// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
//import QtQuick 1.1
import QtQuick 2.3

Rectangle {
    id: root
    
    // Store winning positions to draw lines
    property var winningPositions: []
    property int lastWinAmount: 0
    
    function getSlotPosition(r, c) {
        var slots = [[r0c0, r0c1, r0c2, r0c3, r0c4],
                     [r1c0, r1c1, r1c2, r1c3, r1c4],
                     [r2c0, r2c1, r2c2, r2c3, r2c4]]
        var slot = slots[r][c]
        return Qt.point(slot.x + slot.width/2, slot.y + slot.height/2)
    }
    
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
            console.log("WIN at:", r, c)
            
            // Add to winning positions for line drawing
            winningPositions.push({r: r, c: c})
            winLineCanvas.requestPaint()
            
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

        function onWin(amount) {
            lastWinAmount = amount * (engine ? engine.bet : 1)
            winAmountDisplay.show()
        }
        
        function onSpinStarted() {
            winningPositions = []
            winLineCanvas.requestPaint()
            winAmountDisplay.hide()
            
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
    
    // Credits display with golden style
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 5
        width: creditsText.width + 20
        height: creditsText.height + 10
        color: "#1a1a1a"
        border.color: "#FFD700"
        border.width: 2
        radius: 5
        
        Text {
            id: creditsText
            text: engine ? engine.credits : "0"
            color: "#FFD700"
            font.pixelSize: 24
            font.bold: true
            anchors.centerIn: parent
        }
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
    
    // Flashy win amount display
    Item {
        id: winAmountDisplay
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        opacity: 0
        z: 100
        
        function show() {
            opacity = 1
            showAnimation.restart()
        }
        
        function hide() {
            opacity = 0
        }
        
        SequentialAnimation {
            id: showAnimation
            ParallelAnimation {
                NumberAnimation {
                    target: winText
                    property: "scale"
                    from: 0.5
                    to: 1.5
                    duration: 400
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    target: winText
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 300
                }
            }
            PauseAnimation { duration: 1500 }
            ParallelAnimation {
                NumberAnimation {
                    target: winText
                    property: "scale"
                    to: 2.0
                    duration: 400
                    easing.type: Easing.InBack
                }
                NumberAnimation {
                    target: winText
                    property: "opacity"
                    to: 0
                    duration: 400
                }
            }
            ScriptAction {
                script: winAmountDisplay.hide()
            }
        }
        
        // Glow background
        Rectangle {
            anchors.centerIn: parent
            width: winText.width + 80
            height: winText.height + 40
            color: "#40000000"
            border.color: "#FFD700"
            border.width: 3
            radius: 15
            opacity: winText.opacity
            scale: winText.scale * 0.9
            
            SequentialAnimation on border.width {
                running: winAmountDisplay.opacity > 0
                loops: Animation.Infinite
                NumberAnimation { to: 5; duration: 600; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 3; duration: 600; easing.type: Easing.InOutQuad }
            }
        }
        
        Text {
            id: winText
            text: "+ " + lastWinAmount
            anchors.centerIn: parent
            color: "#FFD700"
            font.pixelSize: 56
            font.bold: true
            style: Text.Outline
            styleColor: "#000000"
            scale: 1.0
            
            SequentialAnimation on color {
                running: winAmountDisplay.opacity > 0
                loops: Animation.Infinite
                ColorAnimation { to: "#FFF700"; duration: 400 }
                ColorAnimation { to: "#FFD700"; duration: 400 }
            }
        }
    }

    Rectangle {
        id: board
        width: 80 * 5
        height: 80 * 3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: spinButton.top
        anchors.bottomMargin: 30
        color: "#020202"

        // Canvas for drawing winning lines
        Canvas {
            id: winLineCanvas
            anchors.fill: parent
            z: 10
            
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                
                if(winningPositions.length > 0) {
                    // Draw line connecting all winning positions
                    ctx.strokeStyle = "#FFD700"
                    ctx.lineWidth = 4
                    ctx.lineCap = "round"
                    ctx.shadowColor = "#FFD700"
                    ctx.shadowBlur = 10
                    
                    ctx.beginPath()
                    var firstPos = getSlotPosition(winningPositions[0].r, winningPositions[0].c)
                    ctx.moveTo(firstPos.x, firstPos.y)
                    
                    for(var i = 1; i < winningPositions.length; i++) {
                        var pos = getSlotPosition(winningPositions[i].r, winningPositions[i].c)
                        ctx.lineTo(pos.x, pos.y)
                    }
                    
                    ctx.stroke()
                }
            }
        }

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
