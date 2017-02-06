/*
 * AppConfig.cpp
 *
 *  Created on: Jan 17, 2017
 *      Author: misha
 */

#include "AppConfig.hpp"
#include <QtCore/QSettings>

bool AppConfig::USING_PUBLIC_PPG = true;
QString AppConfig::PROVIDER_APP_ID = "300065-910B145627tryr34c5425h82824k3s724";
QString AppConfig::PPG_URL = "http://cp300065.pushapi.eval.blackberry.com";
bool AppConfig::LAUNCH_APP_ON_PUSH = true;

AppConfig::AppConfig(QObject* parent) : QObject(parent) {}

AppConfig::~AppConfig() {}

QVariant AppConfig::getStatic(const QString name) {
    QSettings conf;
    return conf.value(name, "");
}

void AppConfig::setStatic(const QString name, const QVariant value) {
    QSettings conf;
    conf.setValue(name, value);
}

QVariant AppConfig::get(const QString name) const {
    return getStatic(name);
}

void AppConfig::set(const QString name, const QVariant value) {
    setStatic(name, value);
}

bool AppConfig::isUsingPublicPushProxyGateway() const { return USING_PUBLIC_PPG; }
const QString& AppConfig::getProviderApplicationId() const { return PROVIDER_APP_ID; }
const QString& AppConfig::getPpgUrl() const { return PPG_URL; }
bool AppConfig::shouldLaunchApplicationOnPush() const { return LAUNCH_APP_ON_PUSH; }

