/*
 * SearchService.cpp
 *
 *  Created on: Feb 11, 2017
 *      Author: misha
 */

#include <src/services/SearchService.hpp>

QString SearchService::DB_PATH = "./sharewith/search/search.db";

SearchService::SearchService(QObject* parent) : QObject(parent), m_pSda(NULL) {}

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
    m_pSda = new SqlDataAccess(DB_PATH);
    m_pSda->execute("PRAGMA encoding = \"UTF-8\"");
    m_pSda->execute("DROP TABLE IF EXISTS search");
    m_pSda->execute("DROP TABLE IF EXISTS search_info");

    m_pSda->execute("CREATE TABLE search_info (icon_path VARCHAR(128), "
                                              "uri VARCHAR(128), "
                                              "timestamp INTEGER NOT NULL DEFAULT 0, "
                                              "group_id INTEGER NOT NULL DEFAULT 0)");

    m_pSda->execute("CREATE VIRTUAL TABLE search USING fts4 (title, description, TOKENIZE=icu)");

    m_pSda->execute("INSERT INTO search_info (rowid, icon_path, uri, timestamp, group_id) VALUES (1, '', 'http://onliner.by', 0, 1)");
    m_pSda->execute("INSERT INTO search_info (rowid, icon_path, uri, timestamp, group_id) VALUES (2, '', '', 0, 2)");
    m_pSda->execute("INSERT INTO search_info (rowid, icon_path, uri, timestamp, group_id) VALUES (3, '', '', 0, 3)");

    m_pSda->execute("INSERT INTO search (docid, title, description) VALUES (1, 'Onliner', 'Sranoe govno!')");
    m_pSda->execute("INSERT INTO search (docid, title, description) VALUES (2, 'Task image', 'image')");
    m_pSda->execute("INSERT INTO search (docid, title, description) VALUES (3, 'empty', '')");
}

