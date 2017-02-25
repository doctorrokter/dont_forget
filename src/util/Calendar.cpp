/*
 * Calendar.cpp
 *
 *  Created on: Jan 21, 2017
 *      Author: misha
 */

#include "Calendar.hpp"
#include <bb/pim/calendar/CalendarEvent>
#include <bb/pim/calendar/Recurrence>

Calendar::Calendar(QObject* parent) :QObject(parent), m_pCalendarService(new CalendarService()) {}

Calendar::~Calendar() {
    delete m_pCalendarService;
    m_pCalendarService = NULL;
}

void Calendar::createEvent(const QString& name, const QString& body, QDateTime dateTime) {
    CalendarEvent ev;
    ev.setAccountId(1);
    ev.setFolderId(1);
    ev.setStartTime(dateTime);
    ev.setEndTime(dateTime.addSecs(3600));
    ev.setReminder(120);
    ev.setSubject(name);
    ev.setBody(body);

    m_pCalendarService->createEvent(ev);

    emit eventCreated();
}

