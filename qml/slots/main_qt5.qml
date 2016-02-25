// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
//import QtQuick 1.1
import QtQuick 2.3

Rectangle {
    Connections {
        target: engine
        // update items from engine
        onSlotsSpinned: {
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

        onWinningSlot: {
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

        onSpinStarted: {
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
        text: "credits: " + engine.credits
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
        color: "#020202"

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }

        Text {
            id: menuButtonText
            text: qsTr("Menu")
            anchors.centerIn: parent
            color: "#dedede"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                startmenu.opacity = 100
            }
        }
    }

    Text {
        text: engine.credits === 0 ? "You are broke :(" : engine.message
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
        text: "Total bet: " + engine.bet * engine.lines
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
        color: engine.playable ? "#02de02" : "#024502"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }

        Text {
            id: spinButtonText
            text: qsTr("Spin")
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            enabled: engine.playable
            onClicked: {
                engine.spin()
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
                onClicked: engine.bet === 1 ? engine.bet = 1 : engine.bet = engine.bet - 1
            }
        }

        Rectangle {
            id: betRect
            width: 40
            height: 30
            color: "#020202"
            Text {
                id: betValueText
                text: engine.bet
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
                onClicked: engine.bet === 10 ? engine.bet = 10 : engine.bet = engine.bet + 1
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
                onClicked: engine.lines === 1 ? engine.lines = 1 : engine.lines = engine.lines - 1
            }
        }

        Rectangle {
            id: linesRect
            width: 40
            height: 30
            color: "#020202"
            Text {
                id: linesText
                text: engine.lines
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
                onClicked: engine.lines === 9 ? engine.lines = 9 : engine.lines = engine.lines + 1
            }
        }
    }

    StartMenu {
        id: startmenu
        anchors.fill: parent
        visible: true
        opacity: 100
        onStartGame: {
            opacity = 0
        }

        Behavior on opacity {
            NumberAnimation { duration: 1000 }
        }
    }
}
