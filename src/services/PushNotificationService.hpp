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

using namespace bb::network;

// This needs to match the invoke target specified in bar-descriptor.xml
// The Invoke target key for receiving new push notifications
#define INVOKE_TARGET_KEY_PUSH "chachkouski.DontForget.invoke.push"

// This needs to match the invoke target specified in bar-descriptor.xml
// The Invoke target key when selecting a notification in the BlackBerry Hub
#define INVOKE_TARGET_KEY_OPEN "chachkouski.DontForget.invoke.open"

#define PUSH_SERVICE_REGISTERED "push_service_registered"

class PushNotificationService: public QObject {
    Q_OBJECT
public:
    PushNotificationService(QObject* parent = 0);
    virtual ~PushNotificationService();

    void initPushService();
    PushService* getPushService();

private Q_SLOTS:
    void createSessionCompleted(const PushStatus& pushStatus);
    void createChannelCompleted(const PushStatus& pushStatus, const QString& token);

private:
    PushService* m_pPushService;
};

#endif /* PUSHNOTIFICATIONSERVICE_HPP_ */
