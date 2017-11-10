/*
 * Color.cpp
 *
 *  Created on: Nov 9, 2017
 *      Author: misha
 */

#include <src/Color.hpp>

Logger Color::logger = Logger::getLogger("Color");

Color::Color(QObject* parent) : QObject(parent) {
    m_skyBlue = "#0092CC";
    m_stormBlue = "#087099";
    m_hyperRed = "#FF3333";
    m_brickRed = "#CC3333";
    m_lightYellow = "#DCD427";
    m_darkYellow = "#B7B327";
    m_lightGreen = "#779933";
    m_darkGreen = "#5C7829";
    m_black = "#323232";
    m_grey = "#969696";
    m_magenta = "#8B008B";

    logger.info("Created");
}

Color::~Color() {}

const QString& Color::skyBlue() const { return m_skyBlue; }
const QString& Color::stormBlue() const { return m_stormBlue; }
const QString& Color::hyperRed() const { return m_hyperRed; }
const QString& Color::brickRed() const { return m_brickRed; }
const QString& Color::lightYellow() const { return m_lightYellow; }
const QString& Color::darkYellow() const { return m_darkYellow; }
const QString& Color::lightGreen() const { return m_lightGreen; }
const QString& Color::darkGreen() const { return m_darkGreen; }
const QString& Color::black() const { return m_black; }
const QString& Color::grey() const { return m_grey; }
const QString& Color::magenta() const { return m_magenta; }

