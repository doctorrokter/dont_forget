/*
 * SearchService.cpp
 *
 *  Created on: Feb 11, 2017
 *      Author: misha
 */

#include "SearchService.hpp"
#include "../config/AppConfig.hpp"
#include <QFile>
#include <QVariantList>
#include <QVariantMap>
#include "../models/Task.hpp"

QString SearchService::DB_PATH = "./sharewith/search/search.db";

SearchService::SearchService(QObject* parent, TasksService* tasksService) : QObject(parent), m_pSda(NULL), m_pTaskService(tasksService) {}

SearchService::~SearchService() {
    delete m_pSda;
    m_pSda = NULL;
    if (m_database.isOpen()) {
        m_database.close();
    }
}

void SearchService::dbOpen() {
    if (!m_database.isOpen()) {
        m_database = QSqlDatabase::addDatabase("QSQLITE");
        m_database.setDatabaseName(DB_PATH);
        m_database.open();
    }
}

void SearchService::init() {
    qDebug() << "Reindex tasks" << endl;

    m_pSda = new SqlDataAccess(DB_PATH);
    m_pSda->execute("PRAGMA encoding = \"UTF-8\"");

//    QString searchDbIndexed = AppConfig::getStatic("search_db_indexed").toString();
//    if (searchDbIndexed.isEmpty()) {
        m_pSda->execute("DROP TABLE IF EXISTS search");
        m_pSda->execute("DROP TABLE IF EXISTS search_info");

        m_pSda->execute("PRAGMA foreign_keys = ON");
        m_pSda->execute("CREATE TABLE search_info (icon_path VARCHAR(128), "
                                                              "uri VARCHAR(128), "
                                                              "timestamp INTEGER NOT NULL DEFAULT 0, "
                                                              "group_id INTEGER NOT NULL DEFAULT 0,"
                                                              "task_id INTEGER PRIMARY KEY NOT NULL DEFAULT 0,"
                                                              "parent_id INTEGER DEFAULT NULL,"
                                                              "FOREIGN KEY (parent_id) REFERENCES search_info(task_id) ON DELETE CASCADE ON UPDATE NO ACTION)");
        m_pSda->execute("CREATE VIRTUAL TABLE search USING fts4 (title TEXT,"
                                                                "description TEXT,"
                                                                "TOKENIZE=icu)");
        m_pSda->execute("CREATE TRIGGER Search_DELETE AFTER DELETE ON search_info\n"
                        "BEGIN\n"
                            "DELETE FROM search WHERE rowid = OLD.rowid;"
                        "END;");

        if (m_pTaskService != NULL) {
            QVariantList tasks = m_pTaskService->findAll();
//            QString query1("INSERT INTO search_info (rowid, icon_path, uri, timestamp, group_id, task_id, parent_id) ");
//            QString query2("INSERT INTO search (docid, title, description) ");
            for (int i = 0; i < tasks.size(); i++) {
                addTask(tasks.at(i).toMap());

//                QVariantMap taskMap = tasks.at(i).toMap();
//                Task task;
//                task.fromMap(tasks.at(i).toMap());
//
//                QString parentId = NULL;
//                if (!taskMap.value("parent_id").toString().isEmpty()) {
//                    parentId = taskMap.value("parent_id").toString();
//                }
//
//                QString taskId = QString::number(task.getId());
//                if (i == 0) {
//                    query1.append("SELECT '" + taskId + "' AS 'rowid', '' AS 'icon_path', '' AS 'uri', '0' AS 'timestamp', '" + taskId + "' AS 'group_id', '" + taskId + "' AS 'task_id', '" + parentId + "' AS 'parent_id' ");
//                    query2.append("SELECT '" + taskId + "' AS 'docid', '" + task.getName() + "' AS 'title', '" + task.getDescription() + "' AS 'description' ");
//                } else {
//                    query1.append("UNION ALL SELECT '" + taskId + "', '', '', '0', '" + taskId + "', '" + taskId + "', '" + parentId + "' ");
//                    query2.append("UNION ALL SELECT '" + taskId + "', '" + task.getName() + "', '" + task.getDescription() + "' ");
//                }
            }

//            qDebug() << query1 << endl;
//            qDebug() << query2 << endl;
//
//            m_pSda->execute(query1);
//            m_pSda->execute(query2);
//            AppConfig::setStatic("search_db_indexed", "true");
        }
//    } else {
//        qDebug() << "Search DB already indexed." << endl;
//    }

    if (m_pTaskService != NULL) {
        bool res = QObject::connect(m_pTaskService, SIGNAL(taskCreated(const QVariantMap&)), this, SLOT(onTaskCreated(const QVariantMap&)));
        Q_ASSERT(res);
        res = QObject::connect(m_pTaskService, SIGNAL(taskUpdated(const QVariantMap&)), this, SLOT(onTaskUpdated(const QVariantMap&)));
        Q_ASSERT(res);
        res = QObject::connect(m_pTaskService, SIGNAL(taskDeleted(const int)), this, SLOT(onTaskDeleted(const int)));
        Q_ASSERT(res);
        res = QObject::connect(m_pTaskService, SIGNAL(taskMoved(const int, const int)), this, SLOT(onTaskMoved(const int, const int)));
        Q_ASSERT(res);
        Q_UNUSED(res);
    }
}

void SearchService::onTaskCreated(const QVariantMap& taskMap) {
    addTask(taskMap);
}

void SearchService::onTaskUpdated(const QVariantMap& taskMap) {
    Task task;
    task.fromMap(taskMap);

    QString searchQuery = "UPDATE search SET title = :title, description = :description WHERE docid = :docid";
    QVariantMap searchData;
    searchData["docid"] = task.getId();
    searchData["title"] = task.getName();
    searchData["description"] = task.getDescription();

    m_pSda->execute(searchQuery, searchData);
}

void SearchService::onTaskDeleted(const int id) {
    m_pSda->execute("PRAGMA foreign_keys = ON");
    m_pSda->execute(QString::fromLatin1("DELETE FROM search_info WHERE task_id = %1").arg(id));
    m_pSda->execute(QString::fromLatin1("DELETE FROM search WHERE docid = %1").arg(id));
}

void SearchService::onTaskMoved(const int id, const int parentId) {
    QString parent = NULL;
    if (parentId != 0) {
        parent = QString::number(parentId);
    }
    QVariantMap searchInfoData;
    searchInfoData["parent_id"] = parent;
    searchInfoData["rowid"] = id;
    m_pSda->execute("UPDATE search_info SET parent_id = :parent_id WHERE rowid = :rowid", searchInfoData);
}

void SearchService::addTask(const QVariantMap& taskMap) {
    Task task;
    task.fromMap(taskMap);

    QString parentId = NULL;
    if (!taskMap.value("parent_id").toString().isEmpty()) {
        parentId = taskMap.value("parent_id").toString();
    }

    QString searchInfoQuery = "INSERT INTO search_info (rowid, icon_path, uri, timestamp, group_id, task_id, parent_id) VALUES (:rowid, '', '', 0, :group_id, :task_id, :parent_id)";
    QVariantMap searchInfoData;
    searchInfoData["rowid"] = task.getId();
    searchInfoData["group_id"] = task.getId();
    searchInfoData["task_id"] = task.getId();
    searchInfoData["parent_id"] = parentId;

//    qDebug() << searchInfoQuery << searchInfoData << endl;

    m_pSda->execute(searchInfoQuery, searchInfoData);

    QString searchQuery = "INSERT INTO search (docid, title, description) VALUES (:docid, :title, :description)";
    QVariantMap searchData;
    searchData["docid"] = task.getId();
    searchData["title"] = task.getName();
    searchData["description"] = task.getDescription();

//    qDebug() << searchQuery << searchData << endl;

    m_pSda->execute(searchQuery, searchData);
}
