/*
 * SearchService.hpp
 *
 *  Created on: Feb 11, 2017
 *      Author: misha
 */

#ifndef SEARCHSERVICE_HPP_
#define SEARCHSERVICE_HPP_

#include <QtCore/QObject>
#include <bb/data/SqlDataAccess>
#include <QtSql/QtSql>
#include <QVariantMap>

#include "TasksService.hpp"

using namespace bb::data;

class SearchService: public QObject {
    Q_OBJECT
public:
    SearchService(QObject* parent = 0, TasksService* tasksService = 0);
    virtual ~SearchService();

    static QString DB_PATH;

    void dbOpen();
    void init();

private Q_SLOTS:
    void onTaskCreated(const QVariantMap& task);
    void onTaskUpdated(const QVariantMap& task);
    void onTaskDeleted(const int id);
    void onTaskMoved(const int id, const int parentId);

private:
    QSqlDatabase m_database;
    SqlDataAccess* m_pSda;

    TasksService* m_pTaskService;

    void addTask(const QVariantMap& taskMap);
};

#endif /* SEARCHSERVICE_HPP_ */
