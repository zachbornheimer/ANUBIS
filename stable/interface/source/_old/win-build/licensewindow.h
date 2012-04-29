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

#ifndef LICENSEWINDOW_H
#define LICENSEWINDOW_H

#include <QDialog>

namespace Ui {
    class licenseWindow;
}

class licenseWindow : public QDialog
{
    Q_OBJECT

public:
    explicit licenseWindow(QWidget *parent = 0);
    ~licenseWindow();

private:
    Ui::licenseWindow *ui;
};

#endif // LICENSEWINDOW_H
