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
                startGame()
            }
        }

        MyButton {
            id: aboutButton
            width: 120
            height: 40
            label: "Help"

            onMyButtonClicked: {
                //
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
}
