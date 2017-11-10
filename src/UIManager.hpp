/*
 * UIManager.hpp
 *
 *  Created on: Nov 8, 2017
 *      Author: misha
 */

#ifndef UIMANAGER_HPP_
#define UIMANAGER_HPP_

#include <QObject>
#include "Color.hpp"
#include "Logger.hpp"

class UIManager: public QObject {
    Q_OBJECT
    Q_PROPERTY(QString backgroundImage READ getBackgroundImage WRITE setBackgroundImage NOTIFY backgroundImageChanged)
    Q_PROPERTY(Color* color READ getColor NOTIFY colorChanged)
public:
    UIManager(QObject* parent = 0);
    virtual ~UIManager();

    QString getBackgroundImage() const;
    void setBackgroundImage(const QString& backgroundImage);

    Color* getColor() const;

Q_SIGNALS:
    void backgroundImageChanged(const QString& backgroundImage);
    void colorChanged(Color* color);

private:
    static Logger logger;

    QString m_backgroundImage;
    Color* m_pColor;
};

#endif /* UIMANAGER_HPP_ */
