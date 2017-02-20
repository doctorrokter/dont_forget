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
#include <QList>
#include <bb/system/InvokeManager>
#include <bb/system/InvokeRequest>

#include "services/PushNotificationService.hpp"
#include "services/TasksService.hpp"
#include "services/SearchService.hpp"
#include "services/DropboxService.hpp"
#include "config/AppConfig.hpp"

namespace bb
{
    namespace cascades
    {
        class LocaleHandler;
    }
}
using namespace bb::system;

class QTranslator;

/*!
 * @brief Application UI object
 *
 * Use this object to create and init app UI, to create context objects, to register the new meta types etc.
 */
class ApplicationUI : public QObject {
    Q_OBJECT
public:
    ApplicationUI();
    virtual ~ApplicationUI() {}

Q_SIGNALS:
    void taskSheetRequested();
    void tasksReceived();

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
    TasksService* m_pTasksService;
    SearchService* m_pSearchService;
    DropboxService* m_pDropboxService;

    bool m_running;
    QList<QString> m_filesToDelete;

    void initFullUI();
    void initComposerUI(const QString& pathToPage, const QString& data = "");
    void processReceivedTaskMap(const QVariantMap& taskMap, const int parentId);
};

#endif /* ApplicationUI_HPP_ */
