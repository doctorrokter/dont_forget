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
#include <bb/data/XmlDataAccess>
#include <bb/platform/Notification>
#include <bb/platform/NotificationPriorityPolicy>
#include <QtConcurrentRun>
#include <bb/pim/calendar/CalendarEvent>
#include <bb/PpsObject>

#include "models/Task.hpp"

#define INVOKE_SEARCH_SOURCE "chachkouski.DontForget.search.asyoutype"
#define INVOKE_SEARCH_EXTENDED "chachkouski.DontForget.search.extended"
#define INVOKE_CARD_EDIT_TEXT "chachkouski.DontForget.card.edit.text"
#define INVOKE_CARD_EDIT_URI "chachkouski.DontForget.card.edit.uri"
#define CREATE_TASK_FROM_TEXT_CARD "asset:///cards/CreateTaskFromTextCard.qml"
#define CREATE_TASK_FROM_URL_CARD "asset:///cards/CreateTaskFromUrlCard.qml"

using namespace bb::cascades;
using namespace bb::network;
using namespace bb::system;
using namespace bb::data;
using namespace bb::platform;
using namespace bb::pim::calendar;

ApplicationUI::ApplicationUI() : QObject() {
    m_pTranslator = new QTranslator(this);
    m_pLocaleHandler = new LocaleHandler(this);
    m_running = false;

    m_pCalendar = new CalendarUtil(this);
    m_pDateUtil = new DateUtil(this);

    m_pDbConfig = new DBConfig(this);
    m_pAttachmentsService = new AttachmentsService(this, m_pDbConfig);

    m_pPushService = new PushNotificationService(this);
    m_pPushService->initPushService();

    m_pTasksService = new TasksService(this, m_pDbConfig, m_pAttachmentsService);
    m_pSearchService = new SearchService(this, m_pTasksService);

    m_pUsersService = new UsersService(this, m_pDbConfig);
    m_pDropboxService = new DropboxService(this);
    m_pSignal = new Signal(this);

    m_pTasksService->processCollisions();

    bool res = QObject::connect(m_pDropboxService, SIGNAL(fileLoaded(const QString&)), this, SLOT(processTasksContent(const QString&)));
    Q_ASSERT(res);
    Q_UNUSED(res);

    QCoreApplication::setOrganizationName("mikhail.chachkouski");
    QCoreApplication::setApplicationName("DontForget");

    m_notifSettings.setPreview(NotificationPriorityPolicy::Allow);
    m_notifSettings.apply();

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

    res = QObject::connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), this, SLOT(onSystemLanguageChanged()));
    Q_ASSERT(res);

    onSystemLanguageChanged();

    switch (m_pInvokeManager->startupMode()) {
        case ApplicationStartupMode::LaunchApplication:
            m_startupMode = "Launch";
            initFullUI();
            QtConcurrent::run(m_pTasksService, &TasksService::init);
            QtConcurrent::run(m_pSearchService, &SearchService::init);
            break;
        case ApplicationStartupMode::InvokeApplication:
            m_startupMode = "Invoke";
            break;
        case ApplicationStartupMode::InvokeCard:
            m_startupMode = "Card";
            break;
        }
}

ApplicationUI::~ApplicationUI() {
    clear();
}

void ApplicationUI::openCalendarEvent(const int eventId) {
    InvokeRequest req;
    req.setMimeType("text/calendar");
    req.setTarget("sys.pim.calendar.viewer.eventcreate");
    req.setAction("bb.calendar.EDIT");

    QVariantMap data;
    CalendarEvent ev = m_pCalendar->findEventById(eventId);

    data["accountId"] = ev.accountId();
    data["eventId"] = ev.id();
    data["folder"] = ev.folderId();

    req.setData(bb::PpsObject::encode(data));
    m_pInvokeManager->invoke(req);
}

void ApplicationUI::openRememberNote(const QString& rememberId) {
    InvokeRequest req;
    req.setTarget("sys.pim.remember.composer");
    req.setAction("bb.action.EDIT");
    req.setUri("pim:application/vnd.blackberry.notebookentry:" + rememberId);
    m_pInvokeManager->invoke(req);
}

QVariant ApplicationUI::loadHtmlAsObject(const QString& html) {
    XmlDataAccess xml;
    return xml.loadFromBuffer(html);
}

void ApplicationUI::onSystemLanguageChanged() {
    QCoreApplication::instance()->removeTranslator(m_pTranslator);
    QString locale_string = QLocale().name();
    QString file_name = QString("DontForget_%1").arg(locale_string);
    if (m_pTranslator->load(file_name, "app/native/qm")) {
        QCoreApplication::instance()->installTranslator(m_pTranslator);
    }
}

void ApplicationUI::cardDone(const QString& msg) {
    CardDoneMessage message;
    message.setData(msg);
    message.setDataType("text/plain");
    message.setReason(tr("Success!"));

    m_pInvokeManager->sendCardDone(message);
    emit taskCardDone();
}

void ApplicationUI::initFullUI() {
    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
    QDeclarativeEngine* engine = QmlDocument::defaultDeclarativeEngine();
    QDeclarativeContext* rootContext = engine->rootContext();
    rootContext->setContextProperty("_app", this);
    rootContext->setContextProperty("_currentPath", QDir::currentPath());
    rootContext->setContextProperty("_appConfig", m_pAppConfig);
    rootContext->setContextProperty("_tasksService", m_pTasksService);
    rootContext->setContextProperty("_usersService", m_pUsersService);
    rootContext->setContextProperty("_pushService", m_pPushService);
    rootContext->setContextProperty("_dropboxService", m_pDropboxService);
    rootContext->setContextProperty("_attachmentsService", m_pAttachmentsService);
    rootContext->setContextProperty("_calendar", m_pCalendar);
    rootContext->setContextProperty("_signal", m_pSignal);
    rootContext->setContextProperty("_date", m_pDateUtil);
    rootContext->setContextProperty("_hasSharedFilesPermission", m_pDbConfig->hasSharedFilesPermission());
    m_running = true;

    AbstractPane *root = qml->createRootObject<AbstractPane>();
    Application::instance()->setScene(root);
}

void ApplicationUI::initComposerUI(const QString& pathToPage, const QString& data, const QString& mimeType) {
    QmlDocument *qml = QmlDocument::create(pathToPage);
    QDeclarativeEngine* engine = QmlDocument::defaultDeclarativeEngine();
    QDeclarativeContext* rootContext = engine->rootContext();
    rootContext->setContextProperty("_app", this);
    rootContext->setContextProperty("_appConfig", m_pAppConfig);
    rootContext->setContextProperty("_tasksService", m_pTasksService);
    rootContext->setContextProperty("_attachmentsService", m_pAttachmentsService);
    rootContext->setContextProperty("_data", data);
    rootContext->setContextProperty("_hasSharedFilesPermission", m_pDbConfig->hasSharedFilesPermission());
    rootContext->setContextProperty("_calendar", m_pCalendar);
    rootContext->setContextProperty("_date", m_pDateUtil);
    rootContext->setContextProperty("_mimeType", mimeType);

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

        bb::platform::Notification* p_notification = new bb::platform::Notification(this);
        p_notification->setTitle("Don't Forget");
        p_notification->setBody(tr("Tasks received!"));
        p_notification->setIconUrl(QUrl("file://" + QDir::currentPath() + "/app/public/icon.png"));

        QString soundType = AppConfig::getStatic("notification_theme").toString();
        if (soundType.compare("chachkouski_theme") == 0) {
            p_notification->setSoundUrl(QUrl("file://" + QDir::currentPath() + "/app/public/notification2.mp3"));
        }

        p_notification->notify();
        p_notification->deleteLater();

        emit tasksReceived();
    } else {
        qDebug() << jda.error() << endl;
    }
    if (!m_running) {
        clear();
        exit(0);
    }
}

void ApplicationUI::processReceivedTaskMap(const QVariantMap& taskMap, const int parentId) {
    Task task;
    task.fromMap(taskMap);
    task.setParentId(parentId);

    m_pTasksService->copyTask(task);
    task.fromMap(m_pTasksService->lastCreated());

    QVariantList attachments = taskMap.value("attachments").toList();
    if (!attachments.isEmpty()) {
        foreach(QVariant attVar, attachments) {
            QVariantMap attMap = attVar.toMap();
            QByteArray bytes = QByteArray::fromBase64(attMap.value("data").toString().toAscii());
            QString name = attMap.value("name").toString();
            QString partialPath = "/shared/misc/dont_forget/attachments/";

            QDir dir("." + partialPath);
            if (!dir.exists()) {
                dir.mkpath("." + partialPath);
            }

            QFile attachment("." + partialPath + name);
            bool opened = attachment.open(QIODevice::WriteOnly);
            if (opened) {
                attachment.write(bytes);
                attachment.close();
                m_pAttachmentsService->add(task.getId(), name, "file:///accounts/1000" + partialPath + name, attMap.value("mime_type").toString());
            } else {
                qDebug() << "Cannot open a file: " << name << " " << attachment.errorString() << endl;
            }
        }
    }

    QVariantList children = taskMap.value("children").toList();
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

    qDebug() << "action: " << action << endl;
    qDebug() << "target: " << target << endl;
    qDebug() << "mimeType: " << mimeType << endl;

    if (target == INVOKE_SEARCH_SOURCE) {
        int id = QString::fromUtf8(request.data()).toInt();
        if (!m_running) {
            initFullUI();
        }
        m_pTasksService->setActiveTask(id);
        emit taskSheetRequested("");
    } else if (target == INVOKE_SEARCH_EXTENDED) {
        if (!m_running) {
            initFullUI();
        }
        QString data = QString::fromUtf8(request.data());
        emit taskSheetRequested(data);
    } else if (target == INVOKE_CARD_EDIT_TEXT) {
        initComposerUI(CREATE_TASK_FROM_TEXT_CARD, QString::fromUtf8(request.data()), mimeType);
    } else if (target == INVOKE_CARD_EDIT_URI) {
        initComposerUI(CREATE_TASK_FROM_URL_CARD, request.uri().toString(), mimeType);
    } else if (target == INVOKE_TARGET_KEY_PUSH) {
        PushPayload payload(request);
        if (payload.isValid()) {
            if (payload.isAckRequired()) {
                m_pPushService->getPushService()->acceptPush(payload.id());
            }

            QString data = QString::fromUtf8(payload.data());

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

void ApplicationUI::clear() {
    m_pAppConfig->deleteLater();
    m_pDbConfig->deleteLater();
    m_pDropboxService->deleteLater();
    m_pTasksService->deleteLater();
    m_pInvokeManager->deleteLater();
    m_pPushService->deleteLater();
    m_pSearchService->deleteLater();
    m_pUsersService->deleteLater();
    m_pTranslator->deleteLater();
    m_pLocaleHandler->deleteLater();
    m_pAttachmentsService->deleteLater();
    m_pSignal->deleteLater();
    m_pCalendar->deleteLater();
}
