/*
 * UsersService.cpp
 *
 *  Created on: Feb 21, 2017
 *      Author: misha
 */

#include <src/services/UsersService.hpp>

UsersService::UsersService(QObject* parent, DBConfig* dbConfig) : QObject(parent), m_pDbConfig(dbConfig) {}

UsersService::~UsersService() {
    delete m_pDbConfig;
    m_pDbConfig = NULL;
}

QVariantList UsersService::findAll() const {
    return m_pDbConfig->connection()->execute("SELECT * FROM df_users").toList();
}

QVariantMap UsersService::findById(const int id) const {
    return m_pDbConfig->connection()->execute(QString::fromLatin1("SELECT * FROM df_users WHERE id = %1").arg(id)).toList().first().toMap();
}

void UsersService::add(const QString& firstName, const QString& lastName, const QString& pin) {
    QString query = "INSERT INTO df_users (first_name, last_name, pin) VALUES (:first_name, :last_name, :pin)";
    QVariantMap values;
    values["first_name"] = firstName;
    values["last_name"] = lastName;
    values["pin"] = pin;
    m_pDbConfig->connection()->execute(query, values);
    emit userAdded(lastCreated());
}

void UsersService::remove(const int id) {
    m_pDbConfig->connection()->execute(QString::fromLatin1("DELETE FROM df_users WHERE id = %1").arg(id));
    emit userRemoved();
}

void UsersService::update(const int id, const QString& firstName, const QString& lastName, const QString& pin) {
    QString query = "UPDATE df_users SET first_name = :first_name, last_name = :last_name, pin = :pin WHERE id = :id";
    QVariantMap values;
    values["first_name"] = firstName;
    values["last_name"] = lastName;
    values["pin"] = pin;
    values["id"] = id;
    m_pDbConfig->connection()->execute(query, values);
    emit userUpdated();
}

QVariantMap UsersService::lastCreated() {
    return m_pDbConfig->connection()->execute("SELECT * FROM df_users ORDER BY id DESC LIMIT 1").toList().at(0).toMap();
}

