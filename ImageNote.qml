import QtQuick

Item {
    id: root

    required property var objectData
    property bool selected: false
    property bool selectable: false
    property bool dragStarted: false

    signal selectedRequested(string id)
    signal moveRequested(string id, real x, real y)

    x: objectData.x
    y: objectData.y
    width: objectData.width
    height: objectData.height
    z: 19

    Rectangle {
        anchors.fill: parent
        radius: 2
        color: "#e8ded3"
        border.width: root.selected ? 3 : 1
        border.color: root.selected ? "#b18d52" : "#8a8174"
    }

    Image {
        id: image
        anchors.fill: parent
        anchors.margins: 4
        source: root.objectData.path.indexOf("file://") === 0 ? root.objectData.path : "file://" + root.objectData.path
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        cache: false
    }

    Text {
        anchors.centerIn: parent
        visible: image.status === Image.Error || image.status === Image.Null
        text: "IMAGE\n" + root.objectData.path.split("/").pop()
        horizontalAlignment: Text.AlignHCenter
        color: "#806b6258"
        font.pixelSize: 12
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.selectable
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.SizeAllCursor
        onClicked: root.selectedRequested(root.objectData.id)
    }

    DragHandler {
        enabled: root.selectable
        target: root
        acceptedButtons: Qt.LeftButton
        xAxis.minimum: 0
        xAxis.maximum: root.parent ? Math.max(0, root.parent.width - root.width) : 0
        yAxis.minimum: 0
        yAxis.maximum: root.parent ? Math.max(0, root.parent.height - root.height) : 0
        onActiveChanged: {
            if (active) {
                root.dragStarted = true
                root.selectedRequested(root.objectData.id)
            } else if (root.dragStarted) {
                root.dragStarted = false
                root.moveRequested(root.objectData.id, root.x, root.y)
                root.x = Qt.binding(function() { return root.objectData.x })
                root.y = Qt.binding(function() { return root.objectData.y })
            }
        }
    }
}
