CONFIG += qt c++11
QT += network xml sql

linux:!android {
    !contains(CONFIG, quickcontrols) {
        QT += dbus
    }
}
android {
    QT += androidextras
}

DEFINES += QWEBDAVITEM_EXTENDED_PROPERTIES

!macx {
    CONFIG(release, debug|release) {
        QMAKE_POST_LINK=$(STRIP) $(TARGET)
        DEFINES += QT_NO_DEBUG_OUTPUT
    }
}

contains(CONFIG, quickcontrols) {
    DEFINES += GHOSTCLOUD_UI_QUICKCONTROLS
}

INCLUDEPATH += $$PWD/src
DEPENDPATH += $$PWD/src
INCLUDEPATH += $$PWD/../../3rdparty/libqtcommandqueue/src
DEPENDPATH += $$PWD/../../3rdparty/libqtcommandqueue/src

INCLUDEPATH += $$PWD/../../3rdparty/qwebdavlib/qwebdavlib
DEPENDPATH += $$PWD/../../3rdparty/qwebdavlib/qwebdavlib

android {
    LIBS += $$OUT_PWD/../../3rdparty/openssl/libcrypto.so
    LIBS += $$OUT_PWD/../../3rdparty/openssl/libssl.so
    LIBS += $$OUT_PWD/../../3rdparty/qwebdavlib/qwebdavlib/libqwebdav.so
    LIBS += $$OUT_PWD/../../src/common/libharbourowncloudcommon.so
}

linux:!android {
    LIBS += $$OUT_PWD/../../3rdparty/qwebdavlib/qwebdavlib/libqwebdav.so.1
    LIBS += $$OUT_PWD/../../src/common/libharbourowncloudcommon.so.1
}

# Build everything statically on macOS
macx {
    include($$PWD/../../3rdparty/qwebdavlib/qwebdavlib/qwebdavlib.pri)
}

ios {
    LIBS += $$OUT_PWD/../../3rdparty/qwebdavlib/qwebdavlib/libqwebdav.a
    CONFIG(release, debug|release) {
        LIBS += $$OUT_PWD/../../src/common/libharbourowncloudcommon.a
    }
    CONFIG(debug, debug|release) {
        LIBS += $$OUT_PWD/../../src/common/libharbourowncloudcommon_debug.a
    }
}

# Sailfish additionals
contains(CONFIG, sailfish_build) {
    CONFIG += ghostcloud_link
    QMAKE_RPATHDIR += /usr/share/harbour-owncloud/lib
}

# Ubuntu Touch configuration
contains(CONFIG, click) {
    DEFINES += GHOSTCLOUD_UBUNTU_TOUCH
    DEFINES += OS_SUPPORTS_THEME_PROVIDER # Qml-Ui-Set
}

# Ubuntu Touch Photo Backup configuration
contains(CONFIG, clickphotobackup) {
    DEFINES += GHOSTCLOUD_UBUNTU_TOUCH_PHOTOBACKUP
    CONFIG += ghostcloud_link
}

contains(CONFIG, ghostcloud_link) {
    LIBS += $$OUT_PWD/../../3rdparty/qwebdavlib/qwebdavlib/libqwebdav.so.1
    LIBS += $$OUT_PWD/../../src/common/libharbourowncloudcommon.so.1
}
