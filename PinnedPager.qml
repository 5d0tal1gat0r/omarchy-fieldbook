import QtQuick

Item {
    id: root

    property QtObject theme
    property int currentPage: 1
    property int pageCount: 1
    property bool previousEnabled: false
    property bool nextEnabled: false

    signal previousRequested()
    signal nextRequested()

    implicitWidth: 112
    implicitHeight: 36

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: root.theme.background
        border.width: root.theme.borderWidth
        border.color: root.theme.border
        opacity: 0.96
    }

    Row {
        anchors.fill: parent
        anchors.margins: 3
        spacing: 2

        Rectangle {
            width: 32
            height: parent.height
            radius: 5
            color: previousMouse.containsMouse && root.previousEnabled ? root.theme.hoverFill : "transparent"
            opacity: root.previousEnabled ? 1 : 0.35

            Text {
                anchors.centerIn: parent
                text: "‹"
                color: root.theme.icon
                font.pixelSize: 23
                font.bold: true
            }

            MouseArea {
                id: previousMouse
                anchors.fill: parent
                enabled: root.previousEnabled
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.previousRequested()
            }
        }

        Text {
            width: 38
            height: parent.height
            text: root.currentPage + "/" + root.pageCount
            color: root.theme.subtle
            font.family: "monospace"
            font.pixelSize: 10
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle {
            width: 32
            height: parent.height
            radius: 5
            color: nextMouse.containsMouse && root.nextEnabled ? root.theme.hoverFill : "transparent"
            opacity: root.nextEnabled ? 1 : 0.35

            Text {
                anchors.centerIn: parent
                text: "›"
                color: root.theme.icon
                font.pixelSize: 23
                font.bold: true
            }

            MouseArea {
                id: nextMouse
                anchors.fill: parent
                enabled: root.nextEnabled
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.nextRequested()
            }
        }
    }
}
