import QtQuick 1.1

Item {
    id: base
    property string label: ""
    signal myButtonClicked()

    Rectangle {
        id: button
        width: 120
        height: 40
        radius: 5
        smooth: true
        color: "#454545"

        Behavior on color {
            ColorAnimation {
                duration: 50
            }
        }

        Timer {
            id: clickTimer
            repeat: false
            interval: 100
            onTriggered: {
                button.color = "#454545"
            }
        }

        Text {
            id: spinButtonText
            text: base.label
            anchors.centerIn: parent
            color: "#dedede"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                button.color = "#252525"
                clickTimer.start()
                myButtonClicked()
            }
        }
    }
}
