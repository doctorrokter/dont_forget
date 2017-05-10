/*
 * AppConfig.cpp
 *
 *  Created on: Jan 17, 2017
 *      Author: misha
 */

#include "AppConfig.hpp"
#include <QUrl>
#include <QDir>
#include <QDebug>

bool AppConfig::USING_PUBLIC_PPG = true;
//QString AppConfig::PROVIDER_APP_ID = "300065-910B145627tryr34c5425h82824k3s724";
//QString AppConfig::PPG_URL = "http://cp300065.pushapi.eval.blackberry.com";
//QString AppConfig::PUSH_URL = "https://cp300065.pushapi.eval.blackberry.com";
//QString AppConfig::PUSH_PASSWORD = "nr2rA2W7";
QString AppConfig::PROVIDER_APP_ID = "1400-la83B532433iO13y8508o50c3a106a20s92";
QString AppConfig::PPG_URL = "http://cp1400.pushapi.na.blackberry.com";
QString AppConfig::PUSH_URL = "https://cp1400.pushapi.na.blackberry.com";
QString AppConfig::PUSH_PASSWORD = "6rDQacwP";
bool AppConfig::LAUNCH_APP_ON_PUSH = true;
QSettings AppConfig::CONF;
bool AppConfig::isOnline = false;

AppConfig::AppConfig(QObject* parent) : QObject(parent), m_pNetworkConf(new QNetworkConfigurationManager()) {
    isOnline = m_pNetworkConf->isOnline();

    bool res = connect(m_pNetworkConf, SIGNAL(onlineStateChanged(bool)), this, SLOT(onOnlineStatusChanged(bool)));
    Q_ASSERT(res);
    Q_UNUSED(res);

    m_publicAssetsPath = QUrl("file://" + QDir::currentPath() + "/app/public").toString();
}

AppConfig::~AppConfig() {
    delete m_pNetworkConf;
    m_pNetworkConf = NULL;
}

QVariant AppConfig::getStatic(const QString name) {
    return CONF.value(name, "");
}

void AppConfig::setStatic(const QString name, const QVariant value) {
    CONF.setValue(name, value);
}

bool AppConfig::hasNetworkStatic() { return isOnline; }

QVariant AppConfig::get(const QString name) const {
    return getStatic(name);
}

void AppConfig::set(const QString name, const QVariant value) {
    setStatic(name, value);
    emit settingsChanged();
}

bool AppConfig::isUsingPublicPushProxyGateway() const { return USING_PUBLIC_PPG; }
const QString& AppConfig::getProviderApplicationId() const { return PROVIDER_APP_ID; }
const QString& AppConfig::getPpgUrl() const { return PPG_URL; }
bool AppConfig::shouldLaunchApplicationOnPush() const { return LAUNCH_APP_ON_PUSH; }
bool AppConfig::hasNetwork() { return hasNetworkStatic(); }

void AppConfig::onOnlineStatusChanged(bool onlineStatus) {
    isOnline = onlineStatus;
}

QString AppConfig::getPublicAssets() const { return m_publicAssetsPath; }
