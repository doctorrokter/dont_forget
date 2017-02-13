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
#include <bb/pim/notebook/NotebookEntryStatus>
#include <bb/pim/notebook/NotebookEntryDescription>
#include <bb/pim/notebook/NotebookEntryId>
#include <limits>

//QString TasksService::DB_PATH = "./data/dont_forget.db";
QString TasksService::DB_PATH = "./shared/misc/dont_forget";
QString TasksService::DB_NAME = "dont_forget.db";
QString TasksService::COPY_DB_NAME = "dont_forget_copy.db";

using namespace std;

TasksService::TasksService(QObject* parent) : QObject(parent), m_pSda(NULL),  m_pActiveTask(NULL), m_pNotebookService(new NotebookService(this)), m_hasSharedFilesPermission(true) {}

TasksService::~TasksService() {
    delete m_pSda;
    m_pSda = NULL;
    m_database.close();
    flushActiveTask();
}

void TasksService::init() {
        QDir dbdir(TasksService::DB_PATH);
        bool newDb = !dbdir.exists();

        if (newDb) {
            dbdir.mkpath(TasksService::DB_PATH);
        } else {
            if (AppConfig::getStatic("first_run").toString().isEmpty()) {
                AppConfig::setStatic("first_run", "false");
                QFile dbfile(TasksService::DB_PATH + "/" + TasksService::DB_NAME);

                bool copied = dbfile.copy(TasksService::DB_PATH + "/" + TasksService::DB_NAME, TasksService::DB_PATH + "/" + TasksService::COPY_DB_NAME);
                qDebug() << "DB copied successfully: " << copied << endl;

                if (copied) {
                    bool removed = dbfile.remove();
                    qDebug() << "Old db file removed successfully: " << removed << endl;

                    if(removed) {
                        QFile newDbfile(TasksService::DB_PATH + "/" + TasksService::COPY_DB_NAME);
                        bool renamed = newDbfile.rename(TasksService::DB_PATH + "/" + TasksService::COPY_DB_NAME, TasksService::DB_PATH + "/" + TasksService::DB_NAME);
                        qDebug() << "New DB file renamed successfully: " << renamed << endl;
                    }
                }
            }
        }

        QString dbpath = TasksService::DB_PATH + "/" + TasksService::DB_NAME;
        m_database = QSqlDatabase::addDatabase("QSQLITE");
        m_database.setDatabaseName(dbpath);
        m_database.open();

        if (m_database.isOpenError()) {
            m_hasSharedFilesPermission = false;
        }

        m_pSda = new SqlDataAccess(dbpath);
        m_pSda->execute("PRAGMA encoding = \"UTF-8\"");
        if (newDb) {
            cout << "Create DB from scratch" << endl;
            m_pSda->execute("DROP TABLE IF EXISTS tasks");
            m_pSda->execute("PRAGMA foreign_keys = ON");
            m_pSda->execute("CREATE TABLE tasks (id INTEGER PRIMARY KEY, name TEXT DEFAULT NULL, description TEXT DEFAULT NULL, type TEXT, deadline INTEGER DEFAULT 0, closed INTEGER DEFAULT 0, expanded INTEGER DEFAULT 0, important INTEGER DEFAULT 0, remember_id TEXT DEFAULT NULL)");
            m_pSda->execute("ALTER TABLE tasks ADD COLUMN parent_id INTEGER AFTER type DEFAULT NULL REFERENCES tasks(id) ON DELETE CASCADE ON UPDATE NO ACTION");
        } else {
            cout << "DB already exists. Use one." << endl;
            sync();
        }
    //    m_pSda->execute("DELETE FROM tasks");
}

QVariantList TasksService::findAll() const {
    QString sortBy = AppConfig::getStatic("sort_by").toString();
    if (sortBy.isEmpty()) {
        sortBy = "name";
    }

    QVariantList tasks = m_pSda->execute("SELECT * FROM tasks ORDER BY parent_id, type, " + sortBy).toList();

    for (int i = 0; i < tasks.size(); i++) {
        QVariantMap taskMap = tasks.at(i).toMap();
        Task task(taskMap);
    }

    return tasks;
}

QVariantMap TasksService::findById(const int id) {
    return m_pSda->execute(QString::fromLatin1("SELECT * FROM tasks WHERE id = %1").arg(id)).toList().at(0).toMap();
}

QVariantList TasksService::findByType(const QString& type) {
    return m_pSda->execute(QString::fromLatin1("SELECT * FROM tasks WHERE type = '%1'").arg(type)).toList();
}

void TasksService::changeClosed(const int id, const bool closed) {
    int state = closed ? 1 : 0;
    QString query = QString::fromLatin1("UPDATE tasks SET closed = %1 WHERE id = %2").arg(state).arg(id);

    cout << query.toStdString() << endl;
    m_pSda->execute(query);

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
    QString query = QString::fromLatin1("UPDATE tasks SET expanded = %1 WHERE id = %2").arg(state).arg(id);

    cout << query.toStdString() << endl;

    m_pSda->execute(query);
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

void TasksService::createTask(const QString name, const QString description, const QString type, const int deadline, const int important, const int createInRemember) {
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

    cout << query.toStdString() << endl;

    m_pSda->execute(query, values);
    QVariantMap taskMap = m_pSda->execute("SELECT * FROM tasks ORDER BY id DESC LIMIT 1").toList().at(0).toMap();

    emit taskCreated(taskMap);
}

void TasksService::updateTask(const QString name, const QString description, const QString type, const int deadline, const int important, const int createInRemember) {
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

    QString query = "UPDATE tasks SET name = :name, description = :description, type = :type, deadline = :deadline, important = :important, remember_id = :remember_id WHERE id = :id";
    QVariantMap values;
    values["name"] = name;
    values["description"] = description;
    values["type"] = type;
    values["deadline"] = deadline;
    values["important"] = important;
    values["remember_id"] = rememberId;
    values["id"] = m_pActiveTask->getId();

    qDebug() << query << values << endl;

    m_pSda->execute(query, values);

    QVariantMap taskMap = findById(m_pActiveTask->getId());
    m_pActiveTask->fromMap(taskMap);
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

            cout << query.toStdString() << endl;

            m_pSda->execute("PRAGMA foreign_keys = ON");
            m_pSda->execute(query);

            flushActiveTask();
            emit activeTaskChanged(m_pActiveTask);
    } else {
        m_pSda->execute("PRAGMA foreign_keys = ON");
        query = query.arg(id);
        m_pSda->execute(query);

        cout << query.toStdString() << endl;
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

    qDebug() << query << values << endl;

    m_pSda->execute(query, values);

    emit taskMoved();
}

void TasksService::expandAll() {
    m_pSda->execute("UPDATE tasks SET expanded = 1");
    emit allTasksExpanded();
}

void TasksService::unexpandAll() {
    m_pSda->execute("UPDATE tasks SET expanded = 0");
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
    QVariantList rememberTasks = m_pSda->execute("SELECT * FROM tasks WHERE remember_id IS NOT NULL").toList();
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

                cout << query.toStdString() << endl;
                m_pSda->execute(query, values);
            } else {
                QString query = QString::fromLatin1("UPDATE tasks SET remember_id = NULL WHERE id = %1").arg(taskMap.value("id").toInt());
                cout << query.toStdString() << endl;
                m_pSda->execute(query);
            }
         }
     }
}

bool TasksService::hasSharedFilesPermission() { return m_hasSharedFilesPermission; }

