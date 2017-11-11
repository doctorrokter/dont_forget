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

void Logger::info(const QString& message) {
    qDebug() << "[INFO]" << "[" << currDateString() << "] -" << m_class << "-" << message << endl;
}

void Logger::info(const QUrl& url) {
    qDebug() << "[INFO]" << "[" << currDateString() << "] -" << m_class << "-" << url << endl;
}

void Logger::info(const QVariantMap& map) {
    qDebug() << "[INFO]" << "[" << currDateString() << "] -" << m_class << "-" << map << endl;
}

void Logger::info(const QVariantList& list) {
    qDebug() << "[INFO]" << "[" << currDateString() << "] -" << m_class << "-" << list << endl;
}

void Logger::info(const QList<int>& list) {
    qDebug() << "[INFO]" << "[" << currDateString() << "] -" << m_class << "-" << list << endl;
}

void Logger::error(const QNetworkReply::NetworkError e) {
    qDebug() << "[ERROR]" << "[" << currDateString() << "] -" << m_class << "-" << e << endl;
}

void Logger::error(const QString& error) {
    qDebug() << "[ERROR]" << "[" << currDateString() << "] -" << m_class << "-" << error << endl;
}

QString Logger::currDateString() {
    return QDateTime::currentDateTime().toString(Qt::SystemLocaleShortDate);
}

