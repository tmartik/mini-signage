import QtQuick 2.15

Slide {
    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: slide.filename
    }
}
