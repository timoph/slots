// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {
    property int value: 0
    property color itemcolor: "#dedede"
    width: 80
    height: 80
    color: "#020202"
    border.color: "#efefef"
    border.width: 0
    Text {
        id: txt
        color: parent.itemcolor
        text: parent.value
        font.pixelSize: 48
        anchors.centerIn: parent

        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
}
