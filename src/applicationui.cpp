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
#include <QVariantList>
#include <bb/system/InvokeRequest>

#include "config/AppConfig.hpp"
#include "models/Task.hpp"
#include "services/TasksService.hpp"
#include "services/SearchService.hpp"

using namespace bb::cascades;
using namespace bb::network;
using namespace bb::system;

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
    Q_UNUSED(res);

    onSystemLanguageChanged();

    m_pTasksService = new TasksService(this);
    m_pTasksService->init();

    m_pSearchService = new SearchService(this);
    m_pSearchService->init();

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

void ApplicationUI::closeCard() {
    m_pInvokeManager->closeChildCard();
}

void ApplicationUI::initFullUI() {
    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
    QDeclarativeEngine* engine = QmlDocument::defaultDeclarativeEngine();
    QDeclarativeContext* rootContext = engine->rootContext();
    rootContext->setContextProperty("_currentPath", QDir::currentPath());
    rootContext->setContextProperty("_appConfig", m_pAppConfig);
    rootContext->setContextProperty("_tasksService", m_pTasksService);

    AbstractPane *root = qml->createRootObject<AbstractPane>();
    Application::instance()->setScene(root);
}

void ApplicationUI::initComposerUI(const QString& data) {
    qDebug() << "Init Composer UI with data: " << data << endl;

    QmlDocument *qml = QmlDocument::create("asset:///cards/CreateTaskFromUrlCard.qml");
    qml->setContextProperty("_app", this);

    QDeclarativeEngine* engine = QmlDocument::defaultDeclarativeEngine();
    QDeclarativeContext* rootContext = engine->rootContext();
    rootContext->setContextProperty("_appConfig", m_pAppConfig);
    rootContext->setContextProperty("_tasksService", m_pTasksService);
    rootContext->setContextProperty("_data", data);

    AbstractPane *root = qml->createRootObject<AbstractPane>();
    Application::instance()->setScene(root);
}

void ApplicationUI::onInvoked(const bb::system::InvokeRequest& request) {
    QString action = request.action();
    QString target = request.target();
    QString mimeType = request.mimeType();

    qDebug() << "Requested target: " << target << endl;
    qDebug() << "Requested action: " << action << endl;
    qDebug() << "Requested mimeType: " << mimeType << endl;

    if (target == "chachkouski.DontForget.search.asyoutype") {
        initComposerUI();
    } else if (target == "chachkouski.DontForget.card.edit.text") {
        qDebug() << "SHARE card requested" << endl;
        QString data = QString::fromUtf8(request.data());
        qDebug() << "Data received: " << data << endl;
        initComposerUI(data);
    } else if (target == "chachkouski.DontForget.card.edit.uri") {
        qDebug() << "SHARE card requested" << endl;
        QUrl url = request.uri();
        m_url = url.toString();
        initComposerUI(m_url);
    }
//    if (action.compare("bb.action.PUSH") == 0) {
//        PushPayload payload(request);
//        if (payload.isValid()) {
//            qDebug() << "Payload is valid. Processing now." << endl;
//            if (payload.isAckRequired()) {
//                qDebug() << "ACK required. Sending..." << endl;
//                m_pPushService->getPushService()->acceptPush(payload.id());
//            }
//
//            QString data = payload.data();
//            qDebug() << data << endl;
//        }
//    } else if (action.compare("bb.action.SEARCH.EXTENDED") == 0) {
//        qDebug() << "Test: handleInvoke()";
//        qDebug() << "Invoke action:" << request.action();
//        qDebug() << "Search term:" << request.data();
//    } else if (action.compare("bb.action.SEARCH.SOURCE") == 0) {
//        qDebug() << "Test: handleInvoke()";
//        qDebug() << "Invoke action:" << request.action();
//        qDebug() << "Search term:" << request.data();
//    }
}
