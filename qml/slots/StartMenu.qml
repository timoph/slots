// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {
    id: base
    color: "#020202"
    property bool gameOnGoing: false
    signal startGame()

    Text {
        id: titleText
        color: "#dedede"
        text: qsTr("Slots")
        font.pixelSize: 92
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
    }

    Column {
        id: buttonColumn
        anchors.top: titleText.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 15

        MyButton {
            id: resumeButton
            width: 120
            height: 40
            label: "Resume game"
            visible: base.gameOnGoing && engine.credits > 0

            onMyButtonClicked: {
                startGame()
            }
        }

        MyButton {
            id: playButton
            width: 120
            height: 40
            label: "New game"

            onMyButtonClicked: {
                base.gameOnGoing = true
                engine.credits = 100
                engine.message = ""
                engine.lines = 9
                engine.bet = 1
                startGame()
            }
        }

        MyButton {
            id: aboutButton
            width: 120
            height: 40
            label: "About"

            onMyButtonClicked: {
                aboutRect.opacity = 100
            }
        }
    }

    Text {
        id: copyText
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        width: parent.width
        color: "#dedede"
        horizontalAlignment: Text.AlignHCenter
        text: "(c) 2012 - Timo Härkönen\ntimop.harkonen@gmail.com"
    }

    Rectangle {
        id: aboutRect
        anchors.fill: parent
        color: "#020202"
        opacity: 0

        Behavior on opacity {
            NumberAnimation { duration: 800 }
        }

        TextEdit {
            id: aboutText
            enabled: false
            text: "TODO"
            color: "#dedede"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MyButton {
            id: closeAboutButton
            width: 120
            height: 40
            label: "ok"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: aboutText.bottom
            anchors.topMargin: 20

            onMyButtonClicked: {
                aboutRect.opacity = 0
            }
        }
    }
}
