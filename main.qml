/**

  Mini Signage

  Command line parameters:
  mini-signage.exe config.json

  */

import QtQuick 2.15
import QtQuick.Window 2.15
import QtMultimedia 5.13

import Qt.labs.folderlistmodel 2.15

Window {
    property string configPath: Qt.application.arguments.slice(1)[0] || "config.json"

    property var config: ({})

    property bool fullScreen: config.fullscreen || false                                // Enable fullscreen
    property bool blank: config.blank || false                                          // Enable blank screen between slides
    property bool verbose: config.verbose || false                                      // Show path of the current slide
    property string slideShowPath: config.path || "slides"                              // Path to the files of the slideshow as URL
    property int slideInterval: config.interval || 5                                    // How many seconds to show each slide (except videos)
    property int showDailyAfterHour: (config.daily || {}).after || 0                    // Show slides only after this hour of day
    property int showDailyUntilHour: (config.daily || {}).until || 24                   // Show slides only before this hour of day
    property var stillExtensions: (config.extensions || {}).still || ["jpg"]            // Supported image file types
    property var videoExtensions: (config.extensions || {}).video || ["avi", "mp4"]     // Supported video file types

    width: 640
    height: 480
    flags: Qt.WindowStaysOnTopHint
    visible: true
    visibility: fullScreen ? Window.FullScreen : Window.Windowed
    title: qsTr("%1 %2").arg(Qt.application.displayName).arg(Qt.application.version)
    color: 'black'

    Presentation {
        id: presentation
        anchors.fill: parent
        running: visible
        showFilename: verbose
        slideDuration: slideInterval

        onShowSlideIndexChanged: {
            if(showSlideIndex === 0) {
                loadConfigFile(configPath)
            }
        }
    }

    // Show error message
    Rectangle {
        id: errorMessage
        anchors.bottom: parent.bottom
        width: parent.width
        height: 16
        color: 'red'
        opacity: 0.75
        visible: false

        Text {
            id: text
            anchors.fill: parent
            color: 'white'
        }

        function show(message) {
            visible = true
            text.text = message.toString()
        }

        function hide() {
            visible = false
        }
    }

    // Hide mouse cursor
    MouseArea {
       anchors.fill: parent
       enabled: false
       cursorShape: Qt.BlankCursor
    }

    // Keyboard shortcuts
    Shortcut {
        sequence: "Escape"
        onActivated: Qt.quit()
    }

    Shortcut {
        sequence: "F11"
        onActivated: fullScreen = !fullScreen
    }

    Component.onCompleted: loadConfigFile(configPath)

    onConfigChanged: Qt.callLater(function() {
        loadSlideshow()
    })

    function loadConfigFile(filename) {
        try {
            if(!FileSystem.exists(filename)) {
                throw new Error("Does not exist.")
            }

            var content = FileSystem.readFile(filename)
            config = JSON.parse(content)

            if(!FileSystem.exists(slideShowPath)) {
                throw new Error("Slideshow path '" + slideShowPath + "' does not exist.")
            }

            errorMessage.hide()
        } catch(e) {
            var message = filename + ": " + e
            console.log(message)
            errorMessage.show(message)
        }
    }

    function loadSlideshow() {
        var files = FileSystem.listFiles(slideShowPath)

        var extensions = stillExtensions.concat(videoExtensions)
        files = files.filter(function(f) {
            return extensions.indexOf(f.split('.').pop().toLowerCase()) >= 0
        })

        console.log('Slide list loaded: ' + files)

        var slideModel = []

        files.forEach(function(filename) {
            var url = FileSystem.toUrl(slideShowPath + '/' + filename)
            slideModel.push({
                                type: videoExtensions.indexOf(filename.split('.').pop().toLowerCase()) >= 0 ? 'video' : 'image',
                                filename: url
                            })
            if(blank) {
                slideModel.push({
                                    type: 'blank',
                                    filename: ''
                                })
            }
        })

        presentation.showSlideIndex = 0      // Restart from the first slide
        presentation.slides = slideModel     // Set new slides
        presentation.visible = !isQuietTime()
    }

    function isQuietTime() {
        var t = new Date()
        var after = new Date(t)
        var until = new Date(t)

        after.setHours(showDailyAfterHour)
        after.setMinutes(0)
        after.setSeconds(0)
        until.setHours(showDailyUntilHour)
        until.setMinutes(0)
        until.setSeconds(0)

        return showDailyAfterHour && showDailyUntilHour && (t.getTime() < after.getTime() || until.getTime() < t.getTime())
    }
}
