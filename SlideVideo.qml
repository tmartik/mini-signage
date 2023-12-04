import QtQuick 2.15
import QtMultimedia 5.13

Slide {
    duration: video.duration > 0 ? video.duration - video.position - fadeDuration : 0

    function prepare() {
        video.play()
    }

    Video {
        id: video
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit
        source: slide.filename
        onStopped: seek(0)
    }
}
