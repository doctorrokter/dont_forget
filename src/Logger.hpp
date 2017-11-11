/*
 * Logger.hpp
 *
 *  Created on: Aug 24, 2017
 *      Author: misha
 */

#ifndef LOGGER_HPP_
#define LOGGER_HPP_

#include <QUrl>
#include <QNetworkReply>
#include <QVariantMap>
#include <QVariantList>
#include <QList>

class Logger: public QObject {
    Q_OBJECT
public:
    Logger(const QString& clazz, QObject* parent = 0);
    Logger(const Logger& logger);
    virtual ~Logger();

    static Logger getLogger(const QString& clazz);

    const QString& getClass() const;

    void info(const QString& message);
    void info(const QUrl& url);
    void info(const QVariantMap& map);
    void info(const QVariantList& list);
    void info(const QList<int>& list);
    void error(const QNetworkReply::NetworkError e);
    void error(const QString& error);

private:
    QString m_class;

    QString currDateString();
};

#endif /* LOGGER_HPP_ */
