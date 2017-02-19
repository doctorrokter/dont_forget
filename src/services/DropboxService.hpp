/*
 * DropboxService.hpp
 *
 *  Created on: Feb 19, 2017
 *      Author: misha
 */

#ifndef DROPBOXSERVICE_HPP_
#define DROPBOXSERVICE_HPP_

#include <QtCore/QObject>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>

class DropboxService: public QObject {
    Q_OBJECT
public:
    DropboxService(QObject* parent = 0);
    virtual ~DropboxService();

    Q_INVOKABLE void uploadFile(const QString& fileName, const QString& dataToUpload);
    Q_INVOKABLE void loadFile(const QString& tempLink);

Q_SIGNALS:
    void fileUploaded(const QString& path);
    void tempLinkCreated(const QString& tempLink);
    void fileLoaded(const QString& fileData);

private Q_SLOTS:
    void processFileUpload(QNetworkReply* reply);
    void createTempLink(const QString& path);
    void processTempLink(QNetworkReply* reply);
    void processLoadingFile(QNetworkReply* reply);

private:
    QNetworkAccessManager* m_pNetworkManager;

    void clear();
};

#endif /* DROPBOXSERVICE_HPP_ */
