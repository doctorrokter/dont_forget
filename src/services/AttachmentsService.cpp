/*
 * AttachmentsService.cpp
 *
 *  Created on: Mar 3, 2017
 *      Author: misha
 */

#include <src/services/AttachmentsService.hpp>

#include <bb/system/InvokeRequest>
#include <bb/system/InvokeManager>
#include <QFile>

using namespace bb::system;

AttachmentsService::AttachmentsService(QObject* parent, DBConfig* dbConfig) : QObject(parent), m_pDbConfig(dbConfig) {
    m_docList << "doc" << "dot" << "txt" << "docx" << "dotx" << "docm" << "dotm";
    m_xlsList << "xls" << "xlt" << "xlsx" << "xltx" << "xlsm" << "xltm";
    m_pptList << "ppt" << "pot" << "pps" << "pptx" << "potx" << "ppsx" << "pptm" << "potm" << "ppsm";
}

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

QVariantList AttachmentsService::getEncodedAttachments(const int taskId) {
    QVariantList attachments = findByTaskId(taskId);
    QVariantList encoded;
    foreach(QVariant attVar, attachments) {
        QVariantMap attMap = attVar.toMap();
        QFile att(attMap.value("path").toString().replace("file://", ""));
        bool opened = att.open(QIODevice::ReadOnly);
        if (opened) {
            QByteArray bytes = att.readAll();
            attMap["data"] = QString::fromAscii(bytes.toBase64().data());
            encoded.append(attMap);
        } else {
            qDebug() << "Cannot open a file: " << attMap.value("path").toString() << " " << att.errorString() << endl;
        }
    }
    return encoded;
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
}

void AttachmentsService::remove(const int id) {
    if (id != 0) {
        m_pDbConfig->connection()->execute(QString::fromLatin1("DELETE FROM attachments WHERE id = %1").arg(id));
    }
    emit attachmentRemoved(id);
}

void AttachmentsService::showAttachment(const QString& uri, const QString& mimeType) {
    InvokeManager invokeManager;
    InvokeRequest request;

    QUrl url(uri);

    request.setAction("bb.action.VIEW");
    request.setUri(url);
    request.setMimeType(mimeType);

//    qDebug() << url << mimeType << endl;

    if (mimeType == "application/pdf") {
        request.setTarget("com.rim.bb.app.adobeReader.viewer");
    } else if (mimeType.contains("image/")) {
        request.setTarget("sys.pictures.card.previewer");
    } else if (mimeType.contains("audio/") || mimeType.contains("video/")) {
        request.setTarget("sys.mediaplayer.previewer");
    } else {
        QString ext = getExtension(uri);
        if (hasExtension(m_docList, ext)) {
            request.setTarget("sys.wordtogo.previewer");
        } else if (hasExtension(m_xlsList, ext)) {
            request.setTarget("sys.sheettogo.previewer");
        } else if (hasExtension(m_pptList, ext)) {
            request.setTarget("sys.slideshowtogo.previewer");
        }
    }

    if (!request.target().isEmpty()) {
        invokeManager.invoke(request);
    }
}

QString AttachmentsService::getIconBig(const QString& ext, const QString& mimeType) {
    if (mimeType.contains("audio/")) {
        return "audio_icon_big_512x512.png";
    } else if (mimeType.contains("video/")) {
        return "video_icon_big_512x512.png";
    } else if (mimeType.contains("application/pdf")) {
        return "pdf_icon_big.png";
    } else if (mimeType.contains("application/javascript")) {
        return "js_icon_big_512x512.png";
    } else if (mimeType.contains("application/vnd.android.package-archive")) {
        return "apk_icon_big_512x512.png";
    } else if (mimeType.contains("application/zip")) {
        return "zip_icon_big_512x512.png";
    } else if (hasExtension(m_docList, ext)) {
        return "doc_icon_big_512x512.png";
    } else if (hasExtension(m_xlsList, ext)) {
        return "xls_icon_big_512x512.png";
    } else if (hasExtension(m_pptList, ext)) {
        return "ppt_icon_big_512x512.png";
    }
    return "generic_icon_big_512x512.png";
}

QVariantMap AttachmentsService::getIconColorMap(const QString& ext, const QString& mimeType) {
    QVariantMap map;
    if (mimeType.contains("audio/")) {
        map.insert("image", "ic_doctype_music.png");
        map.insert("color", "#8F3096");
    } else if (mimeType.contains("video/")) {
        map.insert("image", "ic_doctype_video.png");
        map.insert("color", "#FF3333");
    } else if (mimeType.contains("application/pdf")) {
        map.insert("image", "ic_doctype_pdf.png");
        map.insert("color", "#FF3333");
    } else if (hasExtension(m_docList, ext)) {
        map.insert("image", "ic_doctype_doc.png");
        map.insert("color", "#0092CC");
    } else if (hasExtension(m_xlsList, ext)) {
        map.insert("image", "ic_doctype_xls.png");
        map.insert("color", "#779933");
    } else if (hasExtension(m_pptList, ext)) {
        map.insert("image", "ic_doctype_ppt.png");
        map.insert("color", "#FF3333");
    } else {
        map.insert("image", "ic_doctype_generic.png");
        map.insert("color", "#969696");
    }
    return map;
}

QVariantMap AttachmentsService::lastCreated() {
    return m_pDbConfig->connection()->execute("SELECT * FROM attachments ORDER BY id DESC LIMIT 1").toList().at(0).toMap();
}

QString AttachmentsService::getExtension(const QString& path) {
    QStringList parts = path.split(".");
    return parts[parts.length() - 1];
}

bool AttachmentsService::hasExtension(const QStringList& extenstions, const QString& ext) {
    foreach(QString e, extenstions) {
        if (e.compare(ext) == 0) {
            return true;
        }
    }
    return false;
}
