import QtQuick

Item {
    id: root

    required property var objectData
    property bool selected: false
    property bool editing: false
    property bool selectable: false
    property bool editable: false
    property bool dragStarted: false

    signal selectedRequested(string id)
    signal editRequested(string id)
    signal commitRequested(string id, string text)
    signal cancelRequested(string id)
    signal moveRequested(string id, real x, real y)

    x: objectData.x
    y: objectData.y
    width: objectData.width
    height: objectData.height
    z: 21

    readonly property color noteColor: ({
        yellow: "#f4dc7a",
        pink: "#f1a6b8",
        blue: "#9bc9e8",
        green: "#a9d9a2"
    })[objectData.color] || "#f4dc7a"

    Rectangle {
        anchors.fill: parent
        radius: 2
        color: root.noteColor
        border.width: root.editing || root.selected ? 2 : 1
        border.color: root.editing ? "#7a6037" : root.selected ? "#b18d52" : "#806b38"
        rotation: -1.2
    }

    TextEdit {
        id: editor
        anchors.fill: parent
        anchors.margins: 12
        enabled: root.editing
        text: root.objectData.text
        color: "#423e38"
        font.family: "sans-serif"
        font.pixelSize: root.objectData.size || 16
        wrapMode: TextEdit.Wrap
        textFormat: TextEdit.PlainText
        readOnly: !root.editing
        selectByMouse: root.editing
        cursorVisible: root.editing && activeFocus
        onActiveFocusChanged: {
            if (!activeFocus && root.editing)
                root.commitRequested(root.objectData.id, text)
        }
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.cancelRequested(root.objectData.id)
                event.accepted = true
            } else if ((event.modifiers & Qt.ControlModifier) && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
                root.commitRequested(root.objectData.id, text)
                event.accepted = true
            }
        }
    }

    Text {
        anchors.fill: editor
        visible: root.editing && editor.length === 0
        text: "Write a sticky note…"
        color: "#80423e38"
        font: editor.font
        wrapMode: Text.Wrap
    }

    MouseArea {
        anchors.fill: parent
        enabled: !root.editing && (root.selectable || root.editable)
        acceptedButtons: Qt.LeftButton
        cursorShape: root.editable ? Qt.IBeamCursor : Qt.SizeAllCursor
        onClicked: root.editable ? root.editRequested(root.objectData.id) : root.selectedRequested(root.objectData.id)
        onDoubleClicked: root.editRequested(root.objectData.id)
    }

    DragHandler {
        enabled: root.selectable && !root.editing
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

    onEditingChanged: {
        if (editing) {
            editor.text = objectData.text
            Qt.callLater(function() {
                if (root.editing) {
                    editor.forceActiveFocus()
                    editor.cursorPosition = editor.length
                }
            })
        } else {
            editor.text = objectData.text
        }
    }
}
