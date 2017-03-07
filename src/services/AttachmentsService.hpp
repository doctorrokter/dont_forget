/*
 * AttachmentsService.hpp
 *
 *  Created on: Mar 3, 2017
 *      Author: misha
 */

#ifndef ATTACHMENTSSERVICE_HPP_
#define ATTACHMENTSSERVICE_HPP_

#include <QtCore/QObject>
#include <QVariantList>
#include <QVariantMap>
#include "../config/DBConfig.hpp"

class AttachmentsService: public QObject {
    Q_OBJECT
public:
    AttachmentsService(QObject* parent = 0, DBConfig* dbConfig = 0);
    virtual ~AttachmentsService();

    Q_INVOKABLE QVariantList findAll();
    Q_INVOKABLE QVariantMap findById(const int id);
    Q_INVOKABLE QVariantList findByTaskId(const int taskId);

    Q_INVOKABLE void add(const int taskid, const QString& name, const QString& path, const QString& mimeType);
    Q_INVOKABLE void remove(const int id = 0);

    Q_INVOKABLE void showAttachment(const QString& uri, const QString& mimeType);
    Q_INVOKABLE QString getExtension(const QString& path);
    Q_INVOKABLE QString getIconBig(const QString& ext, const QString& mimeType = "");
    Q_INVOKABLE QVariantMap getIconColorMap(const QString& ext, const QString& mimeType = "");

Q_SIGNALS:
    void attachmentAdded(const QVariantMap attachment);
    void attachmentRemoved(const int id);

private:
    DBConfig* m_pDbConfig;
    QStringList m_docList;
    QStringList m_xlsList;
    QStringList m_pptList;

    QVariantMap lastCreated();
    bool hasExtension(const QStringList& extenstions, const QString& ext);
};

#endif /* ATTACHMENTSSERVICE_HPP_ */
