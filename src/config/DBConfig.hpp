/*
 * DBConfig.hpp
 *
 *  Created on: Feb 20, 2017
 *      Author: misha
 */

#ifndef DBCONFIG_HPP_
#define DBCONFIG_HPP_

#include <QtCore/QObject>
#include <bb/data/SqlDataAccess>
#include <QtSql/QtSql>
#include <QVariant>
#include <QVariantMap>
#include <QVariantList>
#include "../Logger.hpp"

using namespace bb::data;

class DBConfig: public QObject {
    Q_OBJECT
public:
    DBConfig(QObject* parent = 0);
    virtual ~DBConfig();

    QVariant execute(const QString& query);
    QVariant execute(const QString& query, const QVariantMap& data);
    QVariant execute(const QString& query, const QVariantList& data);

    SqlDataAccess* connection();
    bool isNewDb() const;
    bool hasSharedFilesPermission() const;

private:
    QSqlDatabase m_database;
    SqlDataAccess* m_pSda;
    bool m_hasSharedFilesPermission;
    bool m_newDb;

    static Logger logger;

    void runMigration(const QString& path);
    bool hasVersion(const int version);
    void setVersion(const int version);
    int getVersion();
    bool hasSchemaVersionTable();
    int getMigrationVersion(const QString& path);
    void migrate();
    int maxMigrationVersion();
};

#endif /* DBCONFIG_HPP_ */
