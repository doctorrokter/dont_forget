/*
 * TasksService.cpp
 *
 *  Created on: Jan 23, 2017
 *      Author: misha
 */

#include "TasksService.hpp"
#include "../config/AppConfig.hpp"
#include <QVariantMap>
#include <QMutableListIterator>
#include <iostream>
#include <QDateTime>
#include <bb/pim/Global>
#include <bb/pim/notebook/NotebookEntryStatus>
#include <bb/pim/notebook/NotebookEntryDescription>
#include <bb/pim/notebook/NotebookEntryId>
#include <limits>
#include "../util/CalendarUtil.hpp"

using namespace std;

TasksService::TasksService(QObject* parent, DBConfig* dbConfig, AttachmentsService* attachmentsService) : QObject(parent),
        m_pDbConfig(dbConfig),
        m_pAttachmentsService(attachmentsService),
        m_pActiveTask(NULL),
        m_pNotebookService(new NotebookService(this)),
        m_multiselectMode(false) {

    bool res = QObject::connect(this, SIGNAL(multiselectModeChanged(bool)), this, SLOT(processMultiselectMode(bool)));
    Q_ASSERT(res);
    Q_UNUSED(res);
}

TasksService::~TasksService() {
    delete m_pDbConfig;
    m_pDbConfig = NULL;
    flushActiveTask();
}

void TasksService::init() {
    if (!m_pDbConfig->isNewDb()) {
        sync();
    }
}

void TasksService::processCollisions() {
    QVariantList collisions = m_pDbConfig->execute("SELECT * FROM tasks WHERE id = parent_id").toList();
    if (!collisions.isEmpty()) {
        qDebug() << "FOUND COLLISIONS!" << endl;
        foreach(QVariant taskVar, collisions) {
            Task t;
            t.fromMap(taskVar.toMap());
            if (hasChildren(t.getId())) {
                m_pDbConfig->execute(QString("UPDATE tasks SET parent_id = NULL WHERE id = %1").arg(t.getId()));
            }
        }
    }
}

QVariantList TasksService::findAll() const {
    QString sortBy = AppConfig::getStatic("sort_by").toString();
    if (sortBy.isEmpty()) {
        sortBy = "name";
    }

    QString desc = AppConfig::getStatic("desc_order").toString();
    if (!desc.isEmpty() && desc.compare("true") == 0) {
        desc = "DESC";
    } else {
        desc = "ASC";
    }

    QVariantList tasks = m_pDbConfig->execute(QString("SELECT * FROM tasks ORDER BY parent_id, type, %1 %2").arg(sortBy).arg(desc)).toList();

    for (int i = 0; i < tasks.size(); i++) {
        QVariantMap taskMap = tasks.at(i).toMap();
        Task task(taskMap);
    }

    return tasks;
}

QVariantMap TasksService::findById(const int id) {
    return m_pDbConfig->execute(QString("SELECT * FROM tasks WHERE id = %1").arg(id)).toList().at(0).toMap();
}

QVariantList TasksService::findByType(const QString& type) {
    return m_pDbConfig->execute(QString("SELECT * FROM tasks WHERE type = '%1'").arg(type)).toList();
}

QVariantList TasksService::findSiblings(const int parentId) {
    return m_pDbConfig->execute(QString("SELECT * FROM tasks WHERE parent_id = %1").arg(parentId)).toList();
}

QVariantMap TasksService::lastCreated() {
    return m_pDbConfig->execute("SELECT * FROM tasks ORDER BY id DESC LIMIT 1").toList().at(0).toMap();
}

bool TasksService::isExists(const int id) {
    return m_pDbConfig->execute(QString("SELECT EXISTS (SELECT 1 FROM tasks WHERE id = %1) AS present").arg(id)).toList().at(0).toMap().value("present").toBool();
}

bool TasksService::hasChildren(const int id) {
    return m_pDbConfig->execute(QString("SELECT EXISTS (SELECT 1 FROM tasks WHERE parent_id = %1) AS present").arg(id)).toList().at(0).toMap().value("present").toBool();
}

void TasksService::changeClosed(const int id, const bool closed) {
    int state = closed ? 1 : 0;
    QString query = QString("UPDATE tasks SET closed = %1 WHERE id = %2").arg(state).arg(id);

    m_pDbConfig->execute(query);
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
    m_pDbConfig->execute(QString("UPDATE tasks SET expanded = %1 WHERE id = %2").arg(state).arg(id));
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

void TasksService::createTask(const QString name, const QString description, const QString type, const int deadline, const int important, const int createInRemember,
        const QVariantList attachments, const int createInCalendar, const int folderId, const int accountId, const QString& color) {
    QString parentId = m_pActiveTask == NULL ? NULL : QString::number(m_pActiveTask->getId());
    QString rememberId = NULL;
    int calendarEventId = 0;

    if (createInRemember) {
        NotebookEntry* note = createNotebookEntry(name, description, deadline);
        rememberId = note->id().toString();

        delete note;
        note = NULL;
    }

    if (deadline != 0 && createInCalendar != 0) {
        CalendarUtil calendar;
        CalendarEvent ev = calendar.createEvent(name, description, QDateTime::fromTime_t(deadline), folderId, accountId);
        calendarEventId = ev.id();
    }

    QString query = "INSERT INTO tasks (name, description, type, deadline, important, parent_id, remember_id, closed, expanded, calendar_id, color) "
                    "VALUES (:name, :description, :type, :deadline, :important, :parent_id, :remember_id, :closed, :expanded, :calendar_id, :color)";
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
    values["calendar_id"] = calendarEventId;
    values["color"] = color;

    m_pDbConfig->execute(query, values);
    QVariantMap newTask = lastCreated();

    if (!attachments.isEmpty()) {
        foreach(QVariant attVar, attachments) {
            QVariantMap attMap = attVar.toMap();
            m_pAttachmentsService->add(newTask.value("id").toInt(), attMap.value("name").toString(), attMap.value("path").toString(), attMap.value("mime_type").toString());
        }
    }

    emit taskCreated(newTask);
}

void TasksService::createFolderQuick(const QString& name) {
    QVariantMap values;
    values["name"] = name;
    values["type"] = "FOLDER";

    m_pDbConfig->execute("INSERT INTO tasks (name, type, expanded) VALUES (:name, :type, 1)", values);
    QVariantMap newTask = lastCreated();

    emit quickFolderCreated(newTask);
}

void TasksService::updateTask(const QString name, const QString description, const QString type, const int deadline, const int important, const int createInRemember,
        const int closed, const QVariantList attachments, const int createInCalendar, const QString& color) {
    QString rememberId = NULL;
    int calendarEventId = 0;

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

    CalendarUtil calendar;
    if (deadline != 0 && createInCalendar != 0) {
        CalendarEvent ev;
        if (m_pActiveTask->getCalendarId() == 0) {
            ev = calendar.createEvent(name, description, QDateTime::fromTime_t(deadline));
        } else {
            ev = calendar.updateEvent(m_pActiveTask->getCalendarId(), name, description, QDateTime::fromTime_t(deadline));
        }
        calendarEventId = ev.id();
    } else if (deadline != 0 && createInCalendar == 0) {
        if (m_pActiveTask->getCalendarId() != 0) {
            calendar.deleteEvent(m_pActiveTask->getCalendarId());
        }
    }

    QString query = "UPDATE tasks SET name = :name, description = :description, type = :type, deadline = :deadline, important = :important, "
            "remember_id = :remember_id, closed = :closed, calendar_id = :calendar_id, color = :color WHERE id = :id";
    QVariantMap values;
    values["name"] = name;
    values["description"] = description;
    values["type"] = type;
    values["deadline"] = deadline;
    values["important"] = important;
    values["remember_id"] = rememberId;
    values["closed"] = closed;
    values["id"] = m_pActiveTask->getId();
    values["calendar_id"] = calendarEventId;
    values["color"] = color;

    m_pDbConfig->execute(query, values);

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
    QString query = QString("DELETE FROM tasks WHERE id = %1");

    if (m_multiselectMode) {
        if (isExists(id)) {
            QVariantMap taskMap = findById(id);
            m_pActiveTask = new Task(this);
            m_pActiveTask->fromMap(taskMap);
        }
    }

    if (m_pActiveTask != NULL) {
        if (id == m_pActiveTask->getId()) {
            if (!m_pActiveTask->getRememberId().isEmpty()) {
                deleteNotebookEntry(m_pActiveTask->getRememberId());
            }
            if (m_pActiveTask->getCalendarId() != 0) {
                CalendarUtil calendar;
                calendar.deleteEvent(m_pActiveTask->getCalendarId());
            }
            query = query.arg(m_pActiveTask->getId());

            m_pDbConfig->execute("PRAGMA foreign_keys = ON");
            m_pDbConfig->execute(query);

            flushActiveTask();
            emit activeTaskChanged(m_pActiveTask);
        } else {
            m_pDbConfig->execute("PRAGMA foreign_keys = ON");
            query = query.arg(id);
            m_pDbConfig->execute(query);
        }
        emit taskDeleted(id);
    }
}

void TasksService::moveTask(const int parentId) {
    QString parent = NULL;
    if (parentId != 0) {
        parent = QString::number(parentId);
    }

    QVariantList values;
    values.append(parent);
    values.append(m_pActiveTask->getId());

    m_pDbConfig->execute("UPDATE tasks SET parent_id = ? WHERE id = ?", values);
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

    m_pDbConfig->execute(query, values);
}

void TasksService::changeParentIdInDebug(const int id, const int parentId) {
    QString parent = NULL;
    if (parentId != 0) {
        parent = QString::number(parentId);
    }

    QVariantMap data;
    data.insert("id", id);
    data.insert("parent_id", parent);

    m_pDbConfig->execute("UPDATE tasks SET parent_id = :parent_id WHERE id = :id", data);
    emit parentIdChangedInDebug(id);
}

void TasksService::expandAll() {
    m_pDbConfig->execute("UPDATE tasks SET expanded = 1");
    emit allTasksExpanded();
}

void TasksService::unexpandAll() {
    m_pDbConfig->execute("UPDATE tasks SET expanded = 0");
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
    syncRememberTasks();
    syncCalendarTasks();
}

void TasksService::syncRememberTasks() {
    QVariantList rememberTasks = m_pDbConfig->connection()->execute("SELECT * FROM tasks WHERE remember_id IS NOT NULL").toList();
        if (!rememberTasks.isEmpty()) {
            for (int i = 0; i < rememberTasks.size(); i++) {
                QVariantMap taskMap = rememberTasks.at(i).toMap();
                int id = taskMap.value("id").toInt();
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

                    m_pDbConfig->execute(query, values);
                } else {
                    m_pDbConfig->execute(QString("UPDATE tasks SET remember_id = NULL WHERE id = %1").arg(id));
                    emit droppedRememberId(id);
                }
             }
         }
}

void TasksService::syncCalendarTasks() {
    QVariantList calendarTasks = m_pDbConfig->execute("SELECT * FROM tasks WHERE calendar_id IS NOT NULL").toList();
    if (!calendarTasks.isEmpty()) {
        CalendarUtil calendar;
        foreach(QVariant taskVar, calendarTasks) {
            QVariantMap taskMap = taskVar.toMap();
            int id = taskMap.value("id").toInt();
            CalendarEvent ev = calendar.findEventById(taskMap.value("calendar_id").toInt());
            if (!ev.isValid()) {
                m_pDbConfig->execute(QString("UPDATE tasks SET calendar_id = NULL WHERE id = %1").arg(id));
                emit droppedCalendarId(id);
            }
        }
    }
}

bool TasksService::isMultiselectMode() const { return m_multiselectMode; }
void TasksService::setMultiselectMode(const bool multiselectMode) {
    m_multiselectMode = multiselectMode;
    emit multiselectModeChanged(multiselectMode);
}

void TasksService::selectTask(const int id) {
    m_tasksIds.append(id);
    qDebug() << m_tasksIds << endl;
    emit taskSelected(id);
}

void TasksService::deselectTask(const int id) {
    QMutableListIterator<int> iterator(m_tasksIds);
    while (iterator.hasNext()) {
        if (iterator.next() == id) {
            iterator.remove();
        }
    }
    qDebug() << m_tasksIds << endl;
    emit taskDeselected(id);
}

bool TasksService::isTaskSelected(const int id) {
    return m_tasksIds.contains(id);
}

QVariantList TasksService::deleteBulk() {
    QVariantList ids;
    foreach(int id, m_tasksIds) {
        deleteTask(id);
        ids.append(id);
    }
    m_tasksIds.clear();
    setMultiselectMode(false);
    return ids;
}

void TasksService::moveBulk(const int parentId) {
    foreach(int id, m_tasksIds) {
        if (parentId != id) {
            QString parent = NULL;
            if (parentId != 0) {
                parent = QString::number(parentId);
            }

            QVariantList values;
            values.append(parent);
            values.append(id);

            m_pDbConfig->execute("UPDATE tasks SET parent_id = ? WHERE id = ?", values);
        }
    }
    m_tasksIds.clear();
    setMultiselectMode(false);
    emit taskMovedInBulk();
}

void TasksService::processMultiselectMode(const bool multiselectMode) {
    if (multiselectMode) {
        if (m_pActiveTask != NULL) {
            m_tasksIds.append(m_pActiveTask->getId());
            flushActiveTask();
            emit activeTaskChanged(m_pActiveTask);
        }
    } else {
        m_tasksIds.clear();
    }
}
