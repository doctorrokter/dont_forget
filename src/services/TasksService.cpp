/*
 * TasksService.cpp
 *
 *  Created on: Jan 23, 2017
 *      Author: misha
 */

#include "TasksService.hpp"
#include "../config/AppConfig.hpp"
#include <QVariantMap>
#include <iostream>
#include <QDateTime>
#include <bb/pim/Global>
#include <bb/pim/notebook/NotebookEntryStatus>
#include <bb/pim/notebook/NotebookEntryDescription>
#include <bb/pim/notebook/NotebookEntryId>
#include <limits>

using namespace std;

TasksService::TasksService(QObject* parent, DBConfig* dbConfig, AttachmentsService* attachmentsService) : QObject(parent), m_pDbConfig(dbConfig), m_pAttachmentsService(attachmentsService), m_pActiveTask(NULL), m_pNotebookService(new NotebookService(this)) {}

TasksService::~TasksService() {
    delete m_pDbConfig;
    m_pDbConfig = NULL;
    flushActiveTask();
}

void TasksService::init() {
    if (!m_pDbConfig->isNewDb()) {
        sync();
    }
    //    m_pSda->execute("DELETE FROM tasks");
}

QVariantList TasksService::findAll() const {
    QString sortBy = AppConfig::getStatic("sort_by").toString();
    if (sortBy.isEmpty()) {
        sortBy = "name";
    }

    QVariantList tasks = m_pDbConfig->connection()->execute("SELECT * FROM tasks ORDER BY parent_id, type, " + sortBy).toList();

    for (int i = 0; i < tasks.size(); i++) {
        QVariantMap taskMap = tasks.at(i).toMap();
        Task task(taskMap);
    }

    return tasks;
}

QVariantMap TasksService::findById(const int id) {
    return m_pDbConfig->connection()->execute(QString::fromLatin1("SELECT * FROM tasks WHERE id = %1").arg(id)).toList().at(0).toMap();
}

QVariantList TasksService::findByType(const QString& type) {
    return m_pDbConfig->connection()->execute(QString::fromLatin1("SELECT * FROM tasks WHERE type = '%1'").arg(type)).toList();
}

QVariantList TasksService::findSiblings(const int parentId) {
    return m_pDbConfig->connection()->execute(QString::fromLatin1("SELECT * FROM tasks WHERE parent_id = %1").arg(parentId)).toList();
}

QVariantMap TasksService::lastCreated() {
    return m_pDbConfig->connection()->execute("SELECT * FROM tasks ORDER BY id DESC LIMIT 1").toList().at(0).toMap();
}

void TasksService::changeClosed(const int id, const bool closed) {
    int state = closed ? 1 : 0;
    QString query = QString::fromLatin1("UPDATE tasks SET closed = %1 WHERE id = %2").arg(state).arg(id);

    m_pDbConfig->connection()->execute(query);
    if (m_pActiveTask != NULL) {
        m_pActiveTask->setClosed(closed);
        emit activeTaskChanged(m_pActiveTask);
    }

    Task task;
    task.fromMap(findById(id));
    if (!task.getRememberId().isEmpty()) {
        NotebookEntryId entryId(task.getRememberId());
        NotebookEntry note = m_pNotebookService->notebookEntry(entryId);
        if (note.isValid()) {
            note.setStatus(closed ? NotebookEntryStatus::Completed : NotebookEntryStatus::NotCompleted);
            m_pNotebookService->updateNotebookEntry(note);
        }
    }
}

void TasksService::changeExpanded(const int id, const bool expanded) {
    int state = expanded ? 1 : 0;
    m_pDbConfig->connection()->execute(QString::fromLatin1("UPDATE tasks SET expanded = %1 WHERE id = %2").arg(state).arg(id));
}

Task* TasksService::getActiveTask() const { return m_pActiveTask; }
void TasksService::setActiveTask(const int id) {
    if (id != 0) {
        QVariantMap taskMap = findById(id);

        delete m_pActiveTask;
        m_pActiveTask = new Task(this);
        m_pActiveTask->fromMap(taskMap);
    } else {
        flushActiveTask();
    }

    emit activeTaskChanged(m_pActiveTask);
}

void TasksService::createTask(const QString name, const QString description, const QString type, const int deadline, const int important, const int createInRemember, const QVariantList attachments) {
    QString parentId = m_pActiveTask == NULL ? NULL : QString::number(m_pActiveTask->getId());
    QString rememberId = NULL;

    if (createInRemember) {
        NotebookEntry* note = createNotebookEntry(name, description, deadline);
        rememberId = note->id().toString();

        delete note;
        note = NULL;
    }

    QString query = "INSERT INTO tasks (name, description, type, deadline, important, parent_id, remember_id, closed, expanded) "
                    "VALUES (:name, :description, :type, :deadline, :important, :parent_id, :remember_id, :closed, :expanded)";
    QVariantMap values;
    values["name"] = name;
    values["description"] = description;
    values["type"] = type;
    values["deadline"] = deadline;
    values["important"] = important;
    values["parent_id"] = parentId;
    values["remember_id"] = rememberId;
    values["closed"] = 0;
    values["expanded"] = 1;

    m_pDbConfig->connection()->execute(query, values);
    QVariantMap newTask = lastCreated();

    if (!attachments.isEmpty()) {
        foreach(QVariant attVar, attachments) {
            QVariantMap attMap = attVar.toMap();
            m_pAttachmentsService->add(newTask.value("id").toInt(), attMap.value("name").toString(), attMap.value("path").toString(), attMap.value("mime_type").toString());
        }
    }

    emit taskCreated(newTask);
}

void TasksService::updateTask(const QString name, const QString description, const QString type, const int deadline, const int important, const int createInRemember, const int closed, const QVariantList attachments) {
    QString rememberId = NULL;

    if (createInRemember) {
        if (m_pActiveTask->getRememberId().isEmpty()) {
            NotebookEntry* note = createNotebookEntry(name, description, deadline);
            rememberId = note->id().toString();

            delete note;
            note = NULL;
        } else {
            NotebookEntry note = updateNotebookEntry(m_pActiveTask->getRememberId(), name, description, deadline);
            if (note.isValid()) {
                rememberId = note.id().toString();
            }
        }
    } else {
        if (!m_pActiveTask->getRememberId().isEmpty()) {
            deleteNotebookEntry(m_pActiveTask->getRememberId());
        }
    }

    QString query = "UPDATE tasks SET name = :name, description = :description, type = :type, deadline = :deadline, important = :important, remember_id = :remember_id, closed = :closed WHERE id = :id";
    QVariantMap values;
    values["name"] = name;
    values["description"] = description;
    values["type"] = type;
    values["deadline"] = deadline;
    values["important"] = important;
    values["remember_id"] = rememberId;
    values["closed"] = closed;
    values["id"] = m_pActiveTask->getId();

    m_pDbConfig->connection()->execute(query, values);

    QVariantMap taskMap = findById(m_pActiveTask->getId());
    m_pActiveTask->fromMap(taskMap);


    if (!attachments.isEmpty()) {
        foreach(QVariant attVar, attachments) {
            QVariantMap attMap = attVar.toMap();
            if (!attMap.contains("id")) {
                m_pAttachmentsService->add(m_pActiveTask->getId(), attMap.value("name").toString(), attMap.value("path").toString(), attMap.value("mime_type").toString());
            }
        }
    }

    emit taskUpdated(taskMap);
    emit activeTaskChanged(m_pActiveTask);
}

void TasksService::deleteTask(const int id) {
    QString query = QString::fromLatin1("DELETE FROM tasks WHERE id = %1");

    if (id == m_pActiveTask->getId()) {
        if (!m_pActiveTask->getRememberId().isEmpty()) {
                deleteNotebookEntry(m_pActiveTask->getRememberId());
            }
            query = query.arg(m_pActiveTask->getId());

            m_pDbConfig->connection()->execute("PRAGMA foreign_keys = ON");
            m_pDbConfig->connection()->execute(query);

            flushActiveTask();
            emit activeTaskChanged(m_pActiveTask);
    } else {
        m_pDbConfig->connection()->execute("PRAGMA foreign_keys = ON");
        query = query.arg(id);
        m_pDbConfig->connection()->execute(query);
    }
    emit taskDeleted(id);
}

void TasksService::moveTask(const int parentId) {
    QString parent = NULL;
    if (parentId != 0) {
        parent = QString::number(parentId);
    }

    QString query = "UPDATE tasks SET parent_id = ? WHERE id = ?";
    QVariantList values;
    values.append(parent);
    values.append(m_pActiveTask->getId());

//    qDebug() << query << values << endl;

    m_pDbConfig->connection()->execute(query, values);

    emit taskMoved(m_pActiveTask->getId(), parentId);
}

void TasksService::copyTask(const Task& task) {
    QString parentId = task.getParentId() == 0 ? NULL : QString::number(task.getParentId());
    QString rememberId = NULL;

    bool createInRemember = !task.getRememberId().isEmpty();
    if (createInRemember) {
        NotebookEntry* note = createNotebookEntry(task.getName(), task.getDescription(), task.getDeadline());
        rememberId = note->id().toString();

        delete note;
        note = NULL;
    }

    QString query = "INSERT INTO tasks (name, description, type, deadline, important, parent_id, closed, expanded, remember_id) "
                        "VALUES (:name, :description, :type, :deadline, :important, :parent_id, :closed, :expanded, :remember_id)";
    QVariantMap values;
    values["name"] = task.getName();
    values["description"] = task.getDescription();
    values["type"] = task.getType();
    values["deadline"] = task.getDeadline();
    values["important"] = task.isImportant() ? 1 : 0;
    values["parent_id"] = parentId;
    values["remember_id"] = rememberId;
    values["closed"] = task.isClosed() ? 1 : 0;
    values["expanded"] = 1;

    qDebug() << query << values << endl;

    m_pDbConfig->connection()->execute(query, values);
}

void TasksService::expandAll() {
    m_pDbConfig->connection()->execute("UPDATE tasks SET expanded = 1");
    emit allTasksExpanded();
}

void TasksService::unexpandAll() {
    m_pDbConfig->connection()->execute("UPDATE tasks SET expanded = 0");
    flushActiveTask();
    emit allTasksUnexpanded();
    emit activeTaskChanged(m_pActiveTask);
}

void TasksService::changeViewMode(const QString& viewMode) {
    emit viewModeChanged(viewMode);
}

void TasksService::flushActiveTask() {
    delete m_pActiveTask;
    m_pActiveTask = NULL;
}

NotebookEntry TasksService::findNotebookEntry(const QString& rememberId) {
    NotebookEntryId entryId(rememberId);
    return m_pNotebookService->notebookEntry(entryId);
}

NotebookEntry* TasksService::createNotebookEntry(const QString& name, const QString& description, const int deadline) {
    NotebookEntry* note = new NotebookEntry();
    note->setTitle(name);

    NotebookEntryDescription desc;
    desc.setText(description, NotebookEntryDescription::PLAIN_TEXT);
    note->setDescription(desc);
    note->setStatus(NotebookEntryStatus::NotCompleted);
    if (deadline != 0) {
        note->setDueDateTime(QDateTime::fromTime_t(deadline));
        note->setReminderTime(QDateTime::fromTime_t(deadline));
    }
    m_pNotebookService->addNotebookEntry(note, m_pNotebookService->defaultNotebook().id());
    return note;
}

NotebookEntry TasksService::updateNotebookEntry(const QString& rememberId, const QString& name, const QString& description, const int deadline) {
    NotebookEntry note = findNotebookEntry(rememberId);
    if (note.isValid()) {
        note.setTitle(name);

        NotebookEntryDescription desc;
        desc.setText(description, NotebookEntryDescription::PLAIN_TEXT);
        note.setDescription(desc);

        if (deadline == 0) {
            note.resetDueDateTime();
            note.resetReminderTime();
        } else {
            note.setDueDateTime(QDateTime::fromTime_t(deadline));
            note.setReminderTime(QDateTime::fromTime_t(deadline));
        }
        m_pNotebookService->updateNotebookEntry(note);
    }
    return note;
}

void TasksService::deleteNotebookEntry(const QString& rememberId) {
    NotebookEntryId entryId(rememberId);
    if (entryId.isValid()) {
        m_pNotebookService->deleteNotebookEntry(entryId);
    }
}

void TasksService::sync() {
    QVariantList rememberTasks = m_pDbConfig->connection()->execute("SELECT * FROM tasks WHERE remember_id IS NOT NULL").toList();
    if (!rememberTasks.isEmpty()) {
        for (int i = 0; i < rememberTasks.size(); i++) {
            QVariantMap taskMap = rememberTasks.at(i).toMap();
            NotebookEntry note = findNotebookEntry(taskMap.value("remember_id").toString());
            if (note.isValid()) {
                QString query = "UPDATE tasks SET name = :name, description = :description, deadline = :deadline, closed = :closed WHERE id = :id";
                QVariantMap values;
                values["name"] = note.title();
                values["description"] = note.description().plainText();

                uint maxUint = std::numeric_limits<unsigned int>::max();
                uint noteDeadline = note.reminderTime().toTime_t();
                values["deadline"] = maxUint == noteDeadline ? 0 : noteDeadline;

                values["closed"] = note.status() == NotebookEntryStatus::Completed ? 1 : 0;
                values["id"] = taskMap.value("id").toInt();

//                cout << query.toStdString() << endl;
                m_pDbConfig->connection()->execute(query, values);
            } else {
                QString query = QString::fromLatin1("UPDATE tasks SET remember_id = NULL WHERE id = %1").arg(taskMap.value("id").toInt());
//                cout << query.toStdString() << endl;
                m_pDbConfig->connection()->execute(query);
            }
         }
     }
}
