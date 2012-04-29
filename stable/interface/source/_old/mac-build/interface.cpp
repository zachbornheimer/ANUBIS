/*
    This file is part of the ANUBIS Interface and the larger
    ANUBIS package.  The ANUBIS package and all its parts,
    including this application, are Copyright 2011 Zachary Bornheimer.

    The ANUBIS Interface is free software: you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation, either
    version 3 of the License, or any later version.

    The ANUBIS Interface is distributed in the hope that it will be
    useful, but WITHOUT ANY WARRANTY; without even the implied
    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with The ANUBIS Interface.  If not, see
    <http://www.gnu.org/licenses/>.
*/

#include "interface.h"
#include "aboutanubis.h"
#include "aboutanubisinterface.h"
#include "aboutthetechnetronicsgroupwindow.h"
#include "tutorialswindow.h"
#include "editdatawindow.h"
#include "requiredfilewindow.h"
#include "licensewindow.h"
#include <QtNetwork/QtNetwork>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkRequest>
#include <QUrl>
#include <QList>
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <sstream>
#include <QString>
#include <qstring.h>
#include <QDebug>
#include <sstream>

#ifdef Q_WS_MAC
    #include "ui_mac_interface.h"
#else
    #ifdef Q_OS_LINUX
        #include "ui_nix_interface.h"
    #else
        #ifdef Q_OS_WIN32
            #include "ui_win_interface.h"
        #endif
    #endif
#endif

int interface::commandNumber;
QString interface::line1;
QString interface::line2;
QString interface::line3;
QString interface::line4;
QString interface::line5;
QString interface::line6;
QString interface::line7;
QString interface::line8;
QString interface::line9;
QString interface::line10;
QStringList interface::requiredFiles;

interface::interface(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::interface) {
    ui->setupUi(this);
    connect (ui->actionAbout_ANUBIS, SIGNAL(triggered()), this, SLOT(displayAboutANUBISWindow()));
    connect (ui->actionAbout_ANUBIS_Interface, SIGNAL(triggered()), this, SLOT(displayAboutANUBISInterfaceWindow()));
    connect (ui->actionAbout_The_Technetronics_Group, SIGNAL(triggered()), this, SLOT(displayAboutTheTechnetronicsGroupWindow()));
    connect (ui->actionEdit_Data, SIGNAL(triggered()), this, SLOT(displayEditDataWindow()));
    connect (ui->actionTutorials, SIGNAL(triggered()), this, SLOT(displayTutorialsWindow()));
    connect (ui->addRequiredFiles, SIGNAL(clicked()), this, SLOT(displayRequiredFilesWindow()));
    connect (ui->actionLicense, SIGNAL(triggered()), this, SLOT(displayLicenseWindow()));
    ui->filePaths->setText(interface::requiredFiles.join(", "));
}

interface::~interface() {
    delete ui;
}


void interface::displayRequiredFilesWindow() {
    interface anubisInterface;
    requiredFileWindow window;
    window.show();
    window.exec();
    ui->filePaths->setText(interface::requiredFiles.join(", "));

    if (!interface::requiredFiles.isEmpty()) {
        ui->executeFileList->addItem(interface::requiredFiles.last());
    }

    this->activateWindow();
}

int interface::getCommandNumber() {
    return interface::commandNumber;
}

void interface::displayAboutANUBISWindow() {
    aboutANUBIS window;
    window.exec();
    this->activateWindow();
}

void interface::displayLicenseWindow() {
    licenseWindow window;
    window.exec();
    this->activateWindow();
}

void interface::displayAboutANUBISInterfaceWindow() {
    aboutANUBISInterface window;
    window.exec();
    this->activateWindow();
}

void interface::displayAboutTheTechnetronicsGroupWindow() {
    aboutTheTechnetronicsGroupWindow window;
    window.exec();
    this->activateWindow();
}

void interface::displayEditDataWindow() {
    editDataWindow window;
    window.exec();
    this->activateWindow();
}

void interface::displayTutorialsWindow() {
    tutorialsWindow window;
    window.exec();
    this->activateWindow();
}

void interface::retrieveCommands() {
    QString cont = "yes";
    QString url;

    while (cont == "yes") {
        QSettings settings("The Technetronics Group", "Interface");
        settings.beginGroup("data");
        QString url = settings.value("commandsFileURL").toString();
        settings.endGroup();

        if (url == "") {
            displayEditDataWindow();
        } else {
            cont = "no";
        }
    }

    QSettings settings("The Technetronics Group", "Interface");
    settings.beginGroup("data");
    url = settings.value("commandsFileURL").toString();
    settings.endGroup();
    QNetworkAccessManager *nam = new QNetworkAccessManager(this);
    QNetworkReply *reply = nam->get(QNetworkRequest(QUrl(url)));
    QEventLoop eLoop;
    connect( nam, SIGNAL( finished( QNetworkReply * ) ), &eLoop, SLOT(quit() ) );
    eLoop.exec();
    interface::commandsFile = reply->readAll();
}

void interface::setCommandNumber() {
    QList<QByteArray> array = interface::commandsFile.split('\n');
    QList<QByteArray> command = array[array.length() - 2].split(' ');
    QString commandNumberString;
    commandNumberString.append(command[1]);
    commandNumberString.remove(0, 7);
    commandNumberString.remove(commandNumberString.length() - 1, 1);
    commandNumber = (commandNumberString.toInt() + 1);
}

QString interface::getLine1() {
    return interface::line1;
}
QString interface::getLine2() {
    return interface::line2;
}
QString interface::getLine3() {
    return interface::line3;
}
QString interface::getLine4() {
    return interface::line4;
}
QString interface::getLine5() {
    return interface::line5;
}
QString interface::getLine6() {
    return interface::line6;
}
QString interface::getLine7() {
    return interface::line7;
}
QString interface::getLine8() {
    return interface::line8;
}
QString interface::getLine9() {
    return interface::line9;
}
QString interface::getLine10() {
    return interface::line10;
}
void interface::setLine1(QString &string) {
    interface::line1 = string;
}
void interface::setLine2 (QString &string) {
    interface::line2 = string;
}
void interface::setLine3 (QString &string) {
    interface::line3 = string;
}
void interface::appendLine3(QString &string) {
    interface::line3 += string;
}
void interface::setLine4 (QString &string) {
    interface::line4 = string;
}
void interface::setLine5 (QString &string) {
    interface::line5 = string;
}
void interface::setLine6 (QString &string) {
    interface::line6 = string;
}
void interface::setLine7 (QString &string) {
    interface::line7 = string;
}
void interface::setLine8 (QString &string) {
    interface::line8 = string;
}
void interface::setLine9 (QString &string) {
    interface::line9 = string;
}
void interface::setLine10 (QString &string) {
    interface::line10 = string;
}
void interface::appendRequiredFileArray(QString &string) {
    interface::requiredFiles << string;
}
QString interface::combineRequiredFileArray() {
    return interface::requiredFiles.join(", ");
}

void interface::on_generateCommandsButton_clicked() {
    interface anubisInterface;

    if (ui->cleanUpWhenDoneBox->checkState()) {
        QString str = QString("cleanup:YES");
        anubisInterface.setLine9(str);
        str = "";
    } else {
        QString str = QString("cleanup:NO");
        anubisInterface.setLine9(str);
        str = "";
    }

    QString str = anubisInterface.requiredFiles.join(", ");
    str = "requiredFiles:" + str;
    anubisInterface.setLine3(str);
    str = "";
    str = ui->executeFileList->currentText();
    str = "command:_execute " + str;
    anubisInterface.setLine7(str);
    str = "";
    interface::retrieveCommands();
    interface::setCommandNumber();
    str = QString("<start COMMAND") + interface::intToString(interface::getCommandNumber()).c_str() + ">";
    anubisInterface.setLine1(str);
    str = QString("dir:COMMAND") + interface::intToString(interface::getCommandNumber()).c_str();
    anubisInterface.setLine2(str);
    str = QString("<end COMMAND") + interface::intToString(interface::getCommandNumber()).c_str() + ">";
    anubisInterface.setLine10(str);
    ui->commandsFile->setText("");
    ui->commandsFile->append(interface::getLine1());
    ui->commandsFile->append(interface::getLine2());
    ui->commandsFile->append(interface::getLine3());
    ui->commandsFile->append(interface::getLine4());
    ui->commandsFile->append(interface::getLine5());
    ui->commandsFile->append(interface::getLine6());
    ui->commandsFile->append(interface::getLine7());
    ui->commandsFile->append(interface::getLine8());
    ui->commandsFile->append(interface::getLine9());
    ui->commandsFile->append(interface::getLine10());
}

std::string interface::intToString(int number) {
    std::stringstream ss;
    ss << number;
    return ss.str();
}
