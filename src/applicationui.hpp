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

#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <QVariant>
#include <QList>
#include <bb/system/InvokeManager>
#include <bb/system/InvokeRequest>
#include <bb/platform/NotificationDefaultApplicationSettings>
#include <bb/cascades/QmlDocument>

#include "services/PushNotificationService.hpp"
#include "services/TasksService.hpp"
#include "services/SearchService.hpp"
#include "services/UsersService.hpp"
#include "services/DropboxService.hpp"
#include "services/AttachmentsService.hpp"
#include "config/AppConfig.hpp"
#include "config/DBConfig.hpp"
#include "util/Signal.hpp"
#include "util/CalendarUtil.hpp"
#include "util/DateUtil.hpp"
#include "Logger.hpp"
#include "UIManager.hpp"

namespace bb
{
    namespace cascades
    {
        class LocaleHandler;
    }
}
using namespace bb::system;
using namespace bb::platform;

class QTranslator;

/*!
 * @brief Application UI object
 *
 * Use this object to create and init app UI, to create context objects, to register the new meta types etc.
 */
class ApplicationUI : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList images READ getImages)
public:
    ApplicationUI();
    virtual ~ApplicationUI();

    Q_INVOKABLE void openFolder(const int& taskId, const QString& path);
    Q_INVOKABLE void openCalendarEvent(const int eventId, const int folderId, const int accountId);
    Q_INVOKABLE void openRememberNote(const QString& rememberId);
    Q_INVOKABLE QVariant loadHtmlAsObject(const QString& html);
    Q_INVOKABLE void sync();

    QVariantList getImages() const;

Q_SIGNALS:
    void taskSheetRequested(const QString& data);
    void tasksReceived();
    void taskCardDone();
    void taskCreatedFromExternal();
    void folderPageRequested(const int& taskId, const QString& path);

public Q_SLOTS:
    void onInvoked(const bb::system::InvokeRequest& request);
    void cardDone(const QString& msg);

private slots:
    void onSystemLanguageChanged();
    void processTasksContent(const QString& tasksContent);

private:
    QTranslator* m_pTranslator;
    bb::cascades::LocaleHandler* m_pLocaleHandler;
    InvokeManager* m_pInvokeManager;
    PushNotificationService* m_pPushService;
    QString m_startupMode;
    AppConfig* m_pAppConfig;
    DBConfig* m_pDbConfig;
    TasksService* m_pTasksService;
    UsersService* m_pUsersService;
    SearchService* m_pSearchService;
    DropboxService* m_pDropboxService;
    AttachmentsService* m_pAttachmentsService;
    Signal* m_pSignal;
    CalendarUtil* m_pCalendar;
    DateUtil* m_pDateUtil;
    UIManager* m_pUIManager;

    bool m_running;
    QList<QString> m_filesToDelete;
    NotificationDefaultApplicationSettings m_notifSettings;

    static Logger logger;

    void initFullUI();
    void initComposerUI(const QString& pathToPage, const QString& data = "", const QString& mimeType = "");
    void processReceivedTaskMap(const QVariantMap& taskMap, const int parentId);
    void clear();
    void configureContext(QDeclarativeContext* rootContext);
};

#endif /* ApplicationUI_HPP_ */
