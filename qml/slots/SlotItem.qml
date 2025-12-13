// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
//import QtQuick 1.1
import QtQuick 2.3

Rectangle {
    property int value: 0
    property color itemcolor: "#dedede"
    property bool isSpinning: false
    
    width: 80
    height: 80
    color: "#020202"
    border.color: itemcolor === "#ef2020" ? "#FFD700" : "#1a1a1a"
    border.width: itemcolor === "#ef2020" ? 4 : 1
    smooth: true
    clip: true
    
    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }
    
    Behavior on border.width {
        NumberAnimation { duration: 150 }
    }
    
    // Container for rolling images
    Item {
        id: rollContainer
        anchors.fill: parent
        anchors.margins: 5
        
        // Main visible image
        Image {
            id: mainImage
            source: "image://images/" + value
            width: parent.width
            height: parent.height
            smooth: true
            y: 0
            visible: value !== 1
        }
        
        // BONUS text for value 1
        Rectangle {
            id: bonusRect
            width: parent.width
            height: parent.height
            y: 0
            visible: value === 1 && !isSpinning
            color: "#2a0a2a"
            border.color: "#FF44FF"
            border.width: 2
            radius: 6
            
            Text {
                anchors.centerIn: parent
                text: "BONUS"
                color: "#FFD700"
                font.pixelSize: 16
                font.bold: true
                rotation: -15
                style: Text.Outline
                styleColor: "#FF44FF"
            }
            
            SequentialAnimation on border.color {
                running: bonusRect.visible
                loops: Animation.Infinite
                ColorAnimation { to: "#FF88FF"; duration: 400 }
                ColorAnimation { to: "#FF44FF"; duration: 400 }
            }
        }
        
        // Rolling images that appear during spin
        Image {
            id: rollingImage1
            source: "image://images/" + ((value + 1) % 5 + 1)
            width: parent.width
            height: parent.height
            smooth: true
            y: -parent.height
            visible: isSpinning
        }
        
        Image {
            id: rollingImage2
            source: "image://images/" + ((value + 2) % 5 + 1)
            width: parent.width
            height: parent.height
            smooth: true
            y: -parent.height * 2
            visible: isSpinning
        }
        
        Image {
            id: rollingImage3
            source: "image://images/" + ((value + 3) % 5 + 1)
            width: parent.width
            height: parent.height
            smooth: true
            y: -parent.height * 3
            visible: isSpinning
        }
    }
    
    // Rolling animation
    SequentialAnimation {
        id: rollAnimation
        running: false
        loops: Animation.Infinite
        
        ParallelAnimation {
            NumberAnimation {
                targets: [mainImage, rollingImage1, rollingImage2, rollingImage3]
                property: "y"
                to: parent.height
                duration: 80
                easing.type: Easing.Linear
            }
        }
        
        ScriptAction {
            script: {
                // Reset positions
                mainImage.y = -mainImage.height
                rollingImage1.y = -rollingImage1.height * 2
                rollingImage2.y = -rollingImage2.height * 3
                rollingImage3.y = 0
                
                // Rotate images
                var temp = rollingImage3.source
                rollingImage3.source = rollingImage2.source
                rollingImage2.source = rollingImage1.source
                rollingImage1.source = mainImage.source
                mainImage.source = temp
            }
        }
    }
    
    // Handle value changes to update display
    onValueChanged: {
        if (!isSpinning) {
            mainImage.source = "image://images/" + value
            mainImage.y = 0
            bonusRect.y = 0
        }
    }
    
    // Start/stop rolling
    function startRolling() {
        isSpinning = true
        rollAnimation.start()
    }
    
    function stopRolling() {
        isSpinning = false
        rollAnimation.stop()
        mainImage.source = "image://images/" + value
        mainImage.y = 0
        bonusRect.y = 0
        rollingImage1.y = -mainImage.height
        rollingImage2.y = -mainImage.height * 2
        rollingImage3.y = -mainImage.height * 3
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
