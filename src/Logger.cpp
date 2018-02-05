/*
 * Logger.cpp
 *
 *  Created on: Aug 24, 2017
 *      Author: misha
 */

#include <src/Logger.hpp>
#include <QDebug>
#include <QDateTime>

Logger::Logger(const QString& clazz, QObject* parent) : QObject(parent), m_class(clazz) {}

Logger::~Logger() {}

Logger::Logger(const Logger& logger) : QObject(logger.parent()) {
    m_class = logger.getClass();
}

Logger Logger::getLogger(const QString& clazz) {
    Logger logger(clazz);
    return logger;
}

const QString& Logger::getClass() const {
    return m_class;
}

QString Logger::currDateString() {
    return QDateTime::currentDateTime().toString(Qt::SystemLocaleShortDate);
}
