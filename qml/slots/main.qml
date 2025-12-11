// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
//import QtQuick 1.1
import QtQuick 2.3

Rectangle {
    Connections {
        target: engine
        // update items from engine
        function onSlotsSpinned() {
            if (!engine) return
            // 1st row
            r0c0.value = engine.itemForPlace(0, 0)
            r0c1.value = engine.itemForPlace(0, 1)
            r0c2.value = engine.itemForPlace(0, 2)
            r0c3.value = engine.itemForPlace(0, 3)
            r0c4.value = engine.itemForPlace(0, 4)
            // 2nd row
            r1c0.value = engine.itemForPlace(1, 0)
            r1c1.value = engine.itemForPlace(1, 1)
            r1c2.value = engine.itemForPlace(1, 2)
            r1c3.value = engine.itemForPlace(1, 3)
            r1c4.value = engine.itemForPlace(1, 4)
            // 3rd row
            r2c0.value = engine.itemForPlace(2, 0)
            r2c1.value = engine.itemForPlace(2, 1)
            r2c2.value = engine.itemForPlace(2, 2)
            r2c3.value = engine.itemForPlace(2, 3)
            r2c4.value = engine.itemForPlace(2, 4)
        }

        function onWinningSlot(r, c) {
            console.log(r)
            if(r === 0 && c === 0) r0c0.itemcolor = "#ef2020"
            if(r === 0 && c === 1) r0c1.itemcolor = "#ef2020"
            if(r === 0 && c === 2) r0c2.itemcolor = "#ef2020"
            if(r === 0 && c === 3) r0c3.itemcolor = "#ef2020"
            if(r === 0 && c === 4) r0c4.itemcolor = "#ef2020"

            if(r === 1 && c === 0) r1c0.itemcolor = "#ef2020"
            if(r === 1 && c === 1) r1c1.itemcolor = "#ef2020"
            if(r === 1 && c === 2) r1c2.itemcolor = "#ef2020"
            if(r === 1 && c === 3) r1c3.itemcolor = "#ef2020"
            if(r === 1 && c === 4) r1c4.itemcolor = "#ef2020"

            if(r === 2 && c === 0) r2c0.itemcolor = "#ef2020"
            if(r === 2 && c === 1) r2c1.itemcolor = "#ef2020"
            if(r === 2 && c === 2) r2c2.itemcolor = "#ef2020"
            if(r === 2 && c === 3) r2c3.itemcolor = "#ef2020"
            if(r === 2 && c === 4) r2c4.itemcolor = "#ef2020"
        }

        function onSpinStarted() {
            r0c0.itemcolor = "#dedede"
            r0c1.itemcolor = "#dedede"
            r0c2.itemcolor = "#dedede"
            r0c3.itemcolor = "#dedede"
            r0c4.itemcolor = "#dedede"

            r1c0.itemcolor = "#dedede"
            r1c1.itemcolor = "#dedede"
            r1c2.itemcolor = "#dedede"
            r1c3.itemcolor = "#dedede"
            r1c4.itemcolor = "#dedede"

            r2c0.itemcolor = "#dedede"
            r2c1.itemcolor = "#dedede"
            r2c2.itemcolor = "#dedede"
            r2c3.itemcolor = "#dedede"
            r2c4.itemcolor = "#dedede"
        }
    }

    width: 480
    height: 360
    color: "#020202"
    Text {
        text: engine ? "credits: " + engine.credits : "credits: 0"
        color: "#dedede"
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.topMargin: 5
    }

    Rectangle {
        id: menuButton
        width: 40
        height: 40
        radius: 5
        smooth: true
        color: menuButtonMouseArea.pressed ? "#404040" : "#020202"
        scale: menuButtonMouseArea.containsMouse ? 1.1 : 1.0

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
        
        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }

        Text {
            id: menuButtonText
            text: qsTr("Menu")
            anchors.centerIn: parent
            color: "#dedede"
        }

        MouseArea {
            id: menuButtonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                startmenu.opacity = 100
            }
        }
    }

    Text {
        text: engine ? (engine.credits === 0 ? "You are broke :(" : engine.message) : ""
        color: "#dedede"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 5
    }

    Rectangle {
        id: board
        width: 80 * 5
        height: 80 * 3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: spinButton.top
        anchors.bottomMargin: 30
        color: "#020202"

        Grid {
            id: slotGrid
            columns: 5
            rows: 3
            spacing: 3

            // 1st row
            SlotItem {
                id: r0c0
            }
            SlotItem {
                id: r0c1
            }
            SlotItem {
                id: r0c2
            }
            SlotItem {
                id: r0c3
            }
            SlotItem {
                id: r0c4
            }

            // second row
            SlotItem {
                id: r1c0
            }
            SlotItem {
                id: r1c1
            }
            SlotItem {
                id: r1c2
            }
            SlotItem {
                id: r1c3
            }
            SlotItem {
                id: r1c4
            }

            // 3rd row
            SlotItem {
                id: r2c0
            }
            SlotItem {
                id: r2c1
            }
            SlotItem {
                id: r2c2
            }
            SlotItem {
                id: r2c3
            }
            SlotItem {
                id: r2c4
            }
        }
    }

    Text {
        id: totalBetText
        text: engine ? "Total bet: " + engine.bet * engine.lines : "Total bet: 0"
        color: "#dedede"
        anchors.bottom: spinButton.top
        anchors.bottomMargin: 5
        anchors.horizontalCenter: spinButton.horizontalCenter
    }

    Rectangle {
        id: spinButton
        width: 50
        height: 50
        radius: 45
        smooth: true
        color: (engine && engine.playable) ? "#02de02" : "#024502"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        scale: spinButtonMouseArea.pressed ? 0.9 : 1.0

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
        
        Behavior on scale {
            SpringAnimation {
                spring: 5
                damping: 0.5
            }
        }
        
        SequentialAnimation on opacity {
            running: engine && engine.playable
            loops: Animation.Infinite
            NumberAnimation { to: 0.7; duration: 800; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
        }

        Text {
            id: spinButtonText
            text: qsTr("Spin")
            anchors.centerIn: parent
        }

        MouseArea {
            id: spinButtonMouseArea
            anchors.fill: parent
            enabled: engine && engine.playable
            onClicked: {
                if (engine) engine.spin()
            }
        }
    }

    Text {
        id: betLabel
        text: qsTr("bet")
        anchors.bottom: betRow.top
        anchors.horizontalCenter: betRow.horizontalCenter
        color: "#dedede"
    }

    // bet control
    Row {
        id: betRow
        anchors.bottom: parent.bottom
        anchors.right: spinButton.left
        anchors.rightMargin: 30
        anchors.bottomMargin: 5

        Rectangle {
            id: decreaseBetButton
            width: 40
            height: 30
            color: "#020202"
            Text {
                id: decreaseBetText
                text: qsTr("-")
                anchors.centerIn: parent
                color: "#dedede"
            }

            MouseArea {
                id: decreaseBetMouseArea
                anchors.fill: parent
                onClicked: {
                    if (engine) {
                        engine.bet === 1 ? engine.bet = 1 : engine.bet = engine.bet - 1
                    }
                }
            }
        }

        Rectangle {
            id: betRect
            width: 40
            height: 30
            color: "#020202"
            Text {
                id: betValueText
                text: engine ? engine.bet : "0"
                anchors.centerIn: parent
                color: "#dedede"
            }
        }

        Rectangle {
            id: increaseBetButton
            width: 40
            height: 30
            color: "#020202"
            Text {
                id: increaseBetText
                text: qsTr("+")
                anchors.centerIn: parent
                color: "#dedede"
            }

            MouseArea {
                id: increaseBetMouseArea
                anchors.fill: parent
                onClicked: {
                    if (engine) {
                        engine.bet === 10 ? engine.bet = 10 : engine.bet = engine.bet + 1
                    }
                }
            }
        }
    }

    Text {
        id: linesLabel
        text: qsTr("lines")
        anchors.bottom: linesRow.top
        anchors.horizontalCenter: linesRow.horizontalCenter
        color: "#dedede"
    }

    // selected lines
    Row {
        id: linesRow
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.left: spinButton.right
        anchors.leftMargin: 30

        Rectangle {
            id: decreaseLinesButton
            width: 40
            height: 30
            color: "#020202"
            Text {
                id: decreaseLinesText
                text: qsTr("-")
                anchors.centerIn: parent
                color: "#dedede"
            }

            MouseArea {
                id: decreaseLinesMouseArea
                anchors.fill: parent
                onClicked: {
                    if (engine) {
                        engine.lines === 1 ? engine.lines = 1 : engine.lines = engine.lines - 1
                    }
                }
            }
        }

        Rectangle {
            id: linesRect
            width: 40
            height: 30
            color: "#020202"
            Text {
                id: linesText
                text: engine ? engine.lines : "0"
                anchors.centerIn: parent
                color: "#dedede"
            }
        }

        Rectangle {
            id: increaseLinesButton
            width: 40
            height: 30
            color: "#020202"
            Text {
                id: increaseLinesText
                text: qsTr("+")
                anchors.centerIn: parent
                color: "#dedede"
            }

            MouseArea {
                id: increaseLinesMouseArea
                anchors.fill: parent
                onClicked: {
                    if (engine) {
                        engine.lines === 9 ? engine.lines = 9 : engine.lines = engine.lines + 1
                    }
                }
            }
        }
    }

    StartMenu {
        id: startmenu
        anchors.fill: parent
        visible: opacity > 0
        opacity: 100
        onStartGame: {
            opacity = 0
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutCubic
            }
        }
    }
}
