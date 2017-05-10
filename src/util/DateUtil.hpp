/*
 * DateUtil.hpp
 *
 *  Created on: May 7, 2017
 *      Author: misha
 */

#ifndef DATEUTIL_HPP_
#define DATEUTIL_HPP_

#include <QObject>
#include <QLocale>
#include <QDateTime>

class DateUtil: public QObject {
    Q_OBJECT
public:
    DateUtil(QObject* parent = 0);
    virtual ~DateUtil();

    Q_INVOKABLE QString str(const QDateTime& dateTime);
    Q_INVOKABLE QString str(const int& timestamp);

private:
    QLocale m_locale;
};

#endif /* DATEUTIL_HPP_ */
