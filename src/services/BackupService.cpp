/*
 * BackupService.cpp
 *
 *  Created on: Oct 25, 2017
 *      Author: misha
 */

#include "BackupService.hpp"
#include "../config/AppConfig.hpp"
#include <QDirIterator>
#include <QFile>
#include <QDir>
#include <QDebug>

#define BACKUP_ENABLED "backup_enabled"
#define BACKUP_EVERY "backup_every"
#define BACKUPS_NUMBER "backups_number"
#define BACKUPS_LOCATION "/shared/misc/dont_forget/backup"

BackupService::BackupService(QObject* parent) : QObject(parent) {
    bool enabled = AppConfig::getStatic(BACKUP_ENABLED).toBool();
    if (enabled) {
        int every = AppConfig::getStatic(BACKUP_EVERY).toInt();
        QDirIterator iter(QDir::currentPath() + BACKUPS_LOCATION, QDirIterator::NoIteratorFlags);
        if (iter.hasNext()) {
            QString path = iter.next();
            qDebug() << path << endl;
        } else {
            QFile f1(QDir::currentPath() + BACKUPS_LOCATION + "/bkp1.txt");
            f1.open(QIODevice::WriteOnly);
            f1.write("sdfsdf");
            f1.close();

            QFile f2(QDir::currentPath() + BACKUPS_LOCATION + "/bkp2.txt");
            f2.open(QIODevice::WriteOnly);
            f2.write("sdfsdf");
            f2.close();

            QFile f3(QDir::currentPath() + BACKUPS_LOCATION + "/bkp3.txt");
            f3.open(QIODevice::WriteOnly);
            f3.write("sdfsdf");
            f3.close();
        }
    }
}

BackupService::~BackupService() {}

