/*
 * Signal.hpp
 *
 *  Created on: Mar 11, 2017
 *      Author: misha
 */

#ifndef SIGNAL_HPP_
#define SIGNAL_HPP_

#include <QtCore/QObject>
#include <bb/device/VibrationController>

using namespace bb::device;

class Signal: public QObject {
    Q_OBJECT
public:
    Signal(QObject* parent = 0);
    virtual ~Signal();

    Q_INVOKABLE void play() const;
    Q_INVOKABLE void setSoundEnabled(const bool soundEnabled);
    Q_INVOKABLE void setVibrationEnabled(const bool vibrationEnabled);

private:
    bool m_soundEnabled;
    bool m_vibrationEnabled;
    VibrationController* m_pVibration;

    bool isSoundEnabled() const;
    bool isVibrationEnabled() const;
};

#endif /* SIGNAL_HPP_ */
