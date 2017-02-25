/*
 * Calendar.hpp
 *
 *  Created on: Jan 21, 2017
 *      Author: misha
 */

#ifndef CALENDAR_HPP_
#define CALENDAR_HPP_

#include <QtCore/QObject>
#include <bb/pim/calendar/CalendarService>

using namespace bb::pim::calendar;

class Calendar: public QObject {
    Q_OBJECT
public:
    Calendar(QObject* parent = 0);
    virtual ~Calendar();

    Q_INVOKABLE void createEvent(const QString& name, const QString& body, QDateTime dateTime);

Q_SIGNALS:
    void eventCreated();

private:
    CalendarService* m_pCalendarService;
};

#endif /* CALENDAR_HPP_ */
