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

using namespace bb::data;

class SearchService: public QObject {
    Q_OBJECT
public:
    SearchService(QObject* parent = 0);
    virtual ~SearchService();

    static QString DB_PATH;

    void dbOpen();
    void init();

private:
    QSqlDatabase m_database;
    SqlDataAccess* m_pSda;
};

#endif /* SEARCHSERVICE_HPP_ */
