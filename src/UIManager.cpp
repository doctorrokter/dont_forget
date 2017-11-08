/*
 * UIManager.cpp
 *
 *  Created on: Nov 8, 2017
 *      Author: misha
 */

#include <src/UIManager.hpp>
#include "config/AppConfig.hpp"

#define WALLPAPERS_PATH "asset:///images/backgrounds/"

UIManager::UIManager(QObject* parent) : QObject(parent) {
    m_backgroundImage = AppConfig::getStatic("background_image", "earth.jpg").toString();
}

UIManager::~UIManager() {}

QString UIManager::getBackgroundImage() const { return WALLPAPERS_PATH + m_backgroundImage; }
void UIManager::setBackgroundImage(const QString& backgroundImage) {
    if (m_backgroundImage != backgroundImage) {
        m_backgroundImage = backgroundImage;
        emit backgroundImageChanged(WALLPAPERS_PATH + m_backgroundImage);
    }
}
