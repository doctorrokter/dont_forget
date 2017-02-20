/*
 * Copyright (c) 2011-2015 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "applicationui.hpp"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>
#include <bb/cascades/VisualStyle>
#include <bb/cascades/ThemeSupport>
#include <bb/network/PushPayload>
#include <bb/system/CardDoneMessage>
#include <QVariantList>
#include <QVariantMap>
#include <bb/system/InvokeRequest>
#include <bb/data/JsonDataAccess>
#include <bb/platform/Notification>

#include "config/AppConfig.hpp"
#include "models/Task.hpp"
#include "services/TasksService.hpp"
#include "services/SearchService.hpp"

#define INVOKE_SEARCH_SOURCE "chachkouski.DontForget.search.asyoutype"
#define INVOKE_CARD_EDIT_TEXT "chachkouski.DontForget.card.edit.text"
#define INVOKE_CARD_EDIT_URI "chachkouski.DontForget.card.edit.uri"
#define CREATE_TASK_FROM_TEXT_CARD "asset:///cards/CreateTaskFromTextCard.qml"
#define CREATE_TASK_FROM_URL_CARD "asset:///cards/CreateTaskFromUrlCard.qml"

using namespace bb::cascades;
using namespace bb::network;
using namespace bb::system;
using namespace bb::data;
using namespace bb::platform;

ApplicationUI::ApplicationUI() : QObject() {
    m_pTranslator = new QTranslator(this);
    m_pLocaleHandler = new LocaleHandler(this);

    QCoreApplication::setOrganizationName("mikhail.chachkouski");
    QCoreApplication::setApplicationName("DontForget");

    m_pInvokeManager = new InvokeManager(this);
    connect(m_pInvokeManager, SIGNAL(invoked(const bb::system::InvokeRequest&)), SLOT(onInvoked(const bb::system::InvokeRequest&)));

    m_pAppConfig = new AppConfig(this);
    QString theme = m_pAppConfig->get("theme").toString();
    if (theme.compare("") != 0) {
        if (theme.compare("DARK") == 0) {
            Application::instance()->themeSupport()->setVisualStyle(VisualStyle::Dark);
        } else {
            Application::instance()->themeSupport()->setVisualStyle(VisualStyle::Bright);
        }
    }

    bool res = QObject::connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), this, SLOT(onSystemLanguageChanged()));
    Q_ASSERT(res);

    onSystemLanguageChanged();

    m_pTasksService = new TasksService(this);
    m_pTasksService->init();

    m_pSearchService = new SearchService(this, m_pTasksService);
    m_pSearchService->init();

    m_pPushService = new PushNotificationService(this);
    m_pPushService->initPushService();

    m_pDropboxService = new DropboxService(this);

    res = QObject::connect(m_pDropboxService, SIGNAL(fileLoaded(const QString&)), this, SLOT(processTasksContent(const QString&)));
    Q_ASSERT(res);
    Q_UNUSED(res);

    switch (m_pInvokeManager->startupMode()) {
        case ApplicationStartupMode::LaunchApplication:
            m_startupMode = "Launch";
            initFullUI();
            break;
        case ApplicationStartupMode::InvokeApplication:
            // Wait for invoked signal to determine and initialize the appropriate UI
            m_startupMode = "Invoke";
            break;
        case ApplicationStartupMode::InvokeCard:
            // Wait for invoked signal to determine and initialize the appropriate UI
            m_startupMode = "Card";
            break;
        }

//    qDebug() << "===>>> Startup mode: " << m_startupMode << endl;
}

void ApplicationUI::onSystemLanguageChanged() {
    QCoreApplication::instance()->removeTranslator(m_pTranslator);
    // Initiate, load and install the application translation files.
    QString locale_string = QLocale().name();
    QString file_name = QString("DontForget_%1").arg(locale_string);
    if (m_pTranslator->load(file_name, "app/native/qm")) {
        QCoreApplication::instance()->installTranslator(m_pTranslator);
    }
}

void ApplicationUI::cardDone(const QString& msg) {
    // Assemble message
    CardDoneMessage message;
    message.setData(msg);
    message.setDataType("text/plain");
    message.setReason(tr("Success!"));

    // Send message
    m_pInvokeManager->sendCardDone(message);
}

void ApplicationUI::initFullUI() {
    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
    QDeclarativeEngine* engine = QmlDocument::defaultDeclarativeEngine();
    QDeclarativeContext* rootContext = engine->rootContext();
    rootContext->setContextProperty("_app", this);
    rootContext->setContextProperty("_currentPath", QDir::currentPath());
    rootContext->setContextProperty("_appConfig", m_pAppConfig);
    rootContext->setContextProperty("_tasksService", m_pTasksService);
    rootContext->setContextProperty("_pushService", m_pPushService);
    rootContext->setContextProperty("_dropboxService", m_pDropboxService);
    m_running = true;

    AbstractPane *root = qml->createRootObject<AbstractPane>();
    Application::instance()->setScene(root);
}

void ApplicationUI::initComposerUI(const QString& pathToPage, const QString& data) {
//    qDebug() << "Init Composer UI with data: " << data << endl;

    QmlDocument *qml = QmlDocument::create(pathToPage);
    qml->setContextProperty("_app", this);

    QDeclarativeEngine* engine = QmlDocument::defaultDeclarativeEngine();
    QDeclarativeContext* rootContext = engine->rootContext();
    rootContext->setContextProperty("_app", this);
    rootContext->setContextProperty("_appConfig", m_pAppConfig);
    rootContext->setContextProperty("_tasksService", m_pTasksService);
    rootContext->setContextProperty("_data", data);

    AbstractPane *root = qml->createRootObject<AbstractPane>();
    Application::instance()->setScene(root);
}

void ApplicationUI::processTasksContent(const QString& tasksContent) {
    m_pDropboxService->deleteFile(m_filesToDelete.at(0));
    m_filesToDelete.pop_front();

    JsonDataAccess jda;
    QVariant dataVar = jda.loadFromBuffer(tasksContent);
    if (!jda.hasError()) {
        qDebug() << tasksContent << endl;

        QVariantMap dataMap = dataVar.toMap();
        qDebug() << dataMap << endl;

        processReceivedTaskMap(dataMap, 0);

        Notification* p_notification = new Notification(this);
        p_notification->setTitle("Don't Forget");
        p_notification->setBody(tr("Tasks received!"));
        p_notification->notify();
        p_notification->deleteLater();

        emit tasksReceived();
        if (!m_running) {
            Application::quit();
        }
    } else {
        qDebug() << jda.error() << endl;
    }
}

void ApplicationUI::processReceivedTaskMap(const QVariantMap& taskMap, const int parentId) {
    Task task;
    task.fromMap(taskMap);
    task.setParentId(parentId);

    m_pTasksService->copyTask(task);

    QVariantList children = taskMap.value("children").toList();
    task.fromMap(m_pTasksService->lastCreated());
    if (!children.isEmpty()) {
        foreach(QVariant t, children) {
            processReceivedTaskMap(t.toMap(), task.getId());
        }
    }
}

void ApplicationUI::onInvoked(const bb::system::InvokeRequest& request) {
    QString action = request.action();
    QString target = request.target();
    QString mimeType = request.mimeType();

    qDebug() << "Requested target: " << target << endl;
    qDebug() << "Requested action: " << action << endl;
    qDebug() << "Requested mimeType: " << mimeType << endl;

    if (target == INVOKE_SEARCH_SOURCE) {
        int id = QString::fromUtf8(request.data()).toInt();
        if (!m_running) {
            initFullUI();
        }
        m_pTasksService->setActiveTask(id);
        emit taskSheetRequested();
    } else if (target == INVOKE_CARD_EDIT_TEXT) {
        initComposerUI(CREATE_TASK_FROM_TEXT_CARD, QString::fromUtf8(request.data()));
    } else if (target == INVOKE_CARD_EDIT_URI) {
        initComposerUI(CREATE_TASK_FROM_URL_CARD, request.uri().toString());
    } else if (target == INVOKE_TARGET_KEY_PUSH) {
        PushPayload payload(request);
        if (payload.isValid()) {
            qDebug() << "Payload is valid. Processing now." << endl;
            if (payload.isAckRequired()) {
                qDebug() << "ACK required. Sending..." << endl;
                m_pPushService->getPushService()->acceptPush(payload.id());
            }

            QString data = QString::fromUtf8(payload.data());
            qDebug() << data << endl;

            JsonDataAccess jda;
            QVariant dataVar = jda.loadFromBuffer(data);
            if (!jda.hasError()) {
                QVariantMap dataMap = dataVar.toMap();
                QVariantMap bodyMap = dataMap.value("body").toMap();
                m_pDropboxService->loadFile(bodyMap.value("link").toString());
                m_filesToDelete.append(bodyMap.value("metadata").toMap().value("path_display").toString());
            } else {
                qDebug() << jda.error() << endl;
            }

        }
    }
}
