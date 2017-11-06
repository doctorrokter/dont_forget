/*
 * BackupService.hpp
 *
 *  Created on: Oct 25, 2017
 *      Author: misha
 */

#ifndef BACKUPSERVICE_HPP_
#define BACKUPSERVICE_HPP_

#include <QObject>

class BackupService: public QObject {
public:
    BackupService(QObject* parent = 0);
    virtual ~BackupService();
};

#endif /* BACKUPSERVICE_HPP_ */
