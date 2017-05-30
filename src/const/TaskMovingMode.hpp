/*
 * TaskMovingMode.hpp
 *
 *  Created on: May 21, 2017
 *      Author: misha
 */

#ifndef TASKMOVINGMODE_HPP_
#define TASKMOVINGMODE_HPP_

#include <QObject>
#include <QtDeclarative>

class TaskMovingMode : public QObject {
    Q_OBJECT
    Q_ENUMS(MoveMode)
public:
    enum MoveMode {
        MOVING,
        NOT_MOVING
    };
};

Q_DECLARE_METATYPE(TaskMovingMode::MoveMode)

#endif /* TASKMOVINGMODE_HPP_ */
