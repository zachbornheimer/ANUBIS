#-------------------------------------------------
#
# Project created by QtCreator 2011-05-04T10:22:40
#
#-------------------------------------------------

QT       += "core gui"
QT       += "network"

TARGET = "Interface"
TEMPLATE = "app"

SOURCES += "main.cpp"\
           "interface.cpp" \
           "aboutanubis.cpp" \
           "aboutanubisinterface.cpp" \
           "tutorialswindow.cpp" \
           "aboutthetechnetronicsgroupwindow.cpp" \
           "editdatawindow.cpp" \
           "requiredfilewindow.cpp" \
    licensewindow.cpp

HEADERS  += "interface.h" \
            "aboutanubis.h" \
            "aboutanubisinterface.h" \
            "tutorialswindow.h" \
            "aboutthetechnetronicsgroupwindow.h" \
            "editdatawindow.h" \
            "requiredfilewindow.h" \
    licensewindow.h

win32 {
    FORMS    += "win_interface.ui" \
                "win_aboutanubis.ui" \
                "win_aboutanubisinterface.ui" \
                "win_tutorialswindow.ui" \
                "win_aboutthetechnetronicsgroupwindow.ui" \
                "win_editdatawindow.ui" \
                "win_requiredfilewindow.ui" \
                "win_licensewindow.ui"
} else:mac {
    FORMS    += "mac_interface.ui" \
                "mac_aboutanubis.ui" \
                "mac_aboutanubisinterface.ui" \
                "mac_tutorialswindow.ui" \
                "mac_aboutthetechnetronicsgroupwindow.ui" \
                "mac_editdatawindow.ui" \
                "mac_requiredfilewindow.ui" \
                "mac_licensewindow.ui"
} else {
    FORMS    += "nix_interface.ui" \
                "nix_aboutanubis.ui" \
                "nix_aboutanubisinterface.ui" \
                "nix_tutorialswindow.ui" \
                "nix_aboutthetechnetronicsgroupwindow.ui" \
                "nix_editdatawindow.ui" \
                "nix_requiredfilewindow.ui" \
                "nix_licensewindow.ui"
}

unix {
    ICON = "ANUBIS.icns"
} else:win32 {
    RC_FILE += "windows.rc"
    ICON = "anubis.ico"
    OTHER_FILES += "windows.rc"
}

RESOURCES += "resources.qrc"

FORMS += \
    mac_licensewindow.ui
