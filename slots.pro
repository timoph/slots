TEMPLATE = app
TARGET = slots

contains(QT_VERSION, ^4.*) {
    QT += core gui declarative
    message("building for Qt4")
}

contains(QT_VERSION, ^5.*) {
    QT += core widgets quick
    DEFINES += QT5BUILD
    message("building for Qt5")
}

SOURCES += main.cpp \
    gameengine.cpp \
    imageprovider.cpp
HEADERS += \
    gameengine.h \
    imageprovider.h

OTHER_FILES += \
    qml/slots/main.qml \
    qml/slots/SlotItem.qml \
    qml/slots/StartMenu.qml \
    qml/slots/MyButton.qml

RESOURCES += \
    resources.qrc
