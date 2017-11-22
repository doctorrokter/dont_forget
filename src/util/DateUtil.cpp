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
#define DATE_FORMAT_2 "ddd dd, MMM yyyy, hh:mm"
#define DATE_FORMAT_3 "MMM dd, hh:mm"
#define DATE_FORMAT_4 "MMM dd, yyyy, hh:mm"
#define DATE_FORMAT_5 "MMM dd, ddd yyyy, hh:mm"
#define DATE_FORMAT_6 "MMM dd, ddd, hh:mm"
#define DATE_FORMAT_7 "localized"

DateUtil::DateUtil(QObject* parent) : QObject(parent) {}

DateUtil::~DateUtil() {}

QString DateUtil::str(const QDateTime& dateTime) {
    QString df = AppConfig::getStatic("date_format", "").toString();
    if (df.isEmpty()) {
        return dateTime.toString(DATE_FORMAT);
    }

    if (df.compare(DATE_FORMAT_7) == 0) {
        return dateTime.toString(m_locale.dateTimeFormat(QLocale::ShortFormat));
    }

    return dateTime.toString(df);
}

QString DateUtil::str(const int& timestamp) {
    return str(QDateTime::fromTime_t(timestamp));
}
