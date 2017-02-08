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

#include <bb/data/SqlDataAccess>
#include <QtSql/QtSql>
#include <QDir>
#include <QFile>
#include <QVariantList>
#include <QVariantMap>
#include <bb/pim/notebook/NotebookService>
#include <bb/pim/notebook/NotebookEntry>

using namespace bb::data;
using namespace bb::pim::notebook;

class TasksService: public QObject {
    Q_OBJECT
    Q_PROPERTY(Task* activeTask READ getActiveTask NOTIFY activeTaskChanged)
    Q_PROPERTY(bool hasSharedFilesPermission READ hasSharedFilesPermission)
public:
    static QString DB_PATH;
    static QString DB_NAME;

    TasksService(QObject* parent = 0);
    virtual ~TasksService();

    void init();

    Q_INVOKABLE QVariantList findAll() const;
    Q_INVOKABLE QVariantMap findById(const int id);
    Q_INVOKABLE QVariantList findByType(const QString& type);

    Q_INVOKABLE void changeClosed(const int id, const bool closed);
    Q_INVOKABLE void changeExpanded(const int id, const bool expanded);

    Q_INVOKABLE Task* getActiveTask() const;
    Q_INVOKABLE void setActiveTask(const int id);

    Q_INVOKABLE void createTask(const QString name, const QString description = "", const QString type = "FOLDER", const int deadline = 0, const int important = 0, const int createInRemember = 0);
    Q_INVOKABLE void updateTask(const QString name, const QString description = "", const QString type = "FOLDER", const int deadline = 0, const int important = 0, const int createInRemember = 0);
    Q_INVOKABLE void deleteTask(const int id);
    Q_INVOKABLE void moveTask(const int parentId = 0);

    Q_INVOKABLE void expandAll();
    Q_INVOKABLE void unexpandAll();

    Q_INVOKABLE void changeViewMode(const QString& viewMode);

    Q_INVOKABLE bool hasSharedFilesPermission();

Q_SIGNALS:
    void activeTaskChanged(Task* newActiveTask);
    void taskCreated(QVariantMap newTask);
    void taskUpdated(QVariantMap updatedTask);
    void allTasksExpanded();
    void allTasksUnexpanded();
    void viewModeChanged(const QString& viewMode);
    void taskMoved();

private:
    QSqlDatabase m_database;
    SqlDataAccess* m_pSda;
    Task* m_pActiveTask;
    NotebookService* m_pNotebookService;
    bool m_hasSharedFilesPermission;

    void flushActiveTask();
    NotebookEntry findNotebookEntry(const QString& rememberId);
    NotebookEntry* createNotebookEntry(const QString& name, const QString& description = "", const int deadline = 0);
    NotebookEntry updateNotebookEntry(const QString& rememberId, const QString& name, const QString& description = "", const int deadline = 0);
    void deleteNotebookEntry(const QString& rememberId);
    void sync();
};

#endif /* TASKSSERVICE_HPP_ */
