/*
 * UsersService.hpp
 *
 *  Created on: Feb 21, 2017
 *      Author: misha
 */

#ifndef USERSSERVICE_HPP_
#define USERSSERVICE_HPP_

#include <QtCore/QObject>
#include <QVariantList>
#include <QVariantMap>
#include "../config/DBConfig.hpp"

class UsersService: public QObject {
    Q_OBJECT
public:
    UsersService(QObject* parent = 0, DBConfig* dbConfig = 0);
    virtual ~UsersService();

    Q_INVOKABLE QVariantList findAll() const;
    Q_INVOKABLE QVariantMap findById(const int id) const;
    Q_INVOKABLE void add(const QString& firstName, const QString& lastName, const QString& pin);
    Q_INVOKABLE void remove(const int id);
    Q_INVOKABLE void update(const int id, const QString& firstName, const QString& lastName, const QString& pin);

Q_SIGNALS:
    void userAdded(QVariantMap userMap);
    void userUpdated();
    void userRemoved();

private:
    DBConfig* m_pDbConfig;

    QVariantMap lastCreated();
};

#endif /* USERSSERVICE_HPP_ */
