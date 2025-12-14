// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
//import QtQuick 1.1
import QtQuick 2.3

Rectangle {
    id: root
    
    // Store winning positions to draw lines
    property var winningPositions: []
    property int lastWinAmount: 0
    property bool showLinePatterns: false
    property int currentLines: engine ? engine.lines : 1
    
    function getSlotPosition(r, c) {
        var slots = [[r0c0, r0c1, r0c2, r0c3, r0c4],
                     [r1c0, r1c1, r1c2, r1c3, r1c4],
                     [r2c0, r2c1, r2c2, r2c3, r2c4]]
        var slot = slots[r][c]
        return Qt.point(slot.x + slot.width/2, slot.y + slot.height/2)
    }
    
    // Timer to hide line patterns after showing them
    Timer {
        id: linePatternTimer
        interval: 3000
        onTriggered: showLinePatterns = false
    }
    
    // Timers to stop reels one by one
    Timer {
        id: stopReel0Timer
        interval: 150
        onTriggered: {
            r0c0.stopRolling()
            r1c0.stopRolling()
            r2c0.stopRolling()
        }
    }
    
    Timer {
        id: stopReel1Timer
        interval: 300
        onTriggered: {
            r0c1.stopRolling()
            r1c1.stopRolling()
            r2c1.stopRolling()
        }
    }
    
    Timer {
        id: stopReel2Timer
        interval: 450
        onTriggered: {
            r0c2.stopRolling()
            r1c2.stopRolling()
            r2c2.stopRolling()
        }
    }
    
    Timer {
        id: stopReel3Timer
        interval: 600
        onTriggered: {
            r0c3.stopRolling()
            r1c3.stopRolling()
            r2c3.stopRolling()
        }
    }
    
    Timer {
        id: stopReel4Timer
        interval: 750
        onTriggered: {
            r0c4.stopRolling()
            r1c4.stopRolling()
            r2c4.stopRolling()
        }
    }
    
    Connections {
        target: engine
        
        // Show line patterns when lines change
        function onSelectedLinesChanged(count) {
            currentLines = count
            showLinePatterns = true
            linePatternsCanvas.requestPaint()
            linePatternTimer.restart()
        }
        
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
            
            // Start stopping reels one by one
            stopReel0Timer.start()
            stopReel1Timer.start()
            stopReel2Timer.start()
            stopReel3Timer.start()
            stopReel4Timer.start()
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
            showLinePatterns = false
            linePatternsCanvas.requestPaint()
            linePatternTimer.stop()
            winAmountDisplay.hide()
            
            // Stop all stop timers if running
            stopReel0Timer.stop()
            stopReel1Timer.stop()
            stopReel2Timer.stop()
            stopReel3Timer.stop()
            stopReel4Timer.stop()
            
            // Start rolling animation on all slots
            r0c0.startRolling(); r0c1.startRolling(); r0c2.startRolling(); r0c3.startRolling(); r0c4.startRolling()
            r1c0.startRolling(); r1c1.startRolling(); r1c2.startRolling(); r1c3.startRolling(); r1c4.startRolling()
            r2c0.startRolling(); r2c1.startRolling(); r2c2.startRolling(); r2c3.startRolling(); r2c4.startRolling()
            
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
        
        function onBonusTriggered(spins) {
            console.log("BONUS TRIGGERED:", spins, "free spins")
            bonusDisplay.showBonus(spins)
        }
        
        function onFreeSpinsComplete(totalWon) {
            console.log("FREE SPINS COMPLETE, won:", totalWon)
            freeSpinsCompleteDisplay.show(totalWon)
        }
    }

    width: 800
    height: 600
    color: "#020202"
    
    Item {
        id: gameScaler
        width: 480
        height: 360
        anchors.centerIn: parent
        scale: Math.min(parent.width / width, parent.height / height)

    // Bonus triggered display
    Item {
        id: bonusDisplay
        anchors.fill: board
        opacity: 0
        z: 101
        
        property int bonusSpins: 0
        
        function showBonus(spins) {
            bonusSpins = spins
            opacity = 1
            bonusAnimation.restart()
        }
        
        SequentialAnimation {
            id: bonusAnimation
            ParallelAnimation {
                NumberAnimation {
                    target: bonusText
                    property: "scale"
                    from: 0.3
                    to: 1.8
                    duration: 600
                    easing.type: Easing.OutElastic
                }
                NumberAnimation {
                    target: bonusText
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 400
                }
            }
            PauseAnimation { duration: 1500 }
            ParallelAnimation {
                NumberAnimation {
                    target: bonusText
                    property: "scale"
                    to: 0.3
                    duration: 400
                    easing.type: Easing.InBack
                }
                NumberAnimation {
                    target: bonusText
                    property: "opacity"
                    to: 0
                    duration: 400
                }
            }
            ScriptAction {
                script: bonusDisplay.opacity = 0
            }
        }
        
        Rectangle {
            anchors.centerIn: parent
            width: bonusText.width + 60
            height: bonusText.height + 40
            color: "#60000000"
            border.color: "#FF44FF"
            border.width: 4
            radius: 20
            opacity: bonusText.opacity
            scale: bonusText.scale * 0.95
            
            SequentialAnimation on border.color {
                running: bonusDisplay.opacity > 0
                loops: Animation.Infinite
                ColorAnimation { to: "#FF88FF"; duration: 400 }
                ColorAnimation { to: "#FF44FF"; duration: 400 }
            }
        }
        
        Column {
            id: bonusText
            anchors.centerIn: parent
            spacing: 5
            scale: 1.0
            
            Text {
                text: "★ BONUS! ★"
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#FF44FF"
                font.pixelSize: 32
                font.bold: true
                style: Text.Outline
                styleColor: "#000000"
            }
            
            Text {
                text: bonusDisplay.bonusSpins + " FREE SPINS!"
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#FFD700"
                font.pixelSize: 24
                font.bold: true
                style: Text.Outline
                styleColor: "#000000"
            }
        }
    }
    
    // Free Spins Complete display
    Item {
        id: freeSpinsCompleteDisplay
        anchors.fill: board
        opacity: 0
        z: 101
        
        property int totalWon: 0
        
        function show(won) {
            totalWon = won
            opacity = 1
            completeAnimation.restart()
        }
        
        SequentialAnimation {
            id: completeAnimation
            ParallelAnimation {
                NumberAnimation {
                    target: completeText
                    property: "scale"
                    from: 0.5
                    to: 1.5
                    duration: 500
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    target: completeText
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 400
                }
            }
            PauseAnimation { duration: 2500 }
            ParallelAnimation {
                NumberAnimation {
                    target: completeText
                    property: "scale"
                    to: 2.0
                    duration: 500
                    easing.type: Easing.InBack
                }
                NumberAnimation {
                    target: completeText
                    property: "opacity"
                    to: 0
                    duration: 500
                }
            }
            ScriptAction {
                script: freeSpinsCompleteDisplay.opacity = 0
            }
        }
        
        Rectangle {
            anchors.centerIn: parent
            width: completeText.width + 60
            height: completeText.height + 40
            color: "#60000000"
            border.color: "#44FF44"
            border.width: 4
            radius: 20
            opacity: completeText.opacity
            scale: completeText.scale * 0.95
            
            SequentialAnimation on border.width {
                running: freeSpinsCompleteDisplay.opacity > 0
                loops: Animation.Infinite
                NumberAnimation { to: 6; duration: 500; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 4; duration: 500; easing.type: Easing.InOutQuad }
            }
        }
        
        Column {
            id: completeText
            anchors.centerIn: parent
            spacing: 8
            scale: 1.0
            
            Text {
                text: "FREE SPINS COMPLETE!"
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#44FF44"
                font.pixelSize: 24
                font.bold: true
                style: Text.Outline
                styleColor: "#000000"
            }
            
            Text {
                text: "Won: " + freeSpinsCompleteDisplay.totalWon
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#FFD700"
                font.pixelSize: 32
                font.bold: true
                style: Text.Outline
                styleColor: "#000000"
                
                SequentialAnimation on scale {
                    running: freeSpinsCompleteDisplay.opacity > 0
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.1; duration: 400; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 400; easing.type: Easing.InOutQuad }
                }
            }
        }
    }
    
    // Flashy win amount display
    Item {
        id: winAmountDisplay
        anchors.fill: board
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
        anchors.bottom: controlPanel.top
        anchors.bottomMargin: 10
        color: "#020202"

        // Canvas for drawing active line patterns
        Canvas {
            id: linePatternsCanvas
            anchors.fill: parent
            z: 9
            opacity: showLinePatterns ? 0.8 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            function drawLine(ctx, pattern, color, lineNum) {
                ctx.strokeStyle = color
                ctx.lineWidth = 3
                ctx.lineCap = "round"
                ctx.shadowColor = color
                ctx.shadowBlur = 8
                
                ctx.beginPath()
                var firstPos = getSlotPosition(pattern[0][0], pattern[0][1])
                ctx.moveTo(firstPos.x, firstPos.y)
                
                for(var i = 1; i < pattern.length; i++) {
                    var pos = getSlotPosition(pattern[i][0], pattern[i][1])
                    ctx.lineTo(pos.x, pos.y)
                }
                
                ctx.stroke()
                
                // Draw line number at the start
                ctx.fillStyle = color
                ctx.font = "bold 14px sans-serif"
                ctx.shadowBlur = 4
                ctx.fillText(lineNum.toString(), firstPos.x - 25, firstPos.y + 5)
            }
            
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                
                if(!showLinePatterns || currentLines <= 0) return
                
                // Define all 9 line patterns (row, col)
                var linePatterns = [
                    [[1,0], [1,1], [1,2], [1,3], [1,4]], // Line 1: Middle row
                    [[0,0], [0,1], [0,2], [0,3], [0,4]], // Line 2: Top row
                    [[2,0], [2,1], [2,2], [2,3], [2,4]], // Line 3: Bottom row
                    [[1,0], [1,1], [2,2], [1,3], [1,4]], // Line 4: V shape
                    [[1,0], [1,1], [0,2], [1,3], [1,4]], // Line 5: ^ shape
                    [[0,0], [0,1], [1,2], [0,3], [0,4]], // Line 6: Top with dip
                    [[2,0], [2,1], [1,2], [2,3], [2,4]], // Line 7: Bottom with bump
                    [[0,0], [1,1], [0,2], [1,3], [0,4]], // Line 8: Zigzag top
                    [[2,0], [1,1], [2,2], [1,3], [2,4]]  // Line 9: Zigzag bottom
                ]
                
                var colors = [
                    "#FF4444", // Red
                    "#44FF44", // Green
                    "#4444FF", // Blue
                    "#FFFF44", // Yellow
                    "#FF44FF", // Magenta
                    "#44FFFF", // Cyan
                    "#FF8844", // Orange
                    "#88FF44", // Lime
                    "#FF4488"  // Pink
                ]
                
                // Draw lines based on current line count
                for(var i = 0; i < Math.min(currentLines, linePatterns.length); i++) {
                    drawLine(ctx, linePatterns[i], colors[i], i + 1)
                }
            }
        }
        
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

    // Bottom control panel
    Rectangle {
        id: controlPanel
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 20
        height: 90
        color: "#1a1a1a"
        border.color: "#3a3a3a"
        border.width: 2
        radius: 8
        
        Row {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5
            
            // Credits display on the left
            Column {
                width: 100
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3
                
                Text {
                    text: qsTr("CREDITS")
                    color: "#999999"
                    font.pixelSize: 9
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Rectangle {
                    width: 85
                    height: 38
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#0a0a0a"
                    border.color: "#FFD700"
                    border.width: 2
                    radius: 4
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: addCreditsDialog.visible = true
                    }

                    Text {
                        id: creditsText
                        text: engine ? engine.credits : "0"
                        color: "#FFD700"
                        font.pixelSize: 20
                        font.bold: true
                        anchors.centerIn: parent
                    }
                }
            }
            
            // Bet and Lines controls with total bet display
            Column {
                width: 200
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                
                // Total bet display at the top
                Rectangle {
                    id: totalBetDisplay
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 150
                    height: 20
                    color: "#2a2a2a"
                    border.color: "#FFD700"
                    border.width: 1
                    radius: 3
                    
                    Text {
                        anchors.centerIn: parent
                        text: engine ? "TOTAL BET: " + (engine.bet * engine.lines) : "TOTAL BET: 0"
                        color: "#FFD700"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
                
                // Row with bet and lines controls
                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    // Bet controls
                    Column {
                        spacing: 3
                        
                        Text {
                            text: qsTr("BET")
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#999999"
                            font.pixelSize: 9
                            font.bold: true
                        }
                        
                        Row {
                            spacing: 2
                            
                            Rectangle {
                                id: decreaseBetButton
                                width: 26
                                height: 26
                                radius: 3
                                color: decreaseBetMouseArea.pressed ? "#4a4a4a" : (decreaseBetMouseArea.containsMouse ? "#3a3a3a" : "#2a2a2a")
                                border.color: "#555555"
                                border.width: 1
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                                
                                Text {
                                    text: qsTr("−")
                                    anchors.centerIn: parent
                                    color: "#dedede"
                                    font.pixelSize: 16
                                    font.bold: true
                                }

                                MouseArea {
                                    id: decreaseBetMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (engine) {
                                            engine.bet = Math.max(1, engine.bet - 1)
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: 32
                                height: 26
                                radius: 3
                                color: "#0a0a0a"
                                border.color: "#FFD700"
                                border.width: 1
                                
                                Text {
                                    text: engine ? engine.bet : "0"
                                    anchors.centerIn: parent
                                    color: "#FFD700"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                id: increaseBetButton
                                width: 26
                                height: 26
                                radius: 3
                                color: increaseBetMouseArea.pressed ? "#4a4a4a" : (increaseBetMouseArea.containsMouse ? "#3a3a3a" : "#2a2a2a")
                                border.color: "#555555"
                                border.width: 1
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                                
                                Text {
                                    text: qsTr("+")
                                    anchors.centerIn: parent
                                    color: "#dedede"
                                    font.pixelSize: 16
                                    font.bold: true
                                }

                                MouseArea {
                                    id: increaseBetMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (engine) {
                                            engine.bet = Math.min(10, engine.bet + 1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Lines controls
                    Column {
                        spacing: 3
                        
                        Text {
                            text: qsTr("LINES")
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#999999"
                            font.pixelSize: 9
                            font.bold: true
                        }
                        
                        Row {
                            spacing: 2
                            
                            Rectangle {
                                id: decreaseLinesButton
                                width: 26
                                height: 26
                                radius: 3
                                color: decreaseLinesMouseArea.pressed ? "#4a4a4a" : (decreaseLinesMouseArea.containsMouse ? "#3a3a3a" : "#2a2a2a")
                                border.color: "#555555"
                                border.width: 1
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                                
                                Text {
                                    text: qsTr("−")
                                    anchors.centerIn: parent
                                    color: "#dedede"
                                    font.pixelSize: 16
                                    font.bold: true
                                }

                                MouseArea {
                                    id: decreaseLinesMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (engine) {
                                            engine.lines = Math.max(1, engine.lines - 1)
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: 32
                                height: 26
                                radius: 3
                                color: "#0a0a0a"
                                border.color: "#FFD700"
                                border.width: 1
                                
                                Text {
                                    text: engine ? engine.lines : "0"
                                    anchors.centerIn: parent
                                    color: "#FFD700"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                id: increaseLinesButton
                                width: 26
                                height: 26
                                radius: 3
                                color: increaseLinesMouseArea.pressed ? "#4a4a4a" : (increaseLinesMouseArea.containsMouse ? "#3a3a3a" : "#2a2a2a")
                                border.color: "#555555"
                                border.width: 1
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                                
                                Text {
                                    text: qsTr("+")
                                    anchors.centerIn: parent
                                    color: "#dedede"
                                    font.pixelSize: 16
                                    font.bold: true
                                }

                                MouseArea {
                                    id: increaseLinesMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (engine) {
                                            engine.lines = Math.min(9, engine.lines + 1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Spin button section
            Column {
                width: 140
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                
                // Spin button
                Rectangle {
                    id: spinButton
                    width: 55
                    height: 55
                    radius: 28
                    anchors.horizontalCenter: parent.horizontalCenter
                    smooth: true
                    color: (engine && engine.playable) ? "#02de02" : "#024502"
                    border.color: (engine && engine.playable) ? "#04ff04" : "#036503"
                    border.width: 3
                    scale: spinButtonMouseArea.pressed ? 0.85 : (spinButtonMouseArea.containsMouse ? 1.1 : 1.0)
                    
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
                        NumberAnimation { to: 0.8; duration: 800; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                    }
                    
                    // Inner glow
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 10
                        height: parent.height - 10
                        radius: width / 2
                        color: "transparent"
                        border.color: (engine && engine.playable) ? "#88ffffff" : "transparent"
                        border.width: 2
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        
                        Text {
                            text: (engine && engine.freeSpins > 0) ? "FREE" : qsTr("SPIN")
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: (engine && engine.freeSpins > 0) ? "#FF44FF" : "#000000"
                            font.pixelSize: (engine && engine.freeSpins > 0) ? 11 : 14
                            font.bold: true
                        }
                        
                        Text {
                            text: (engine && engine.freeSpins > 0) ? engine.freeSpins : ""
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#FFD700"
                            font.pixelSize: 16
                            font.bold: true
                            visible: engine && engine.freeSpins > 0
                        }
                    }

                    MouseArea {
                        id: spinButtonMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: engine && engine.playable
                        onClicked: {
                            if (engine) engine.spin()
                        }
                    }
                }
            }
        }
    }
    } // End of gameScaler

    // Add Credits Dialog
    Rectangle {
        id: addCreditsDialog
        anchors.fill: parent
        color: "#aa000000"
        visible: false
        z: 100
        
        MouseArea {
            anchors.fill: parent
            onClicked: addCreditsDialog.visible = false
        }
        
        Rectangle {
            width: 350
            height: 200
            anchors.centerIn: parent
            color: "#2a2a2a"
            border.color: "#FFD700"
            border.width: 2
            radius: 10
            
            Column {
                anchors.centerIn: parent
                spacing: 20
                
                Text {
                    text: "ADD CREDITS"
                    color: "#FFD700"
                    font.pixelSize: 24
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Row {
                    spacing: 15
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    // 100 Button
                    Rectangle {
                        width: 80
                        height: 40
                        color: "#444"
                        radius: 5
                        border.color: "#888"
                        
                        Text {
                            text: "100"
                            color: "white"
                            anchors.centerIn: parent
                            font.bold: true
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                engine.credits += 100
                                addCreditsDialog.visible = false
                            }
                        }
                    }
                    
                    // 500 Button
                    Rectangle {
                        width: 80
                        height: 40
                        color: "#444"
                        radius: 5
                        border.color: "#888"
                        
                        Text {
                            text: "500"
                            color: "white"
                            anchors.centerIn: parent
                            font.bold: true
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                engine.credits += 500
                                addCreditsDialog.visible = false
                            }
                        }
                    }
                    
                    // 1000 Button
                    Rectangle {
                        width: 80
                        height: 40
                        color: "#444"
                        radius: 5
                        border.color: "#888"
                        
                        Text {
                            text: "1000"
                            color: "white"
                            anchors.centerIn: parent
                            font.bold: true
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                engine.credits += 1000
                                addCreditsDialog.visible = false
                            }
                        }
                    }
                }
                
                Rectangle {
                    width: 100
                    height: 30
                    color: "#662222"
                    radius: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Text {
                        text: "CANCEL"
                        color: "white"
                        anchors.centerIn: parent
                        font.pixelSize: 12
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: addCreditsDialog.visible = false
                    }
                }
            }
        }
    }
}
