TEMPLATE = app
TARGET = slots

QT += core gui declarative

SOURCES += main.cpp \
    gameengine.cpp
HEADERS += \
    gameengine.h

OTHER_FILES += \
    qml/slots/main.qml \
    qml/slots/SlotItem.qml \
    qml/slots/StartMenu.qml \
    qml/slots/MyButton.qml

RESOURCES += \
    resources.qrc
