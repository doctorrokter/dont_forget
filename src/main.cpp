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

#include <QLocale>
#include <QTranslator>

#include <Qt/qdeclarativedebug.h>
#include <QList>
#include <QtCore/QObject>

#include "vendor/Console.hpp"
#include <QSettings>
#include <bb/cascades/WebPage>
#include <QTimer>

#include "models/Task.hpp"
#include "const/DFColors.hpp"
#include "util/CalendarUtil.hpp"

using namespace bb::cascades;
using namespace bb::system;

void myMessageOutput(QtMsgType type, const char* msg) {  // <-- ADD THIS
    Q_UNUSED(type);
    fprintf(stdout, "%s\n", msg);
    fflush(stdout);

    QSettings settings;
    if (settings.value("sendToConsoleDebug", true).toBool()) {
        Console* console = new Console();
        console->sendMessage("ConsoleThis$$" + QString(msg));
        console->deleteLater();
    }
}

Q_DECL_EXPORT int main(int argc, char **argv) {
    qmlRegisterType<QTimer>("chachkouski.util", 1, 0, "Timer");
    qmlRegisterType<Task>("chachkouski.models", 1, 0, "Task");
    qmlRegisterType<WebPage>("WebPageComponent", 1, 0, "WebPage");
    qmlRegisterType<DFColors>("Const", 1, 0, "DFColors");
    qRegisterMetaType<QList<Task> >("QList<Task>");
    qRegisterMetaType<Task*>("Task*");
    qRegisterMetaType<CalendarUtil*>("CalendarUtil*");

    Application app(argc, argv);

    qInstallMsgHandler(myMessageOutput);

    ApplicationUI appui;
    return Application::exec();
}
