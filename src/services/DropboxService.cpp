/*
 * DropboxService.cpp
 *
 *  Created on: Feb 19, 2017
 *      Author: misha
 */

#include <src/services/DropboxService.hpp>
#include <iostream>
#include <bb/data/JsonDataAccess>
#include <QVariant>
#include <QVariantMap>

using namespace std;
using namespace bb::data;

#define DROPBOX_AUTH_KEY "Bearer ABVarbjJ4gAAAAAAAAAACQfIN4KTdGY0DLeJdC_GPx6S1DUV6OrqzYJNW11Sl3rY"

DropboxService::DropboxService(QObject* parent) : QObject(parent), m_pNetworkManager(0) {
    bool res = QObject::connect(this, SIGNAL(fileUploaded(const QString&)), this, SLOT(createTempLink(const QString&)));
    Q_ASSERT(res);
    Q_UNUSED(res);
}

DropboxService::~DropboxService() {
    delete m_pNetworkManager;
    m_pNetworkManager = NULL;
}

void DropboxService::uploadFile(const QString& fileName, const QString& dataToUpload) {
    QNetworkRequest request = QNetworkRequest();
    request.setUrl(QUrl("https://content.dropboxapi.com/2/files/upload"));
    request.setRawHeader("Content-type", "application/octet-stream");
    request.setRawHeader("Authorization", DROPBOX_AUTH_KEY);

    QString drpApiArgStr = QString::fromLatin1("{\"path\":\"/").append(fileName).append("\"}");
    QByteArray drpApiArg;
    drpApiArg.append(drpApiArgStr);
    request.setRawHeader("Dropbox-API-Arg", drpApiArg);

    QByteArray data;
    data.append(dataToUpload.toUtf8());

    m_pNetworkManager = new QNetworkAccessManager(this);

    bool res = QObject::connect(m_pNetworkManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(processFileUpload(QNetworkReply*)));
    Q_ASSERT(res);
    Q_UNUSED(res);

    m_pNetworkManager->post(request, data);
}

void DropboxService::processFileUpload(QNetworkReply* reply) {
    clear();
    if (reply != NULL && reply->bytesAvailable() > 0 && reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        QString dataStr = QString::fromUtf8(data.data());

        cout << dataStr.toStdString() << endl;

        JsonDataAccess jsonResponse;
        QVariant rawData = jsonResponse.loadFromBuffer(dataStr);
        if (!jsonResponse.hasError()) {
            QVariantMap dataMap = rawData.toMap();
            emit fileUploaded(dataMap.value("path_display").toString());
        } else {
            cout << "JSON error" << endl;
        }
    } else {
        cout << reply->errorString().toStdString() << endl;
    }
}

void DropboxService::createTempLink(const QString& path) {
    QNetworkRequest request = QNetworkRequest();
    request.setUrl(QUrl("https://api.dropboxapi.com/2/files/get_temporary_link"));
    request.setRawHeader("Content-type", "application/json");
    request.setRawHeader("Authorization", DROPBOX_AUTH_KEY);

    QString data = QString::fromLatin1("{\"path\":\"").append(path).append("\"}");
    QByteArray bytes;
    bytes.append(data);

    m_pNetworkManager = new QNetworkAccessManager(this);

    bool res = QObject::connect(m_pNetworkManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(processTempLink(QNetworkReply*)));
    Q_ASSERT(res);
    Q_UNUSED(res);

    m_pNetworkManager->post(request, bytes);
}

void DropboxService::processTempLink(QNetworkReply* reply) {
    clear();
    if (reply != NULL && reply->bytesAvailable() > 0 && reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        QString dataStr = QString::fromUtf8(data.data());
        emit tempLinkCreated(dataStr);
    } else {
        cout << reply->errorString().toStdString() << endl;
    }
}

void DropboxService::loadFile(const QString& tempLink) {
    QNetworkRequest request = QNetworkRequest();
    request.setUrl(QUrl(tempLink));

    m_pNetworkManager = new QNetworkAccessManager(this);
    bool res = QObject::connect(m_pNetworkManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(processLoadingFile(QNetworkReply*)));
    Q_ASSERT(res);
    Q_UNUSED(res);

    m_pNetworkManager->get(request);
}

void DropboxService::processLoadingFile(QNetworkReply* reply) {
    clear();
    if (reply != NULL && reply->bytesAvailable() > 0 && reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        QString dataStr = QString::fromUtf8(data.data());
        emit fileLoaded(dataStr);
    } else {
        cout << "ERROR READING FILE!!! " << reply->errorString().toStdString() << endl;
    }
}

void DropboxService::clear() {
    m_pNetworkManager->deleteLater();
}
