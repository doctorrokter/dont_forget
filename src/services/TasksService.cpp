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
#include <QtConcurrentRun>
#include <QFuture>
#include "../util/CalendarUtil.hpp"

using namespace std;

Logger TasksService::logger = Logger::getLogger("TasksService");

TasksService::TasksService(QObject* parent, DBConfig* dbConfig, AttachmentsService* attachmentsService) : QObject(parent),
        m_pDbConfig(dbConfig),
        m_pAttachmentsService(attachmentsService),
        m_pActiveTask(NULL),
        m_pNotebookService(new NotebookService(this)),
        m_multiselectMode(false) {

    m_moveMode = false;

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
    if (AppConfig::getStatic("collisions_processed").toInt() != 1) {
        m_pDbConfig->execute("UPDATE tasks SET parent_id = NULL WHERE id = parent_id");
        QVariantList parents = m_pDbConfig->execute("SELECT id, parent_id FROM tasks WHERE parent_id IS NOT NULL ORDER BY parent_id").toList();
        if (!parents.isEmpty()) {
            foreach(QVariant taskVar, parents) {
                int id = taskVar.toMap().value("id").toInt();
                int parentId = taskVar.toMap().value("parent_id").toInt();
                if (!isExists(parentId)) {
                    m_pDbConfig->execute(QString("UPDATE tasks SET parent_id = NULL WHERE id = %1").arg(id));
                }
            }
        }
        AppConfig::setStatic("collisions_processed", 1);
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

QVariantMap TasksService::findById(const int& id) {
    return m_pDbConfig->execute(QString("SELECT * FROM tasks WHERE id = %1").arg(id)).toList().at(0).toMap();
}

QVariantList TasksService::findByType(const QString& type) {
    return m_pDbConfig->execute(QString("SELECT * FROM tasks WHERE type = '%1'").arg(type)).toList();
}

QVariantList TasksService::findByType(const QString& type, const int& parentId) {
    QVariantMap values;

    QString query = "SELECT * FROM tasks WHERE";
    if (parentId == 0) {
        query = query.append(" parent_id IS NULL");
    } else {
        query = query.append(" parent_id = :parent_id");
        values["parent_id"] = parentId;
    }
    query = query.append(" AND type = :type ORDER BY closed");
    values["type"] = type;

    QVariantList tasks = m_pDbConfig->execute(query, values).toList();
    countOrAttachments(tasks);
    return tasks;
}

QVariantList TasksService::findSiblings(const int& parentId) {
    QVariantMap values;
    QString query = "SELECT * FROM tasks WHERE";
    if (parentId == 0) {
        query = query.append(" parent_id IS NULL");
    } else {
        query = query.append(" parent_id = :parent_id");
        values["parent_id"] = parentId;
    }
    query = query.append(" ORDER BY type, closed");

    QVariantList tasks = m_pDbConfig->execute(query, values).toList();
    countOrAttachments(tasks);
    return tasks;
}

QVariantMap TasksService::lastCreated() {
    return m_pDbConfig->execute("SELECT * FROM tasks ORDER BY id DESC LIMIT 1").toList().at(0).toMap();
}

bool TasksService::isExists(const int& id) {
    return m_pDbConfig->execute(QString("SELECT EXISTS (SELECT 1 FROM tasks WHERE id = %1) AS present").arg(id)).toList().at(0).toMap().value("present").toBool();
}

bool TasksService::hasChildren(const int& id) {
    return m_pDbConfig->execute(QString("SELECT EXISTS (SELECT 1 FROM tasks WHERE parent_id = %1) AS present").arg(id)).toList().at(0).toMap().value("present").toBool();
}

int TasksService::countChildren(const int& id) {
    return m_pDbConfig->execute(QString("SELECT COUNT(*) AS count FROM tasks WHERE parent_id = %1").arg(QString::number(id))).toList().at(0).toMap().value("count").toInt();
}

int TasksService::countImportantTasks() {
    return m_pDbConfig->execute(QString("SELECT COUNT(*) AS count FROM tasks WHERE type IN ('TASK', 'LIST') AND important = 1 AND closed = 0")).toList().at(0).toMap().value("count").toInt();
}

int TasksService::countTodayTasks() {
    QDateTime startOfToday = QDateTime::currentDateTime();
    QTime beginning;
    beginning.setHMS(0, 0, 0, 0);
    startOfToday.setTime(beginning);

    QDateTime endOfToday = QDateTime::currentDateTime();
    QTime end;
    end.setHMS(23, 59, 0, 0);
    endOfToday.setTime(end);

    return m_pDbConfig->execute(QString("SELECT COUNT(*) AS count FROM tasks WHERE type IN ('TASK', 'LIST') AND closed = 0 AND deadline BETWEEN %1 AND %2").arg(startOfToday.toTime_t()).arg(endOfToday.toTime_t())).toList().at(0).toMap().value("count").toInt();
}

int TasksService::countOverdueTasks() {
    QDateTime startOfToday = QDateTime::currentDateTime();
    QTime beginning;
    beginning.setHMS(0, 0, 0, 0);
    startOfToday.setTime(beginning);

    return m_pDbConfig->execute(QString("SELECT COUNT(*) AS count FROM tasks WHERE type IN ('TASK', 'LIST') AND closed = 0 AND deadline != 0 AND deadline < %1").arg(startOfToday.toTime_t())).toList().at(0).toMap().value("count").toInt();
}

int TasksService::countCompletedTasks() {
    return m_pDbConfig->execute("SELECT COUNT(*) AS count FROM tasks WHERE type IN ('TASK', 'LIST') AND closed = 1").toList().at(0).toMap().value("count").toInt();
}

int TasksService::countUpcomingTasks() {
    QDateTime endOfToday = QDateTime::currentDateTime();
    QTime end;
    end.setHMS(23, 59, 0, 0);
    endOfToday.setTime(end);

    return m_pDbConfig->execute(QString("SELECT COUNT(*) AS count FROM tasks WHERE type IN ('TASK', 'LIST') AND closed = 0 AND deadline != 0 AND deadline > %1").arg(endOfToday.toTime_t())).toList().at(0).toMap().value("count").toInt();
}

int TasksService::countReceivedTasks() {
    return m_pDbConfig->execute("SELECT COUNT(*) AS count FROM tasks WHERE type IN ('TASK', 'LIST') AND received = 1").toList().at(0).toMap().value("count").toInt();
}

QVariantList TasksService::findImportantTasks() {
    QVariantList tasks = m_pDbConfig->execute(QString("SELECT * FROM tasks WHERE type IN ('TASK', 'LIST') AND important = 1 AND closed = 0 ORDER BY parent_id")).toList();
    countOrAttachments(tasks);
    return tasks;
}

QVariantList TasksService::findTodayTasks() {
    QDateTime startOfToday = QDateTime::currentDateTime();
    QTime beginning;
    beginning.setHMS(0, 0, 0, 0);
    startOfToday.setTime(beginning);

    QDateTime endOfToday = QDateTime::currentDateTime();
    QTime end;
    end.setHMS(23, 59, 0, 0);
    endOfToday.setTime(end);

    QVariantList tasks = m_pDbConfig->execute(QString("SELECT * FROM tasks WHERE type IN ('TASK', 'LIST') AND closed = 0 AND deadline BETWEEN %1 AND %2 ORDER BY parent_id, type").arg(startOfToday.toTime_t()).arg(endOfToday.toTime_t())).toList();
    countOrAttachments(tasks);
    return tasks;
}

QVariantList TasksService::findOverdueTasks() {
    QDateTime startOfToday = QDateTime::currentDateTime();
    QTime beginning;
    beginning.setHMS(0, 0, 0, 0);
    startOfToday.setTime(beginning);

    QVariantList tasks = m_pDbConfig->execute(QString("SELECT * FROM tasks WHERE type IN ('TASK', 'LIST') AND closed = 0 AND deadline != 0 AND deadline < %1 ORDER BY parent_id, type").arg(startOfToday.toTime_t())).toList();
    countOrAttachments(tasks);
    return tasks;
}

QVariantList TasksService::findCompletedTasks() {
    QVariantList tasks =  m_pDbConfig->execute("SELECT * FROM tasks WHERE type IN ('TASK', 'LIST') AND closed = 1 ORDER BY parent_id, type").toList();
    countOrAttachments(tasks);
    return tasks;
}

QVariantList TasksService::findUpcomingTasks() {
    QDateTime endOfToday = QDateTime::currentDateTime();
    QTime end;
    end.setHMS(23, 59, 0, 0);
    endOfToday.setTime(end);

    QVariantList tasks = m_pDbConfig->execute(QString("SELECT * FROM tasks WHERE type IN ('TASK', 'LIST') AND closed = 0 AND deadline != 0 AND deadline > %1 ORDER BY parent_id, type").arg(endOfToday.toTime_t())).toList();
    countOrAttachments(tasks);
    return tasks;
}

QVariantList TasksService::findReceivedTasks() {
    QVariantList tasks =  m_pDbConfig->execute("SELECT * FROM tasks WHERE type IN ('TASK', 'LIST') AND received = 1 ORDER BY parent_id, type").toList();
    countOrAttachments(tasks);
    return tasks;
}

void TasksService::changeClosed(const int& id, const bool& closed, const int& parentId) {
    Task task;
    task.fromMap(findById(id));

    int state = closed ? 1 : 0;

    if (task.getType().compare("TASK") == 0) {
        QString query = QString("UPDATE tasks SET closed = %1 WHERE id = %2").arg(state).arg(id);
        m_pDbConfig->execute(query);
        changeNotebookEntryState(closed, task.getRememberId());
    } else if (task.getType().compare("LIST") == 0) {
        QString query = QString("UPDATE tasks SET closed = %1 WHERE id = %2 OR parent_id = %3").arg(state).arg(id).arg(id);
        m_pDbConfig->execute(query);

        QStringList rememberIds = m_pDbConfig->execute(QString("SELECT remember_id FROM tasks WHERE parent_id = %1").arg(id)).toStringList();
        foreach(QString rememberId, rememberIds) {
            changeNotebookEntryState(closed, rememberId);
        }
    }
    emit taskClosedChanged(task.getId(), closed, parentId);
}

Task* TasksService::getActiveTask() const { return m_pActiveTask; }
void TasksService::setActiveTask(const int& id) {
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

void TasksService::createTask(const QString& name, const QString& type, const int& parentId) {
    QVariantMap values;
    values["name"] = name;
    values["type"] = type;

    QString query = "INSERT INTO tasks";
    if (parentId == 0) {
        query = query.append(" (name, type) VALUES (:name, :type)");
    } else {
        query = query.append(" (name, type, parent_id) VALUES (:name, :type, :parent_id)");
        values["parent_id"] = parentId;
    }

    m_pDbConfig->execute(query, values);

    QVariantMap task = lastCreated();
    if (type.compare("TASK") != 0) {
        task["count"] = 0;
    } else {
        QVariantList list;
        task["attachments"] = list;
    }

    int parentParentId = 0;
    if (parentId != 0) {
        QVariantMap parent = findById(parentId);
        parentParentId = parent.value("parent_id").toInt();
    }

    emit taskCreated(task, parentId, parentParentId);
}

void TasksService::updateTask(const QString& name, const QString& description, const int& deadline, const int& important, const int& createInRemember,
        const QVariantList& attachments, const int& createInCalendar, const int& folderId, const int& accountId, const QString& color) {
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
            ev = calendar.createEvent(name, description, QDateTime::fromTime_t(deadline), folderId, accountId);
        } else {

            logger.info(QString("curr folder_id: ").append(m_pActiveTask->getFolderId()).append(", curr account_id: ").append(m_pActiveTask->getAccountId()));
            logger.info(QString("new folder_id: ").append(folderId).append(", new account_id: ").append(accountId));

            if (m_pActiveTask->getFolderId() != folderId || m_pActiveTask->getAccountId() != accountId) {
                logger.info("SWITCH CALENDAR ACCOUNTS");
                calendar.deleteEvent(m_pActiveTask->getCalendarId(), m_pActiveTask->getFolderId(), m_pActiveTask->getAccountId());
                ev = calendar.createEvent(name, description, QDateTime::fromTime_t(deadline), folderId, accountId);
            } else {
                logger.info("UPDATE EXISTING CALENDAR EVENT");
                ev = calendar.updateEvent(m_pActiveTask->getCalendarId(), name, description, QDateTime::fromTime_t(deadline), folderId, accountId);
            }
        }
        calendarEventId = ev.id();
    } else if (deadline != 0 && createInCalendar == 0) {
        if (m_pActiveTask->getCalendarId() != 0) {
            calendar.deleteEvent(m_pActiveTask->getCalendarId(), m_pActiveTask->getFolderId(), m_pActiveTask->getAccountId());
        }
    }

    QString query = "UPDATE tasks SET name = :name, description = :description, deadline = :deadline, important = :important, "
            "remember_id = :remember_id, calendar_id = :calendar_id, folder_id = :folder_id, account_id = :account_id, color = :color WHERE id = :id";
    QVariantMap values;
    values["name"] = name;
    values["description"] = description;
    values["deadline"] = deadline;
    values["important"] = important;
    values["remember_id"] = rememberId;
    values["id"] = m_pActiveTask->getId();
    values["calendar_id"] = calendarEventId;
    values["folder_id"] = folderId;
    values["account_id"] = accountId;
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

    taskMap["attachments"] = m_pAttachmentsService->findByTaskId(taskMap.value("id").toInt());

    emit taskUpdated(taskMap, m_pActiveTask->getParentId());
    emit activeTaskChanged(m_pActiveTask);
}

void TasksService::deleteTask(const int& id) {
    if (isExists(id)) {
        QVariantMap taskMap = findById(id);
        Task task;
        task.fromMap(taskMap);

        int parentId = task.getParentId();
        int parentParentId = 0;
        if (parentId != 0) {
            QVariantMap parent = findById(parentId);
            parentParentId = parent.value("parent_id").toInt();
        }

        deleteTaskRecursive(task);
        emit taskDeleted(id, parentId, parentParentId);
    }
}

void TasksService::deleteTaskRecursive(const Task& task) {
    if (!task.getRememberId().isEmpty()) {
        deleteNotebookEntry(task.getRememberId());
    }
    if (task.getCalendarId() != 0) {
        CalendarUtil calendar;
        calendar.deleteEvent(task.getCalendarId(), task.getFolderId(), task.getAccountId());
    }
    QString query = QString("DELETE FROM tasks WHERE id = %1").arg(task.getId());

    if (hasChildren(task.getId())) {
        QVariantList children = findSiblings(task.getId());
        foreach(QVariant taskVar, children) {
            QVariantMap taskMap = findById(taskVar.toMap().value("id").toInt());
            Task child;
            child.fromMap(taskMap);
            deleteTaskRecursive(child);
        }
    }
    m_pDbConfig->execute("PRAGMA foreign_keys = ON");
    m_pDbConfig->execute(query);
}

void TasksService::moveTask(const int& parentId) {
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
    int calendarEventId = task.getCalendarId();

    bool createInRemember = !task.getRememberId().isEmpty();
    if (createInRemember) {
        NotebookEntry* note = createNotebookEntry(task.getName(), task.getDescription(), task.getDeadline());
        rememberId = note->id().toString();

        delete note;
        note = NULL;
    }

    if (task.getCalendarId() != 0 && task.getAccountId() == 1 && task.getFolderId() == 1) {
        CalendarUtil calendar;
        CalendarEvent ev = calendar.createEvent(task.getName(), task.getDescription(), QDateTime::fromTime_t(task.getDeadline()), task.getFolderId(), task.getAccountId());
        calendarEventId = ev.id();
    }

    QString query = "INSERT INTO tasks (name, description, type, deadline, important, parent_id, closed, remember_id, calendar_id, account_id, folder_id, color, received) "
                        "VALUES (:name, :description, :type, :deadline, :important, :parent_id, :closed, :remember_id, :calendar_id, :account_id, :folder_id, :color, :received)";
    QVariantMap values;
    values["name"] = task.getName();
    values["description"] = task.getDescription();
    values["type"] = task.getType();
    values["deadline"] = task.getDeadline();
    values["important"] = task.isImportant() ? 1 : 0;
    values["parent_id"] = parentId;
    values["remember_id"] = rememberId;
    values["closed"] = task.isClosed() ? 1 : 0;
    values["calendar_id"] = calendarEventId;
    values["account_id"] = task.getAccountId();
    values["folder_id"] = task.getFolderId();
    values["color"] = task.getColor();
    values["received"] = task.isReceived() ? 1 : 0;

    m_pDbConfig->execute(query, values);
}

void TasksService::changeParentIdInDebug(const int& id, const int& parentId) {
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

void TasksService::changeNotebookEntryState(const bool& closed, const QString& rememberId) {
    if (!rememberId.isEmpty()) {
        NotebookEntryId entryId(rememberId);
        NotebookEntry note = m_pNotebookService->notebookEntry(entryId);
        if (note.isValid()) {
            note.setStatus(closed ? NotebookEntryStatus::Completed : NotebookEntryStatus::NotCompleted);
            m_pNotebookService->updateNotebookEntry(note);
        }
    }
}

void TasksService::deleteNotebookEntry(const QString& rememberId) {
    NotebookEntryId entryId(rememberId);
    if (entryId.isValid()) {
        m_pNotebookService->deleteNotebookEntry(entryId);
    }
}

void TasksService::sync() {
    QFuture<void> rememberFuture = QtConcurrent::run(this, &TasksService::syncRememberTasks);
    QFuture<void> calendarFuture = QtConcurrent::run(this, &TasksService::syncCalendarTasks);
    qDebug() << "Remember sync started: " << rememberFuture.isStarted() << endl;
    qDebug() << "Calendar sync started: " << calendarFuture.isStarted() << endl;
    qDebug() << "Remember sync running: " << rememberFuture.isRunning() << endl;
    qDebug() << "Calendar sync running: " << calendarFuture.isRunning() << endl;
}

void TasksService::syncRememberTasks() {
    logger.info("===>>> Sync remember tasks");
    QVariantList rememberTasks = m_pDbConfig->connection()->execute("SELECT * FROM tasks WHERE remember_id IS NOT NULL").toList();
        if (!rememberTasks.isEmpty()) {
            for (int i = 0; i < rememberTasks.size(); i++) {
                Task task;
                task.fromMap(rememberTasks.at(i).toMap());

                NotebookEntry note = findNotebookEntry(task.getRememberId());
                if (note.isValid()) {
                    if (!equals(task, note)) {
                        logger.info("Will update task: " + task.getName());

                        QString query = "UPDATE tasks SET name = :name, description = :description, deadline = :deadline, closed = :closed WHERE id = :id";
                        QVariantMap values;
                        values["name"] = note.title();
                        values["description"] = note.description().plainText();

                        uint maxUint = std::numeric_limits<unsigned int>::max();
                        uint noteDeadline = note.reminderTime().toTime_t();
                        values["deadline"] = maxUint == noteDeadline ? 0 : noteDeadline;
                        values["closed"] = note.status() == NotebookEntryStatus::Completed ? 1 : 0;
                        values["id"] = task.getId();

                        m_pDbConfig->execute(query, values);
                        emit changedInRemember(values);
                    } else {
                        logger.info("Nothing to update for task: " + task.getName());
                    }
                } else {
                    m_pDbConfig->execute(QString("UPDATE tasks SET remember_id = NULL WHERE id = %1").arg(task.getId()));
                    emit droppedRememberId(task.getId());
                }
             }
         }
}

bool TasksService::equals(Task& task, NotebookEntry& note) {
    return task.getName().compare(note.title()) == 0 &&
            task.getDescription().compare(note.description().plainText()) == 0 &&
            task.getDeadline() == note.reminderTime().toTime_t() &&
            task.isClosed() == (note.status() == NotebookEntryStatus::Completed);
}

void TasksService::syncCalendarTasks() {
    logger.info("===>>> Sync calendar tasks");
    QVariantList calendarTasks = m_pDbConfig->execute("SELECT * FROM tasks WHERE calendar_id IS NOT NULL").toList();
    if (!calendarTasks.isEmpty()) {
        CalendarUtil calendar;
        foreach(QVariant taskVar, calendarTasks) {
            Task t;
            t.fromMap(taskVar.toMap());
            CalendarEvent ev = calendar.findEventById(t.getCalendarId(), t.getFolderId(), t.getAccountId());
            if (!ev.isValid()) {
                m_pDbConfig->execute(QString("UPDATE tasks SET calendar_id = NULL WHERE id = %1").arg(t.getId()));
                emit droppedCalendarId(t.getId());
            }
        }
    }
}

bool TasksService::isMultiselectMode() const { return m_multiselectMode; }
void TasksService::setMultiselectMode(const bool& multiselectMode) {
    m_multiselectMode = multiselectMode;
    emit multiselectModeChanged(multiselectMode);
}

void TasksService::selectTask(const int& id, const QVariantList& indexPath) {
    if (!isTaskSelected(id)) {
        m_tasksIds.append(id);
        logger.info("Task selected");
        logger.info(m_tasksIds);
        emit taskSelected(id, indexPath);
        emit selectedTasksCountChanged(getSelectedTasksCount());
    }
}

void TasksService::deselectTask(const int& id) {
    QMutableListIterator<int> iterator(m_tasksIds);
    while (iterator.hasNext()) {
        if (iterator.next() == id) {
            iterator.remove();
        }
    }
    logger.info("Task deselected");
    logger.info(m_tasksIds);
    emit taskDeselected(id);
    emit selectedTasksCountChanged(getSelectedTasksCount());
}

void TasksService::deselectAll() {
    m_tasksIds.clear();
    logger.info("All tasks deselected");
    emit allTasksDeselected();
}

bool TasksService::isTaskSelected(const int& id) {
    return m_tasksIds.contains(id);
}

int TasksService::getSelectedTasksCount() const {
    return m_tasksIds.size();
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

void TasksService::moveBulk(const int& parentId) {
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
    emit taskMovedInBulk(parentId);
    emit allTasksDeselected();
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

bool TasksService::isMoveMode() const { return m_moveMode; }
void TasksService::setMoveMode(const bool& moveMode) {
    m_moveMode = moveMode;
    emit moveModeChanged(m_moveMode);
}

void TasksService::countOrAttachments(QVariantList& tasks) {
    QVariantList::Iterator iter;
    for (iter = tasks.begin(); iter != tasks.end(); iter++) {
        QVariantMap taskMap = iter->toMap();
        if (taskMap.value("type").toString().compare("TASK") == 0) {
            taskMap["attachments"] = m_pAttachmentsService->findByTaskId(taskMap.value("id").toInt());
        } else {
            taskMap["count"] = countChildren(taskMap.value("id").toInt());
        }
        *iter = taskMap;
    }
}
