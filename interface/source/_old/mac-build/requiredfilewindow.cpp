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

#include "requiredfilewindow.h"
#include <QDebug>
#include "interface.h"

#ifdef Q_WS_MAC
    #include "ui_mac_requiredfilewindow.h"
#else
    #ifdef Q_OS_LINUX
        #include "ui_nix_requiredfilewindow.h"
    #else
        #ifdef Q_OS_WIN32
            #include "ui_win_requiredfilewindow.h"
        #endif
    #endif
#endif

requiredFileWindow::requiredFileWindow(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::requiredFileWindow) {
    interface anubisInterface;
    ui->setupUi(this);
    ui->extensionsFrame->hide();
    ui->osSpecificFrame->hide();
    ui->versionsFrame->hide();

    if (anubisInterface.line6.mid(anubisInterface.getLine6().length() - 3) == "YES") {
        ui->requireOSVersionCheckBox->setChecked(true);
    } else {
        ui->requireOSVersionCheckBox->setChecked(false);
    }
}

requiredFileWindow::~requiredFileWindow() {
    delete ui;
}

void requiredFileWindow::on_osSpecificCheckBox_clicked(bool checked) {
    if (checked) {
        ui->extensionsFrame->show();
        ui->osSpecificFrame->show();
    } else {
        ui->extensionsFrame->hide();
        ui->osSpecificFrame->hide();
    }
}

void requiredFileWindow::on_appliesToWindowsCheckBox_clicked(bool checked) {
    if (!checked && ((ui->appliesToMacCheckBox->checkState() && ui->appliesToLinuxCheckBox->checkState()) || (ui->appliesToMacCheckBox->checkState() || ui->appliesToLinuxCheckBox->checkState()))) {
        ui->windowsExtensionsLabel->hide();
        ui->windowsExtensionsEntry->hide();
        ui->appliesToWindowsCheckBox->setChecked(false);
    } else {
        ui->windowsExtensionsLabel->show();
        ui->windowsExtensionsEntry->show();
        ui->appliesToWindowsCheckBox->setChecked(true);
    }
}

void requiredFileWindow::on_appliesToMacCheckBox_clicked(bool checked) {
    if (!checked && ((ui->appliesToWindowsCheckBox->checkState() && ui->appliesToLinuxCheckBox->checkState()) || (ui->appliesToWindowsCheckBox->checkState() || ui->appliesToLinuxCheckBox->checkState()))) {
        ui->macExtensionsLabel->hide();
        ui->macExtensionsEntry->hide();
        ui->appliesToMacCheckBox->setChecked(false);
    } else {
        ui->macExtensionsLabel->show();
        ui->macExtensionsEntry->show();
        ui->appliesToMacCheckBox->setChecked(true);
    }
}

void requiredFileWindow::on_requireOSVersionCheckBox_clicked(bool checked) {
    if (checked) {
        ui->versionsFrame->show();
    } else {
        ui->versionsFrame->hide();
    }
}

void requiredFileWindow::on_buttonBox_accepted() {
    interface anubisInterface;

    if (ui->fileName->text() != "") {
        if (anubisInterface.getLine4() == "" || anubisInterface.getLine4() == "os:ALL") {
            if (ui->fileName->text() != "") {
                // Detect Target Operating System (line 5)
                if (ui->appliesToWindowsCheckBox->checkState() && ui->appliesToMacCheckBox->checkState() && ui->appliesToLinuxCheckBox->checkState()) {
                    QString string = "os:ALL";
                    anubisInterface.setLine5(string);
                } else {
                    QStringList os;

                    if (ui->appliesToLinuxCheckBox->checkState()) {
                        if (ui->requireOSVersionCheckBox->checkState()) {
                            os << ui->linuxOSSpecificationEntry->text();
                        } else {
                            os << "Linux";
                        }
                    }

                    if (ui->appliesToMacCheckBox->checkState()) {
                        if (ui->requireOSVersionCheckBox->checkState()) {
                            os << ui->macOSSpecificationEntry->text();
                        } else {
                            os << "Mac";
                        }
                    }

                    if (ui->appliesToWindowsCheckBox->checkState()) {
                        if (ui->requireOSVersionCheckBox->checkState()) {
                            os << ui->windowsOSSpecificationEntry->text();
                        } else {
                            os << "Windows";
                        }
                    }

                    QString str = os.join(", ");
                    str = QString("os:") + str;
                    anubisInterface.setLine5(str);
                } // End Target OS Detection
            }
        }

        // Detect if the file is OS Specific
        if (anubisInterface.getLine4() == "" || anubisInterface.getLine4().mid(anubisInterface.getLine4().length() - 3) != "YES") {
            if (ui->osSpecificCheckBox->checkState()) {
                if (anubisInterface.getLine4().mid(anubisInterface.getLine4().length() - 2) == "NO" || anubisInterface.getLine4() == "") {
                    QString str = QString("filesOSSpecific:YES");
                    anubisInterface.setLine4(str);
                }
            } else {
                if (anubisInterface.getLine4() == "") {
                    QString str = QString("filesOSSpecific:NO");
                    anubisInterface.setLine4(str);
                }
            } // End file OS Specific Dectection
        }

        // OS Version Requirement Detect
        if (ui->requireOSVersionCheckBox->checkState()) {
            QString str = QString("osVersionRequired:YES");
            anubisInterface.setLine6(str);
        } else {
            QString str = QString("osVersionRequired:NO");
            anubisInterface.setLine6(str);
        } // NOTE, There is no protection for overwriting version required data

        // End OS Version Requirement Detection

        // File Extension Detection
        if (anubisInterface.getLine8() == "" || anubisInterface.getLine8() == "commandEXT:,,") {
            QStringList extensions;

            if (ui->appliesToLinuxCheckBox->checkState()) {
                extensions << ui->linuxExtensionsEntry->text();
            } else {
                extensions << QString(" ");
            }

            if (ui->appliesToMacCheckBox->checkState()) {
                extensions << ui->macExtensionsEntry->text();
            } else {
                extensions << QString(" ");
            }

            if (ui->appliesToWindowsCheckBox->checkState()) {
                extensions << ui->windowsExtensionsEntry->text();
            } else {
                extensions << QString(" ");
            }

            QString str = QString("commandEXT:") + extensions.join(", ");
            str.replace("  ,", ",");
            str.replace(" , ", ", ");
            str.replace(",, ", ",,");
            anubisInterface.setLine8(str);
        } // END File Extension Detection

        // FileName Recgonition
        QString fileName = QString(ui->fileName->text());

        if (ui->osSpecificCheckBox->checkState()) {
            // Prepend *OS* Wildcard with the proper joining character
            fileName = "*OS*_" + fileName;
            // Append Extension Wildcard by removing the old extension
            QStringList fileNameSegments = fileName.split(".");

            if (fileNameSegments.count() > 1) {
                fileNameSegments.removeLast();
            }

            fileName = fileNameSegments.join(".");
            fileName += "*EXT*";
        }

        anubisInterface.requiredFiles << fileName;
        fileName = "";
    }
}


void requiredFileWindow::on_appliesToLinuxCheckBox_clicked(bool checked) {
    if (!checked && ((ui->appliesToMacCheckBox->checkState() && ui->appliesToWindowsCheckBox->checkState()) || (ui->appliesToMacCheckBox->checkState() || ui->appliesToWindowsCheckBox->checkState()))) {
        ui->linuxExtensionsLabel->hide();
        ui->linuxExtensionsEntry->hide();
        ui->appliesToLinuxCheckBox->setChecked(false);
    } else {
        ui->linuxExtensionsLabel->show();
        ui->linuxExtensionsEntry->show();
        ui->appliesToLinuxCheckBox->setChecked(true);
    }
}

void requiredFileWindow::on_buttonBox_rejected() {
    this->close();
}