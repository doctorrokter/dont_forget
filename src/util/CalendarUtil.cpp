/*
 * Calendar.cpp
 *
 *  Created on: Jan 21, 2017
 *      Author: misha
 */

#include "CalendarUtil.hpp"
#include <QPair>
#include <bb/pim/calendar/CalendarFolder>

CalendarUtil::CalendarUtil(QObject* parent) :QObject(parent), m_pCalendarService(new CalendarService()) {}

CalendarUtil::~CalendarUtil() {
    m_pCalendarService->deleteLater();
}

CalendarEvent CalendarUtil::createEvent(const QString& name, const QString& body, QDateTime dateTime, const int folderId, const int accountId) {
    CalendarEvent ev;

    ev.setAccountId(accountId);
    ev.setFolderId(folderId);
    ev.setStartTime(dateTime);
    ev.setEndTime(dateTime.addSecs(3600));
    ev.setReminder(120);
    ev.setSubject(name);
    ev.setBody(body);

    m_pCalendarService->createEvent(ev);
    emit eventCreated();
    return ev;
}

CalendarEvent CalendarUtil::updateEvent(const int id, const QString& name, const QString& body, QDateTime dateTime) {
    QPair<AccountId, FolderId> pair = m_pCalendarService->defaultCalendarFolder();
    CalendarEvent ev = m_pCalendarService->event(pair.first, id);
    ev.setStartTime(dateTime);
    ev.setEndTime(dateTime.addSecs(3600));
    ev.setReminder(120);
    ev.setSubject(name);
    ev.setBody(body);
    emit eventUpdated();
    return ev;
}

void CalendarUtil::deleteEvent(const int id) {
    CalendarEvent ev = findEventById(id);
    m_pCalendarService->deleteEvent(ev);
    emit eventDeleted();
}

CalendarEvent CalendarUtil::findEventById(const int id) {
    QPair<AccountId, FolderId> pair = m_pCalendarService->defaultCalendarFolder();
    Result::Type* r = new Result::Type();
    CalendarEvent ev = m_pCalendarService->event(pair.first, id, r);
    return ev;
}

void CalendarUtil::initFolders(DropDown* dropDown, const int folderId, const int accountId) {
    if (!dropDown) {
        return;
    }

    dropDown->removeAll();

    foreach (const CalendarFolder &folder, m_pCalendarService->folders()) {
        if (folder.isReadOnly()) {
            continue;
        }

        Option *option = new Option();
        option->setText(folder.name());

        QVariantMap value;
        int fid = folder.id();
        int aid = folder.accountId();
        value["folderId"] = fid;
        value["accountId"] = aid;
        option->setValue(value);

        if (fid == folderId && aid == accountId) {
            option->setSelected(true);
        }

        dropDown->add(option);
    }
}
