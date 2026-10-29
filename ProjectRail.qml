import QtQuick
import qs.Commons

Item {
    id: root

    property var projects: []
    property var pageTitles: ({})
    property string currentProjectId: ""
    property string currentPageId: ""
    property string editingProjectId: ""
    property QtObject theme

    signal projectSelected(string projectId)
    signal pageSelected(string pageId)
    signal newProjectRequested()
    signal newPageRequested(string projectId)
    signal projectTitleCommitted(string projectId, string title)

    implicitWidth: 224
    implicitHeight: 480

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius
        color: root.theme.background
        border.width: root.theme.borderWidth
        border.color: root.theme.border
    }

    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Item {
            width: parent.width
            height: Math.max(28, chapterLabel.implicitHeight)

            Text {
                id: chapterLabel
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "CHAPTERS"
                color: root.theme.text
                font.family: "monospace"
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.2
            }

            ToolButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                theme: root.theme
                icon: "󰐕"
                text: "New chapter"
                onActivated: root.newProjectRequested()
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: root.theme.divider
        }

        Flickable {
            id: chapterScroller
            width: parent.width
            height: parent.height - y
            contentWidth: width
            contentHeight: chapters.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: chapters
                width: chapterScroller.width
                spacing: 8

                Repeater {
                    model: root.projects

                    delegate: Item {
                        required property var modelData
                        width: chapters.width
                        height: projectTitleRow.height + projectPages.implicitHeight + 4

                        Item {
                            id: projectTitleRow
                            width: parent.width
                            height: 30

                            Rectangle {
                                anchors.fill: parent
                                radius: 5
                                color: modelData.id === root.currentProjectId ? root.theme.selectedFill : "transparent"
                            }

                            Text {
                                id: projectLabel
                                visible: root.editingProjectId !== modelData.id
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.right: addPageButton.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.title
                                color: root.theme.text
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }

                            TextInput {
                                id: projectEditor
                                z: 2
                                visible: root.editingProjectId === modelData.id
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.right: addPageButton.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.title
                                color: root.theme.text
                                font.pixelSize: 13
                                selectByMouse: true
                                onAccepted: root.finishProjectEdit(modelData.id, text)
                                onEditingFinished: {
                                    if (root.editingProjectId === modelData.id)
                                        root.finishProjectEdit(modelData.id, text)
                                }
                            }

                            ToolButton {
                                id: addPageButton
                                z: 3
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                theme: root.theme
                                icon: "󰐕"
                                text: "New page"
                                onActivated: root.newPageRequested(modelData.id)
                            }

                            MouseArea {
                                z: 1
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                onClicked: root.projectSelected(modelData.id)
                                onDoubleClicked: {
                                    root.editingProjectId = modelData.id
                                    projectEditor.forceActiveFocus()
                                    projectEditor.selectAll()
                                }
                            }
                        }

                        Column {
                            id: projectPages
                            anchors.top: projectTitleRow.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 2

                            Repeater {
                                model: modelData.pageIds

                                delegate: Item {
                                    required property string modelData
                                    width: projectPages.width
                                    height: 26

                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        radius: 4
                                        color: modelData === root.currentPageId ? root.theme.selectedFill : "transparent"
                                    }

                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 18
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: root.pageTitles[modelData] || "Untitled page"
                                        color: modelData === root.currentPageId ? root.theme.selectedIcon : root.theme.subtle
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        acceptedButtons: Qt.LeftButton
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.pageSelected(modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function finishProjectEdit(projectId, title) {
        root.editingProjectId = ""
        root.projectTitleCommitted(projectId, title)
    }
}
