/*
 * Calendar.hpp
 *
 *  Created on: Jan 21, 2017
 *      Author: misha
 */

#ifndef CALENDARUTIL_HPP_
#define CALENDARUTIL_HPP_

#include <QtCore/QObject>
#include <bb/pim/calendar/CalendarService>
#include <bb/pim/calendar/CalendarEvent>
#include <bb/pim/calendar/Result>
#include <bb/cascades/DropDown>
#include <bb/cascades/Option>

using namespace bb::cascades;
using namespace bb::pim::calendar;

class CalendarUtil: public QObject {
    Q_OBJECT
public:
    CalendarUtil(QObject* parent = 0);
    virtual ~CalendarUtil();

    Q_INVOKABLE CalendarEvent createEvent(const QString& name, const QString& body, QDateTime dateTime, const int folderId, const int accountId);
    Q_INVOKABLE CalendarEvent updateEvent(const int id, const QString& name, const QString& body, QDateTime dateTime, const int folderId, const int accountId);
    Q_INVOKABLE void deleteEvent(const int id, const int folderId, const int accountId);
    Q_INVOKABLE CalendarEvent findEventById(const int id, const int folderId, const int accountId);
    Q_INVOKABLE void initFolders(bb::cascades::DropDown* dropDown, const int folderId = 1, const int accountId = 1);

Q_SIGNALS:
    void eventCreated();
    void eventUpdated();
    void eventDeleted();

private:
    CalendarService* m_pCalendarService;
};

#endif /* CALENDARUTIL_HPP_ */
