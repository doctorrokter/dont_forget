/*
 * DateUtil.cpp
 *
 *  Created on: May 7, 2017
 *      Author: misha
 */

#include <src/util/DateUtil.hpp>
#include "../config/AppConfig.hpp"
#include <QDebug>

#define DATE_FORMAT "dd.MM.yyyy, hh:mm"

DateUtil::DateUtil(QObject* parent) : QObject(parent) {}

DateUtil::~DateUtil() {}

QString DateUtil::str(const QDateTime& dateTime) {
    QString df = AppConfig::getStatic("date_format").toString();
    if (df.isEmpty() || df.compare(DATE_FORMAT) == 0) {
        return dateTime.toString(DATE_FORMAT);
    }
    return dateTime.toString(m_locale.dateTimeFormat(QLocale::ShortFormat));
}

QString DateUtil::str(const int& timestamp) {
    return str(QDateTime::fromTime_t(timestamp));
}
