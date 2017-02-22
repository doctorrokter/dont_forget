/*
 * DBConfig.cpp
 *
 *  Created on: Feb 20, 2017
 *      Author: misha
 */

#include "DBConfig.hpp"
#include "AppConfig.hpp"
#include <QDir>
#include <QDirIterator>
#include <QFile>

#define DB_PATH "./shared/misc/dont_forget"
#define DB_NAME "dont_forget.db"
#define COPY_DB_NAME "dont_forget_copy.db"

DBConfig::DBConfig(QObject* parent) : QObject(parent) {
    QDir dbdir(DB_PATH);
    m_newDb = !dbdir.exists();
    m_hasSharedFilesPermission = true;

    if (m_newDb) {
        dbdir.mkpath(DB_PATH);
    } else {
        if (AppConfig::getStatic("first_run").toString().isEmpty()) {
            AppConfig::setStatic("first_run", "false");
            QFile dbfile(QString::fromLatin1(DB_PATH).append("/").append(DB_NAME));

            bool copied = dbfile.copy(QString::fromLatin1(DB_PATH).append("/").append(DB_NAME), QString::fromLatin1(DB_PATH).append("/").append(COPY_DB_NAME));
            qDebug() << "DB copied successfully: " << copied << endl;

            if (copied) {
                bool removed = dbfile.remove();
                qDebug() << "Old db file removed successfully: " << removed << endl;

                if(removed) {
                    QFile newDbfile(QString::fromLatin1(DB_PATH).append("/").append(COPY_DB_NAME));
                    bool renamed = newDbfile.rename(QString::fromLatin1(DB_PATH).append("/").append(COPY_DB_NAME), QString::fromLatin1(DB_PATH).append("/").append(DB_NAME));
                    qDebug() << "New DB file renamed successfully: " << renamed << endl;
                }
            }
         }
     }

     QString dbpath = QString::fromLatin1(DB_PATH).append("/").append(DB_NAME);
     m_database = QSqlDatabase::addDatabase("QSQLITE");
     m_database.setDatabaseName(dbpath);
     m_database.open();

     if (m_database.isOpenError()) {
         m_hasSharedFilesPermission = false;
     }

     m_pSda = new SqlDataAccess(dbpath);
     m_pSda->execute("PRAGMA encoding = \"UTF-8\"");
     if (m_newDb) {
         qDebug() << "Create DB from scratch" << endl;

         QDirIterator iter("app/native/assets/migrations", QDirIterator::NoIteratorFlags);
         while (iter.hasNext()) {
             QString path = iter.next();
             if (path.endsWith(".sql")) {
                 runMigration(path);
             }
         }
     } else {
         qDebug() << "DB already exists. Use one." << endl;
//         m_pSda->execute("DROP TABLE IF EXISTS schema_version");
//         m_pSda->execute("DROP TABLE IF EXISTS df_users");
         if (AppConfig::getStatic("db_migrated").toString().isEmpty()) {
             qDebug() << "Start DB migration" << endl;
             if (!hasSchemaVersionTable()) {
                 qDebug() << "No schema version table! Will create it" << endl;
                 runMigration("app/native/assets/migrations/1_create_schema_version_table.sql");
                 setVersion(2);
                 qDebug() << "Current schema_version is " << getVersion() << endl;
             }
             migrate();
             qDebug() << "Current DB version is: " << getVersion() << endl;
             AppConfig::setStatic("db_migrated", "true");
         }
     }
}

DBConfig::~DBConfig() {
    delete m_pSda;
    m_pSda = NULL;
    m_database.close();
}

SqlDataAccess* DBConfig::connection() {
    return m_pSda;
}

bool DBConfig::isNewDb() const { return m_newDb; }
bool DBConfig::hasSharedFilesPermission() const { return m_hasSharedFilesPermission; }

void DBConfig::runMigration(const QString& path) {
    qDebug() << "Process migration: " << path << endl;
    int version = getMigrationVersion(path);

    QFile migration(path);
    migration.open(QIODevice::ReadOnly);
    QString data = migration.readAll();
    qDebug() << data << endl;

    QStringList statements = data.split(";");
    foreach(QString stmt, statements) {
        if (!stmt.isEmpty()) {
            m_pSda->execute(stmt);
        }
    }

    setVersion(version);
}

bool DBConfig::hasVersion(const int version) {
    return m_pSda->execute(QString::fromLatin1("SELECT EXISTS (SELECT 1 FROM schema_version WHERE version = %1 LIMIT 1) AS exists").arg(version))
            .toList().first().toMap().value("exists").toInt() != 0;
}

void DBConfig::setVersion(const int version) {
    m_pSda->execute(QString::fromLatin1("INSERT INTO schema_version (version) VALUES (%1)").arg(version));
}

int DBConfig::getVersion() {
    QVariantList res = m_pSda->execute("SELECT version FROM schema_version ORDER BY version DESC LIMIT 1").toList();
    return res.empty() ? 0 : res.first().toMap().value("version").toInt();
}

bool DBConfig::hasSchemaVersionTable() {
    return m_pSda->execute("SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'schema_version'").toList().size() != 0;
}

int DBConfig::getMigrationVersion(const QString& path) {
    return path.split("_")[0].split("/").last().toInt();
}

void DBConfig::migrate() {
    QDirIterator iter("app/native/assets/migrations", QDirIterator::NoIteratorFlags);
    int currVersion = getVersion();
    while (iter.hasNext()) {
        QString path = iter.next();
        if (path.endsWith(".sql")) {
            if (getMigrationVersion(path) > currVersion) {
                qDebug() << "Found new migration" << endl;
                runMigration(path);
            }
        }
    }
}

