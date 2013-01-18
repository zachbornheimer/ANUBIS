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

#include "aboutanubisinterface.h"
#include <QCloseEvent>
#include "interface.h"

#ifdef Q_WS_MAC
    #include "ui_mac_aboutanubisinterface.h"
#else
    #ifdef Q_OS_LINUX
        #include "ui_nix_aboutanubisinterface.h"
    #else
        #ifdef Q_OS_WIN32
            #include "ui_win_aboutanubisinterface.h"
        #endif
    #endif
#endif

aboutANUBISInterface::aboutANUBISInterface(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::aboutANUBISInterface) {
    ui->setupUi(this);
    connect(ui->okayButton, SIGNAL(clicked()), this, SLOT(close()));
}

aboutANUBISInterface::~aboutANUBISInterface() {
    delete ui;
}
