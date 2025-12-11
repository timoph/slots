// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
//import QtQuick 1.1
import QtQuick 2.3

Rectangle {
    property int value: 0
    property color itemcolor: "#dedede"
    width: 80
    height: 80
    color: "#020202"
    border.color: "#efefef"
    border.width: 0
    smooth: true
    
    scale: itemcolor === "#ef2020" ? 1.1 : 1.0
    
    Behavior on scale {
        SpringAnimation {
            spring: 3
            damping: 0.3
        }
    }

    Image {
        id: image
        source: "image://images/" + value
        anchors.fill: parent
        smooth: true
        
        Behavior on source {
            SequentialAnimation {
                NumberAnimation { target: image; property: "opacity"; to: 0; duration: 100 }
                PropertyAction { target: image; property: "source" }
                NumberAnimation { target: image; property: "opacity"; to: 1; duration: 100 }
            }
        }
    }

    Text {
        id: txt
        color: parent.itemcolor
        text: parent.value
        font.pixelSize: 48
        anchors.centerIn: parent
        opacity: 50

        Behavior on color {
            ColorAnimation { duration: 300; easing.type: Easing.OutQuad }
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: itemcolor
        border.width: itemcolor === "#ef2020" ? 3 : 0
        radius: 4
        
        Behavior on border.width {
            NumberAnimation { duration: 200 }
        }
    }
}
