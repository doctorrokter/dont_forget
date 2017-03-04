/*
 * AttachmentsService.cpp
 *
 *  Created on: Mar 3, 2017
 *      Author: misha
 */

#include <src/services/AttachmentsService.hpp>

AttachmentsService::AttachmentsService(QObject* parent, DBConfig* dbConfig) : QObject(parent), m_pDbConfig(dbConfig) {}

AttachmentsService::~AttachmentsService() {
    delete m_pDbConfig;
    m_pDbConfig = NULL;
}

QVariantList AttachmentsService::findAll() {
    return m_pDbConfig->connection()->execute("SELECT * FROM attachments").toList();
}

QVariantMap AttachmentsService::findById(const int id) {
    QVariantList res = m_pDbConfig->connection()->execute(QString::fromLatin1("SELECT * FROM attachments WHERE id = %1").arg(id)).toList();
    if (res.isEmpty()) {
        return QVariantMap();
    }
    return res.at(0).toMap();
}

QVariantList AttachmentsService::findByTaskId(const int taskId) {
    return m_pDbConfig->connection()->execute(QString::fromLatin1("SELECT * FROM attachments WHERE task_id = %1").arg(taskId)).toList();
}

void AttachmentsService::add(const int taskid, const QString& name, const QString& path, const QString& mimeType) {
    QString query = "INSERT INTO attachments (task_id, name, path, mime_type) VALUES (:task_id, :name, :path, :mime_type)";

    QVariantMap values;
    values.insert("task_id", taskid);
    values.insert("name", name);
    values.insert("path", path);
    values.insert("mime_type", mimeType);

    m_pDbConfig->connection()->execute(query, values);
    emit attachmentAdded(lastCreated());
    // TODO: copy file to app folder
}

void AttachmentsService::remove(const int id) {
    if (id != 0) {
        m_pDbConfig->connection()->execute(QString::fromLatin1("DELETE FROM attachments WHERE id = %1").arg(id));
        // TODO: remove file from app folder
    }
    emit attachmentRemoved(id);
}

QVariantMap AttachmentsService::lastCreated() {
    return m_pDbConfig->connection()->execute("SELECT * FROM attachments ORDER BY id DESC LIMIT 1").toList().at(0).toMap();
}
