/*
 * AppConfig.hpp
 *
 *  Created on: Jan 17, 2017
 *      Author: misha
 */

#ifndef APPCONFIG_HPP_
#define APPCONFIG_HPP_

#include <QtCore/QObject>
#include <QtCore/QSettings>
#include <QVariant>

class AppConfig: public QObject {
    Q_OBJECT

public:
    AppConfig(QObject* parent = 0);
    virtual ~AppConfig();

    Q_INVOKABLE QVariant get(const QString name) const;
    Q_INVOKABLE void set(const QString name, const QVariant value);

private:
    QSettings m_appConfig;
};

#endif /* APPCONFIG_HPP_ */
