/*
 * PushNotificationService.hpp
 *
 *  Created on: Feb 5, 2017
 *      Author: misha
 */

#ifndef PUSHNOTIFICATIONSERVICE_HPP_
#define PUSHNOTIFICATIONSERVICE_HPP_

#include <bb/network/PushService>
#include <bb/network/PushStatus>
#include <qt4/QtNetwork/QNetworkAccessManager>
#include <qt4/QtNetwork/QNetworkRequest>

using namespace bb::network;

// This needs to match the invoke target specified in bar-descriptor.xml
// The Invoke target key for receiving new push notifications
#define INVOKE_TARGET_KEY_PUSH "chachkouski.DontForget.invoke.push"

// This needs to match the invoke target specified in bar-descriptor.xml
// The Invoke target key when selecting a notification in the BlackBerry Hub
#define INVOKE_TARGET_KEY_OPEN "chachkouski.DontForget.invoke.open"

#define PUSH_SERVICE_REGISTERED "push_service_registered"
#define BLACKBERRY_PUSH_BOUNDARY "asdfglkjhqwert"

class PushNotificationService: public QObject {
    Q_OBJECT
public:
    PushNotificationService(QObject* parent = 0);
    virtual ~PushNotificationService();

    void initPushService();
    PushService* getPushService();

    Q_INVOKABLE void pushMessageToUser(const QString &userPin, const int priority, const QString &title, const QString &body);
    Q_INVOKABLE void pushMessageToUserList(const int priority, const QString &title, const QString &body);
    Q_INVOKABLE void requestSubscribedUserList();

private Q_SLOTS:
    void createSessionCompleted(const bb::network::PushStatus& pushStatus);
    void createChannelCompleted(const bb::network::PushStatus& pushStatus, const QString& token);
    void pushMessageResponse(QNetworkReply* reply);
    void subscriptionQueryResponse(QNetworkReply* reply);

private:
    PushService* m_pPushService;
    QNetworkAccessManager networkAccessManager;

    QString readFile(const QString& fileName);
    void pushMessageToSpecifiedUsers(const QString &papFormattedAddresses, const int priority, const QString &title, const QString &body);
    QNetworkRequest generateBasicNetworkRequest(const QString & urlSuffix);
    void generatePushMessagePostData(QString& templateFileData, const QString &address, const QString &pushData);
    void generateSubscriptionQueryPostData(QString& templateFileData);
    void populateAddresses(QString& addressList);
    void generatePushMessage(QString& pushMessage, const int priority, const QString &title, const QString &body);
    void papFormatAddress(QString &address);
    void log(const QString& message);
};

#endif /* PUSHNOTIFICATIONSERVICE_HPP_ */
