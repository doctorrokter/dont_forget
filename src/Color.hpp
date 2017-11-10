/*
 * Color.hpp
 *
 *  Created on: Nov 9, 2017
 *      Author: misha
 */

#ifndef COLOR_HPP_
#define COLOR_HPP_

#include <QObject>
#include "Logger.hpp"

class Color: public QObject {
    Q_OBJECT
    Q_PROPERTY(QString skyBlue READ skyBlue NOTIFY slyBlueChanged)
    Q_PROPERTY(QString stormBlue READ stormBlue NOTIFY stormBlueChanged)
    Q_PROPERTY(QString hyperRed READ hyperRed NOTIFY hyperRedChanged)
    Q_PROPERTY(QString brickRed READ brickRed NOTIFY brickRedChanged)
    Q_PROPERTY(QString lightYellow READ lightYellow NOTIFY lightYellowChanged)
    Q_PROPERTY(QString darkYellow READ darkYellow NOTIFY darkYellowChanged)
    Q_PROPERTY(QString lightGreen READ lightGreen NOTIFY lightGreenChanged)
    Q_PROPERTY(QString darkGreen READ darkGreen NOTIFY darkGreenChanged)
    Q_PROPERTY(QString black READ black NOTIFY blackChanged)
    Q_PROPERTY(QString grey READ grey NOTIFY greyChanged)
    Q_PROPERTY(QString magenta READ magenta NOTIFY magentaChanged)
public:
    Color(QObject* parent = 0);
    virtual ~Color();

    const QString& skyBlue() const;
    const QString& stormBlue() const;
    const QString& hyperRed() const;
    const QString& brickRed() const;
    const QString& lightYellow() const;
    const QString& darkYellow() const;
    const QString& lightGreen() const;
    const QString& darkGreen() const;
    const QString& black() const;
    const QString& grey() const;
    const QString& magenta() const;

    Q_SIGNALS:
        void slyBlueChanged(const QString& skyBlue);
        void stormBlueChanged(const QString& stormBlue);
        void hyperRedChanged(const QString& hyperRed);
        void brickRedChanged(const QString& brickRed);
        void lightYellowChanged(const QString& lightYellow);
        void darkYellowChanged(const QString& darkYellow);
        void lightGreenChanged(const QString& lightGreen);
        void darkGreenChanged(const QString& darkGreen);
        void blackChanged(const QString& black);
        void greyChanged(const QString& grey);
        void magentaChanged(const QString& magenta);

private:
    static Logger logger;

    QString m_skyBlue;
    QString m_stormBlue;
    QString m_hyperRed;
    QString m_brickRed;
    QString m_lightYellow;
    QString m_darkYellow;
    QString m_lightGreen;
    QString m_darkGreen;
    QString m_black;
    QString m_grey;
    QString m_magenta;
};

#endif /* COLOR_HPP_ */
