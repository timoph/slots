// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
//import QtQuick 1.1
import QtQuick 2.3

Rectangle {
    property int value: 0
    property color itemcolor: "#dedede"
    width: 80
    height: 80
    color: "#020202"
    border.color: itemcolor === "#ef2020" ? "#FFD700" : "#1a1a1a"
    border.width: itemcolor === "#ef2020" ? 4 : 1
    smooth: true
    
    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }
    
    Behavior on border.width {
        NumberAnimation { duration: 150 }
    }

    Image {
        id: image
        source: "image://images/" + value
        anchors.fill: parent
        anchors.margins: 5
        smooth: true
        
        Behavior on source {
            SequentialAnimation {
                NumberAnimation { target: image; property: "opacity"; to: 0; duration: 100 }
                PropertyAction { target: image; property: "source" }
                NumberAnimation { target: image; property: "opacity"; to: 1; duration: 100 }
            }
        }
    }
    
    // Golden glow effect for winners
    Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        color: "transparent"
        border.color: "#FFD700"
        border.width: itemcolor === "#ef2020" ? 2 : 0
        radius: 4
        opacity: 0.6
        
        SequentialAnimation on opacity {
            running: itemcolor === "#ef2020"
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 800; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
        }
    }
}
