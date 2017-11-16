/*
 * Task.hpp
 *
 *  Created on: Jan 22, 2017
 *      Author: misha
 */

#ifndef TASK_HPP_
#define TASK_HPP_

#include <QtCore/QObject>
#include <QList>
#include <QVariantMap>

class Task: public QObject {
    Q_OBJECT
    Q_PROPERTY(int id READ getId WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString description READ getDescription WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString type READ getType WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(int parentId READ getParentId WRITE setParentId NOTIFY parentIdChanged)
    Q_PROPERTY(int deadline READ getDeadline WRITE setDeadline NOTIFY deadlineChanged)
    Q_PROPERTY(bool important READ isImportant WRITE setImportant NOTIFY importantChanged)
    Q_PROPERTY(bool closed READ isClosed WRITE setClosed NOTIFY closedChanged)
    Q_PROPERTY(QString rememberId READ getRememberId WRITE setRememberId NOTIFY rememberIdChanged)
    Q_PROPERTY(int calendarId READ getCalendarId WRITE setCalendarId NOTIFY calendarIdChanged)
    Q_PROPERTY(int accountId READ getAccountId WRITE setAccountId NOTIFY accountIdChanged)
    Q_PROPERTY(int folderId READ getFolderId WRITE setFolderId NOTIFY folderIdChanged)
    Q_PROPERTY(QString color READ getColor WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(QList<Task> children READ getChildren WRITE setChildren NOTIFY childrenChanged)
public:
    Task(QObject* parent = 0);
    Task(const Task& task);
    Task(const QVariantMap& taskMap);
    virtual ~Task();

    bool operator==(const Task& task);
    Task& operator=(const Task& task);

    Q_INVOKABLE int getId() const;
    Q_INVOKABLE void setId(const int id);

    Q_INVOKABLE const QString& getName() const;
    Q_INVOKABLE void setName(const QString& name);

    Q_INVOKABLE const QString& getDescription() const;
    Q_INVOKABLE void setDescription(const QString& description);

    Q_INVOKABLE const QString& getType() const;
    Q_INVOKABLE void setType(const QString& type);

    Q_INVOKABLE int getParentId() const;
    Q_INVOKABLE void setParentId(const int parentId);

    Q_INVOKABLE int getDeadline() const;
    Q_INVOKABLE void setDeadline(const int deadline);

    Q_INVOKABLE bool isImportant() const;
    Q_INVOKABLE void setImportant(const bool important);

    Q_INVOKABLE bool isClosed() const;
    Q_INVOKABLE void setClosed(const bool closed);

    Q_INVOKABLE const QString& getRememberId() const;
    Q_INVOKABLE void setRememberId(const QString& rememberId);

    Q_INVOKABLE int getCalendarId() const;
    Q_INVOKABLE void setCalendarId(const int calendarId);

    Q_INVOKABLE int getAccountId() const;
    Q_INVOKABLE void setAccountId(const int accountId);

    Q_INVOKABLE int getFolderId() const;
    Q_INVOKABLE void setFolderId(const int folderId);

    Q_INVOKABLE const QString& getColor() const;
    Q_INVOKABLE void setColor(const QString& color);

    Q_INVOKABLE const QList<Task>& getChildren() const;
    Q_INVOKABLE void setChildren(const QList<Task>& children);

    Q_INVOKABLE QVariantMap toMap() const;
    Q_INVOKABLE QVariantMap toJson() const;
    Q_INVOKABLE void fromMap(const QVariantMap taskMap);

    Q_INVOKABLE void addChild(Task& task);

Q_SIGNALS:
    void idChanged(const int id);
    void nameChanged(const QString& name);
    void descriptionChanged(const QString& description);
    void typeChanged(const QString& type);
    void parentIdChanged(const int parentId);
    void deadlineChanged(const int deadline);
    void importantChanged(const bool important);
    void closedChanged(const bool closed);
    void rememberIdChanged(const QString& rememberId);
    void calendarIdChanged(const int calendarId);
    void accountIdChanged(const int accountId);
    void folderIdChanged(const int folderId);
    void colorChanged(const QString& color);
    void childrenChanged(const QList<Task>& children);

private:
    int m_id;
    QString m_name;
    QString m_description;
    QString m_type;
    int m_parentId;
    int m_deadline;
    bool m_important;
    bool m_closed;
    QString m_rememberId;
    int m_calendarId;
    int m_accountId;
    int m_folderId;
    QString m_color;
    QList<Task> m_children;

    void swap(const Task& task);
};

#endif /* TASK_HPP_ */
