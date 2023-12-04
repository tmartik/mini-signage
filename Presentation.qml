import QtQuick 2.0

Item {
    property bool showFilename: false
    property int slideDuration: 2        // In seconds

    property bool running: true          // Master enable
    property int fadeDuration: 2         // In seconds
    property int showSlideIndex: 0
    property var slides: []

    property int margin: 32

    Repeater {
        id: slideRepeater
        model: slides
        delegate: Item {
            id: slide
            anchors.fill: parent
            opacity: 0
            property bool shown: state === "shown"
            states: [
                State {
                    name: "shown"
                    when: showSlideIndex === index
                    PropertyChanges {
                        target: slide
                        opacity: 1
                    }
                },
                State {
                    name: "hidden"
                    when: showSlideIndex !== index
                    PropertyChanges {
                        target: slide
                        opacity: 0
                    }
                }
            ]
            transitions: Transition {
                onRunningChanged: {
                    if(running === false && shown === true && delay.running === false) {
                        var duration = loader.item.duration || slideDuration * 1000
                        delay.after(Math.max(1000, duration))
                    }
                }
                NumberAnimation {
                    properties: "opacity"
                    duration: fadeDuration * 1000
                }
            }
            onShownChanged: {
                if(shown) {
                    console.log('SHOWING SLIDE: ' + modelData.filename.toString())

                    loader.item.fadeDuration = fadeDuration * 1000  // Video slide needs to know the fade duration
                    loader.item.prepare()
                }
            }

            Loader {
                id: loader
                property var slide: modelData
                anchors.fill: parent
                source: modelData.type === 'blank' ? 'SlideBlank.qml' :
                        modelData.type === 'image' ? 'SlideStill.qml' :
                        modelData.type === 'video' ? 'SlideVideo.qml' : undefined
            }
        }
    }

    // Show current filename for testing
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: margin
        height: text.implicitHeight
        color: 'yellow'
        opacity: 0.75
        visible: showFilename

        Text {
            id: text
            property var slide: slides[showSlideIndex]
            property string filename: slide ? slide.filename : ''
            anchors.left: parent.left
            anchors.right: parent.right
            text: qsTr("%1 %2\nShowing file: %3").arg(Qt.application.displayName).arg(Qt.application.version).arg(filename)
        }
    }

    // Change slide after a delay
    Timer {
        id: delay
        onTriggered: {
            // Play next slide
            nextSlide()
        }

        function after(ms) {
            ms = Math.max(ms, 0)
            console.log('Next slide in ' + ms + ' ms')
            interval = ms
            restart()
        }
    }

    function nextSlide() {
        showSlideIndex++
        if(showSlideIndex >= slides.length) {
            showSlideIndex = 0
        }
    }
}

