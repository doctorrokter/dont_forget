/*
 * AppConfig.cpp
 *
 *  Created on: Jan 17, 2017
 *      Author: misha
 */

#include "AppConfig.hpp"

AppConfig::AppConfig(QObject* parent) : QObject(parent) {}

AppConfig::~AppConfig() {}

QVariant AppConfig::get(const QString name) const {
    return m_appConfig.value(name, "");
}

void AppConfig::set(const QString name, const QVariant value) {
    m_appConfig.setValue(name, value);
}

