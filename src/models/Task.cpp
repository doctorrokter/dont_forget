/*
 * Task.cpp
 *
 *  Created on: Jan 22, 2017
 *      Author: misha
 */

#include "Task.hpp"
#include <QVariantList>

Task::Task(QObject* parent) : QObject(parent), m_id(0), m_name(""), m_description(""), m_type("FOLDER"), m_parentId(0),
    m_deadline(0), m_important(false), m_closed(false), m_expanded(true), m_rememberId(""),
    m_calendarId(0), m_color("") {}

Task::Task(const Task& task) : QObject(task.parent()) {
    if (this != &task) {
        swap(task);
    }
}

Task::Task(const QVariantMap& taskMap) {
    fromMap(taskMap);
}

Task::~Task() {}

bool Task::operator==(const Task& task) {
    return this->getId() == task.getId() && this->getType().compare(task.getType());
}

Task& Task::operator=(const Task& task) {
    swap(task);
    return *this;
}

int Task::getId() const { return m_id; }
void Task::setId(const int id) {
    m_id = id;
    emit idChanged(m_id);
}

const QString& Task::getName() const { return m_name; }
void Task::setName(const QString& name) {
    m_name = name;
    emit nameChanged(m_name);
}

const QString& Task::getDescription() const { return m_description; }
void Task::setDescription(const QString& description) {
    m_description = description;
    emit descriptionChanged(m_description);
}

const QString& Task::getType() const { return m_type; }
void Task::setType(const QString& type) {
    m_type = type;
    emit typeChanged(m_type);
}

int Task::getParentId() const { return m_parentId; }
void Task::setParentId(const int parentId) {
    m_parentId = parentId;
    emit parentIdChanged(m_parentId);
}

int Task::getDeadline() const { return m_deadline; }
void Task::setDeadline(const int deadline) {
    m_deadline = deadline;
    emit deadlineChanged(m_deadline);
}

bool Task::isImportant() const { return m_important; }
void Task::setImportant(const bool important) {
    m_important = important;
    emit importantChanged(m_important);
}

bool Task::isClosed() const { return m_closed; }
void Task::setClosed(const bool closed) {
    m_closed = closed;
    emit closedChanged(m_closed);
}

bool Task::isExpanded() const { return m_expanded; }
void Task::setExpanded(const bool expanded) {
    m_expanded = expanded;
    emit expandedChanged(m_expanded);
}

const QString& Task::getRememberId() const { return m_rememberId; }
void Task::setRememberId(const QString& rememberId) {
    m_rememberId = rememberId;
    emit rememberIdChanged(m_rememberId);
}

int Task::getCalendarId() const { return m_calendarId; }
void Task::setCalendarId(const int calendarId) {
    m_calendarId = calendarId;
    emit calendarIdChanged(m_calendarId);
}

const QString& Task::getColor() const { return m_color; }
void Task::setColor(const QString& color) {
    m_color = color;
    emit colorChanged(m_color);
}

const QList<Task>& Task::getChildren() const { return m_children; }
void Task::setChildren(const QList<Task>& children) {
    m_children = children;
    emit childrenChanged(m_children);
}

void Task::swap(const Task& task) {
    this->setId(task.getId());

    QString name = task.getName();
    this->setName(name);

    QString desc = task.getDescription();
    this->setDescription(desc);

    QString type = task.getType();
    this->setType(type);
    this->setParentId(task.getParentId());
    this->setDeadline(task.getDeadline());
    this->setImportant(task.isImportant());
    this->setClosed(task.isClosed());
    this->setExpanded(task.isExpanded());

    QString rememberId = task.getRememberId();
    this->setRememberId(rememberId);

    this->setCalendarId(task.getCalendarId());

    QList<Task> children = task.getChildren();
    this->setChildren(children);
}

QVariantMap Task::toMap() const {
    QVariantMap map;
    map.insert("id", this->getId());
    map.insert("name", this->getName());
    map.insert("description", this->getDescription());
    map.insert("type", this->getType());
    map.insert("parentId", this->getParentId());
    map.insert("deadline", this->getDeadline());
    map.insert("important", this->isImportant());
    map.insert("closed", this->isClosed());
    map.insert("expanded", this->isExpanded());
    map.insert("rememberId", this->getRememberId());
    map.insert("calendarId", this->getCalendarId());
    map.insert("color", this->getColor());

    QVariantList children;
    for (int i = 0; i < m_children.size(); i++) {
        children.append(m_children.at(i).toMap());
    }
    map.insert("children", children);
    return map;
}

QVariantMap Task::toJson() const {
    QVariantMap map;
    map.insert("id", this->getId());
    map.insert("name", this->getName());
    map.insert("description", this->getDescription());
    map.insert("type", this->getType());
    map.insert("parent_id", this->getParentId());
    map.insert("deadline", this->getDeadline());
    map.insert("important", this->isImportant() ? 1 : 0);
    map.insert("closed", this->isClosed() ? 1 : 0);
    map.insert("expanded", this->isExpanded() ? 1 : 0);
    map.insert("remember_id", this->getRememberId());
    map.insert("calendar_id", this->getCalendarId());
    map.insert("color", this->getColor());
    return map;
}

void Task::fromMap(const QVariantMap taskMap) {
    this->setId(taskMap.value("id").toInt());
    this->setName(taskMap.value("name").toString());
    this->setDescription(taskMap.value("description").toString());
    this->setType(taskMap.value("type").toString());
    this->setParentId(taskMap.value("parent_id").toInt());
    this->setDeadline(taskMap.value("deadline").toInt());
    this->setImportant(taskMap.value("important").toBool());
    this->setClosed(taskMap.value("closed").toBool());
    this->setExpanded(taskMap.value("expanded").toBool());
    this->setRememberId(taskMap.value("remember_id", "").toString());
    this->setCalendarId(taskMap.value("calendar_id", "0").toInt());
    this->setColor(taskMap.value("color", "").toString());
}

void Task::addChild(Task& task) {
    task.setParentId(this->getId());
    m_children.append(task);
}

