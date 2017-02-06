/*
 * PushNotificationService.cpp
 *
 *  Created on: Feb 5, 2017
 *      Author: misha
 */

#include "PushNotificationService.hpp"
#include "../config/AppConfig.hpp"
#include <QUrl>

using namespace bb::network;

PushNotificationService::PushNotificationService(QObject* parent) : QObject(parent), m_pPushService(0) {}

PushNotificationService::~PushNotificationService() {}

void PushNotificationService::initPushService() {
    if (!m_pPushService) {
        m_pPushService = new PushService(AppConfig::PROVIDER_APP_ID, INVOKE_TARGET_KEY_PUSH, this);

        connect(m_pPushService, SIGNAL(createSessionCompleted(const PushStatus&)), this, SLOT(createSessionCompleted(const PushStatus&)));
        connect(m_pPushService, SIGNAL(createChannelCompleted(const PushStatus&, const QString&)), this, SLOT(createChannelCompleted(const PushStatus&, const QString&)));

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

