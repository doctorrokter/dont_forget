/*
 * AppConfig.hpp
 *
 *  Created on: Jan 17, 2017
 *      Author: misha
 */

#ifndef APPCONFIG_HPP_
#define APPCONFIG_HPP_

#include <QtCore/QObject>
#include <QVariant>
#include <QtCore/QSettings>
#include <QtNetwork/QNetworkConfigurationManager>

class AppConfig: public QObject {
    Q_OBJECT
    Q_PROPERTY(bool usingPublicPushProxyGateway READ isUsingPublicPushProxyGateway)
    Q_PROPERTY(QString providerApplicationId READ getProviderApplicationId)
    Q_PROPERTY(QString ppgUrl READ getPpgUrl)
    Q_PROPERTY(bool launchApplicationOnPush READ shouldLaunchApplicationOnPush)
    Q_PROPERTY(QString publicAssets READ getPublicAssets)

public:
    AppConfig(QObject* parent = 0);
    virtual ~AppConfig();

    static bool USING_PUBLIC_PPG;
    static QString PROVIDER_APP_ID;
    static QString PPG_URL;
    static QString PUSH_URL;
    static QString PUSH_PASSWORD;
    static bool LAUNCH_APP_ON_PUSH;
    static QSettings CONF;
    static bool isOnline;

    static QVariant getStatic(const QString name);
    static void setStatic(const QString name, const QVariant value);
    static bool hasNetworkStatic();

    Q_INVOKABLE QVariant get(const QString name) const;
    Q_INVOKABLE void set(const QString name, const QVariant value);

    Q_INVOKABLE bool isUsingPublicPushProxyGateway() const;
    Q_INVOKABLE const QString& getProviderApplicationId() const;
    Q_INVOKABLE const QString& getPpgUrl() const;
    Q_INVOKABLE bool shouldLaunchApplicationOnPush() const;

    Q_INVOKABLE bool hasNetwork();

    Q_INVOKABLE QString getPublicAssets() const;

private Q_SLOTS:
    void onOnlineStatusChanged(bool isOnline);

private:
    QNetworkConfigurationManager* m_pNetworkConf;
    QString m_publicAssetsPath;
};

#endif /* APPCONFIG_HPP_ */
