TEMPLATE = app
TARGET = slots
DESTDIR = bin

greaterThan(QT_MAJOR_VERSION, 4) {
    QT += widgets core qml quick
    DEFINES += QT5BUILD
    RESOURCES += resources_qt5.qrc
}
else {
    QT += core gui declarative
    RESOURCES += resources.qrc
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
    images.qrc


