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

#ifndef INTERFACE_H
#define INTERFACE_H

#include <QMainWindow>
#include <QStringList>

namespace Ui {
class interface;
}

class interface : public QMainWindow {
    Q_OBJECT

public:
    explicit interface(QWidget *parent = 0);
    ~interface();

    static int commandNumber;
    static QString line1;
    static QString line2;
    static QString line3;
    static QString line4;
    static QString line5;
    static QString line6;
    static QString line7;
    static QString line8;
    static QString line9;
    static QString line10;
    static QStringList requiredFiles;

    void retrieveCommands();
    void setCommandNumber();
    int getCommandNumber();
    void getCommands();
    void setLine1(QString &);
    void setLine2(QString &);
    void setLine3(QString &);
    void appendLine3(QString &);
    void setLine4(QString &);
    void setLine5(QString &);
    void setLine6(QString &);
    void setLine7(QString &);
    void setLine8(QString &);
    void setLine9(QString &);
    void setLine10(QString &);
    QString getLine1();
    QString getLine2();
    QString getLine3();
    QString getLine4();
    QString getLine5();
    QString getLine6();
    QString getLine7();
    QString getLine8();
    QString getLine9();
    QString getLine10();
    void appendRequiredFileArray(QString &);
    QString combineRequiredFileArray();
    std::string intToString(int);



private:
    Ui::interface *ui;
    QByteArray commandsFile;


private slots:
    void displayAboutANUBISWindow();
    void displayAboutANUBISInterfaceWindow();
    void displayAboutTheTechnetronicsGroupWindow();
    void displayLicenseWindow();
    void displayEditDataWindow();
    void displayTutorialsWindow();
    void displayRequiredFilesWindow();
    void on_generateCommandsButton_clicked();
};

#endif // INTERFACE_H
