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

Q_SIGNALS:
    void attachmentAdded(const QVariantMap attachment);
    void attachmentRemoved(const int id);

private:
    DBConfig* m_pDbConfig;

    QVariantMap lastCreated();
};

#endif /* ATTACHMENTSSERVICE_HPP_ */
