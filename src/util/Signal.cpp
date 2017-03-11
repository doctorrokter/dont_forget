/*
 * Signal.cpp
 *
 *  Created on: Mar 11, 2017
 *      Author: misha
 */

#include <src/util/Signal.hpp>
#include <src/config/AppConfig.hpp>

#include <bb/multimedia/SystemSound>

using namespace bb::multimedia;

Signal::Signal(QObject* parent) : QObject(parent) {
    m_soundEnabled = isSoundEnabled();
    m_vibrationEnabled = isVibrationEnabled();
    m_pVibration = new VibrationController(this);
}

Signal::~Signal() {}

void Signal::play() const {
    if (m_soundEnabled) {
        SystemSound::play(SystemSound::InputKeypress);
    }
    if (m_vibrationEnabled && m_pVibration->isSupported()) {
        m_pVibration->start(1, 25);
    }
}

void Signal::setSoundEnabled(const bool soundEnabled) {
    m_soundEnabled = soundEnabled;
}

void Signal::setVibrationEnabled(const bool vibrationEnabled) {
    m_vibrationEnabled = vibrationEnabled;
}

bool Signal::isSoundEnabled() const {
    QString s = AppConfig::getStatic("sound_on_select").toString();
    return !s.isEmpty() || s.compare("true") == 0;
}

bool Signal::isVibrationEnabled() const {
    QString s = AppConfig::getStatic("vibrate_on_select").toString();
    return !s.isEmpty() || s.compare("true") == 0;
}
