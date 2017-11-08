/*
 * UIManager.hpp
 *
 *  Created on: Nov 8, 2017
 *      Author: misha
 */

#ifndef UIMANAGER_HPP_
#define UIMANAGER_HPP_

#include <QObject>

class UIManager: public QObject {
    Q_OBJECT
    Q_PROPERTY(QString backgroundImage READ getBackgroundImage WRITE setBackgroundImage NOTIFY backgroundImageChanged)
public:
    UIManager(QObject* parent = 0);
    virtual ~UIManager();

    QString getBackgroundImage() const;
    void setBackgroundImage(const QString& backgroundImage);

Q_SIGNALS:
    void backgroundImageChanged(const QString& backgroundImage);

private:
    QString m_backgroundImage;
};

#endif /* UIMANAGER_HPP_ */
