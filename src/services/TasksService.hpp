/*
 * TasksService.hpp
 *
 *  Created on: Jan 23, 2017
 *      Author: misha
 */

#ifndef TASKSSERVICE_HPP_
#define TASKSSERVICE_HPP_

#include <QtCore/QObject>
#include "../models/Task.hpp"
#include "../config/DBConfig.hpp"
#include "AttachmentsService.hpp"
#include "../const/TaskMovingMode.hpp"

#include <QVariantList>
#include <QVariantMap>
#include <QList>
#include <bb/pim/notebook/NotebookService>
#include <bb/pim/notebook/NotebookEntry>

using namespace bb::data;
using namespace bb::pim::notebook;

class TasksService: public QObject {
    Q_OBJECT
    Q_PROPERTY(Task* activeTask READ getActiveTask NOTIFY activeTaskChanged)
    Q_PROPERTY(bool multiselectMode READ isMultiselectMode WRITE setMultiselectMode NOTIFY multiselectModeChanged)
public:
    TasksService(QObject* parent = 0, DBConfig* dbConfig = 0, AttachmentsService* attachmentsService = 0);
    virtual ~TasksService();

    void init();
    void processCollisions();

    Q_INVOKABLE QVariantList findAll() const;
    Q_INVOKABLE QVariantMap findById(const int id);
    Q_INVOKABLE QVariantList findByType(const QString& type);
    Q_INVOKABLE QVariantList findSiblings(const int parentId);
    Q_INVOKABLE QVariantMap lastCreated();
    Q_INVOKABLE bool isExists(const int id);
    Q_INVOKABLE bool hasChildren(const int id);

    Q_INVOKABLE void changeClosed(const int id, const bool closed);
    Q_INVOKABLE void changeExpanded(const int id, const bool expanded);

    Q_INVOKABLE Task* getActiveTask() const;
    Q_INVOKABLE void setActiveTask(const int id);

    Q_INVOKABLE void createTask(const QString name = "", const QString description = "", const QString type = "TASK", const int deadline = 0, const int important = 0,
            const int createInRemember = 0, const QVariantList attachments = QVariantList(), const int createInCalendar = 0, const int folderId = 1, const int accountId = 1,
            const QString& color = "");
    Q_INVOKABLE void createFolderQuick(const QString& name);
    Q_INVOKABLE void updateTask(const QString name = "", const QString description = "", const QString type = "TASK", const int deadline = 0, const int important = 0, const int createInRemember = 0, const int closed = 0, const QVariantList attachments = QVariantList(), const int createInCalendar = 0, const int folderId = 1, const int accountId = 1, const QString& color = "");
    Q_INVOKABLE void deleteTask(const int id);
    Q_INVOKABLE void moveTask(const int parentId = 0);
    Q_INVOKABLE void copyTask(const Task& task);
    Q_INVOKABLE void changeParentIdInDebug(const int id, const int parentId);

    Q_INVOKABLE void expandAll();
    Q_INVOKABLE void unexpandAll();

    Q_INVOKABLE void changeViewMode(const QString& viewMode);
    Q_INVOKABLE bool isMultiselectMode() const;
    Q_INVOKABLE void setMultiselectMode(const bool multiselectMode);
    Q_INVOKABLE void selectTask(const int id);
    Q_INVOKABLE void deselectTask(const int id);
    Q_INVOKABLE bool isTaskSelected(const int id);
    Q_INVOKABLE QVariantList deleteBulk();
    Q_INVOKABLE void moveBulk(const int parentId);

    Q_INVOKABLE int getMoveMode() const;
    Q_INVOKABLE void setMoveMode(const int& moveMode);

Q_SIGNALS:
    void activeTaskChanged(Task* newActiveTask);
    void taskCreated(QVariantMap newTask);
    void quickFolderCreated(QVariantMap newTask);
    void taskUpdated(QVariantMap updatedTask);
    void taskDeleted(const int id);
    void allTasksExpanded();
    void allTasksUnexpanded();
    void viewModeChanged(const QString& viewMode);
    void taskMoved(const int id, const int parentId);
    void multiselectModeChanged(const bool multiselectMode);
    void taskSelected(const int id);
    void taskDeselected(const int id);
    void taskMovedInBulk();
    void changedInRemember(const QVariantMap& taskMap);
    void droppedRememberId(const int taskId);
    void droppedCalendarId(const int taskId);
    void parentIdChangedInDebug(const int id);
    void moveModeChanged(const int& moveMode);

private Q_SLOTS:
    void processMultiselectMode(const bool multiselectMode);

private:
    DBConfig* m_pDbConfig;
    AttachmentsService* m_pAttachmentsService;

    Task* m_pActiveTask;
    NotebookService* m_pNotebookService;

    bool m_multiselectMode;
    QList<int> m_tasksIds;

    int m_moveMode;

    void flushActiveTask();
    NotebookEntry findNotebookEntry(const QString& rememberId);
    NotebookEntry* createNotebookEntry(const QString& name, const QString& description = "", const int deadline = 0);
    NotebookEntry updateNotebookEntry(const QString& rememberId, const QString& name, const QString& description = "", const int deadline = 0);
    void deleteNotebookEntry(const QString& rememberId);
    void sync();
    void syncRememberTasks();
    void syncCalendarTasks();
    bool equals(Task& task, NotebookEntry& note);
};

#endif /* TASKSSERVICE_HPP_ */
