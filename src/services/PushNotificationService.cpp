/*
 * PushNotificationService.cpp
 *
 *  Created on: Feb 5, 2017
 *      Author: misha
 */

#include "PushNotificationService.hpp"
#include "../config/AppConfig.hpp"
#include <QUrl>
#include <QFile>
#include <QVariantList>
#include <QUuid>
#include <QSettings>
#include <qt4/QtNetwork/QNetworkReply>
#include <QtXml/QDomDocument>
#include <QtXml/QDomNodeList>

using namespace bb::network;

PushNotificationService::PushNotificationService(QObject* parent) : QObject(parent), m_pPushService(0) {}

PushNotificationService::~PushNotificationService() {
    delete m_pPushService;
    m_pPushService = NULL;
}

void PushNotificationService::initPushService() {
    if (!m_pPushService) {
        m_pPushService = new PushService(AppConfig::PROVIDER_APP_ID, INVOKE_TARGET_KEY_PUSH, this);

        connect(m_pPushService, SIGNAL(createSessionCompleted(const bb::network::PushStatus&)), this, SLOT(createSessionCompleted(const bb::network::PushStatus&)));
        connect(m_pPushService, SIGNAL(createChannelCompleted(const bb::network::PushStatus&, const QString&)), this, SLOT(createChannelCompleted(const bb::network::PushStatus&, const QString&)));

        m_pPushService->createSession();
    }
}

PushService* PushNotificationService::getPushService() { return m_pPushService; }

void PushNotificationService::createSessionCompleted(const PushStatus& pushStatus) {
    if (!pushStatus.isError() && m_pPushService) {
        qDebug() << "Session creation completed successfully!" << endl;

        bool pushServiceRegisterd = AppConfig::getStatic(PUSH_SERVICE_REGISTERED).toBool();
        if (!pushServiceRegisterd) {
            qDebug() << "Push Service not registered yet." << endl;

            m_pPushService->createChannel(QUrl(AppConfig::PPG_URL));
            AppConfig::setStatic(PUSH_SERVICE_REGISTERED, true);
        } else {
            qDebug() << "Push Service already registered. Use one." << endl;
        }
    } else {
        qDebug() << pushStatus.errorDescription() << endl;
    }
}
void PushNotificationService::createChannelCompleted(const PushStatus& pushStatus, const QString& token) {
    Q_UNUSED(token);
    if (!pushStatus.isError() && m_pPushService) {
        qDebug() << "Push Service registered succsessfully!" << endl;

        if (AppConfig::LAUNCH_APP_ON_PUSH) {
            m_pPushService->registerToLaunch();
        }
    } else {
        qDebug() << pushStatus.errorDescription() << endl;
    }
}

void PushNotificationService::pushMessageToUser(const QString &userPin, const int priority, const QString &title, const QString &body) {
    QString papFormattedAddress = QString(userPin);
    papFormatAddress(papFormattedAddress);
    pushMessageToSpecifiedUsers(papFormattedAddress, priority, title, body);
}

/**
 * Push a message to all users known to the app (stored in QSettings). This
 * method will retrieve all users stored then add them to a QString and request
 * the message be sent.
 */
void PushNotificationService::pushMessageToUserList(const int priority, const QString &title, const QString &body) {
    QString papFormattedAddresses;
    populateAddresses(papFormattedAddresses);
    pushMessageToSpecifiedUsers(papFormattedAddresses, priority, title, body);
}

/**
 * Both pushMessageToUser() and pushMessageToUserList() will call this method
 *
 */
void PushNotificationService::pushMessageToSpecifiedUsers(const QString &papFormattedAddresses, const int priority, const QString &title, const QString &body) {
    QString pushMessage;
    generatePushMessage(pushMessage, priority, title, body);

    disconnect(&networkAccessManager, 0, 0, 0);
    connect(&networkAccessManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(pushMessageResponse(QNetworkReply*)));

    QNetworkRequest networkRequest = generateBasicNetworkRequest("mss/PD_pushRequest");
    networkRequest.setRawHeader("Content-Type",
            QString("multipart/related; type=\"application/xml\"; boundary=").append(BLACKBERRY_PUSH_BOUNDARY).toAscii());

    QString postData = readFile("pap_push.template");
    generatePushMessagePostData(postData, papFormattedAddresses, pushMessage);
    networkAccessManager.post(networkRequest, postData.toUtf8());
    qDebug() << postData;
}

void PushNotificationService::requestSubscribedUserList() {
    disconnect(&networkAccessManager, 0, 0, 0);
    connect(&networkAccessManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(subscriptionQueryResponse(QNetworkReply*)));

    QNetworkRequest networkRequest = generateBasicNetworkRequest("mss/PD_cpSubQuery");
    networkRequest.setRawHeader("Content-Type", QString("application/xml").toAscii());

    QString postData = readFile("pap_subscription.template");
    generateSubscriptionQueryPostData(postData);
    networkAccessManager.post(networkRequest, postData.toUtf8());
    qDebug() << postData;
}

QNetworkRequest PushNotificationService::generateBasicNetworkRequest(const QString & urlSuffix) {
    QNetworkRequest networkRequest;
    networkRequest.setUrl(QUrl(AppConfig::PPG_URL + "/" + urlSuffix));
    QString login = QString("%1:%2").arg(AppConfig::PROVIDER_APP_ID).arg(AppConfig::PUSH_PASSWORD);
    QByteArray encoded = login.toAscii().toBase64();
    networkRequest.setRawHeader("Authorization", "Basic " + encoded);
    return networkRequest;
}

QString PushNotificationService::readFile(const QString& fileName) {
    QFile file("app/native/assets/templates/" + fileName);
    file.open(QIODevice::ReadOnly);
    QByteArray toPost = file.readAll();
    return toPost;
}

void PushNotificationService::generatePushMessagePostData(QString& templateFileData, const QString &address, const QString &pushData) {
    templateFileData.replace("$(boundary)", BLACKBERRY_PUSH_BOUNDARY);
    templateFileData.replace("$(pushid)", QUuid::createUuid().toString().right(18).left(17));
    templateFileData.replace("$(username)", AppConfig::PROVIDER_APP_ID);
    templateFileData.replace("$(addresses)", address);
    templateFileData.replace("$(deliveryMethod)", "unconfirmed");
    templateFileData.replace("$(headers)", "Content-Type: text/plain");
    templateFileData.replace("$(content)", pushData);
    templateFileData.replace("\r\n", "EOL");
    templateFileData.replace("\n", "EOL");
    templateFileData.replace("EOL", "\r\n");
}

void PushNotificationService::generateSubscriptionQueryPostData(QString& templateFileData) {
    templateFileData.replace("$(username)", AppConfig::PROVIDER_APP_ID);
    templateFileData.replace("\r\n", "EOL");
    templateFileData.replace("\n", "EOL");
    templateFileData.replace("EOL", "\r\n");
}

void PushNotificationService::populateAddresses(QString& papFormattedAddresses) {
    QSettings settings;
    QVariant temp = settings.value("pins");
    QString tempAddr;
    if (!temp.isNull()) {
        QVariantList addressList = temp.toList();
        foreach(QVariant address, addressList){
        tempAddr = QString(address.toString());
        papFormatAddress(tempAddr);
        papFormattedAddresses.append(tempAddr);
    }
}
}

void PushNotificationService::papFormatAddress(QString &address) {
    address = QString("<address address-value=\"%1\"/>\r\n").arg(address);
}

void PushNotificationService::generatePushMessage(QString& pushMessage, const int priority, const QString &title, const QString &body) {
    Q_UNUSED(priority);
    Q_UNUSED(title);
    pushMessage = QString("{\"body\": %1}").arg(body);
}

void PushNotificationService::log(const QString& message) {
    qDebug() << message << endl;
}

void PushNotificationService::pushMessageResponse(QNetworkReply* reply) {
    if (reply->error() == QNetworkReply::NoError) {
        log("Push response: \n" + reply->readAll());
    } else {
        log("Failed to send Push: \n" + reply->errorString());
    }
}

void PushNotificationService::subscriptionQueryResponse(QNetworkReply* reply) {
    if (reply->error() == QNetworkReply::NoError) {
        QDomDocument doc;
        doc.setContent(reply->readAll());
        QDomNodeList list = doc.elementsByTagName("address");
        QVariantList pinList;
        QString listOfPins;
        for (int i = 0; i < list.size(); ++i) {
            pinList << list.at(i).toElement().attribute("address-value");
            listOfPins.append(
                    list.at(i).toElement().attribute("address-value") + "\n");
        }

        log(QString("PINs received: %1\n%2").arg(list.size()).arg(listOfPins));

        QSettings settings;
        settings.clear();
        settings.setValue("pins", pinList);
    } else {
        log("Failed to receive PINs: \n" + reply->errorString());
    }
}
