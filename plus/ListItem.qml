import QtQuick 1.1
import com.nokia.symbian 1.1
import "." 1.1
import "ListStorage.js" as ListStorageJS

CustomPage {
    id: listItem

    property variant list: {'pk': 0, 'title': ''}

    function createItemForm(list) {
        var component = Qt.createComponent("ListItemFormComponent.qml");
        var sprite = component.createObject(textInputPlaceHolder, {"list": list});

        if (sprite == null) {
            // Error Handling
            console.log("Error creating object");
        }
    }

    function updateListItemComplete(index, pk, status) {
        listsItemModel.setProperty(index, "completed", status)
        listItemWorker.sendMessage({'pk': pk, 'status': status})
    }

    WorkerScript {
        id: listItemWorker
        source: "ListItemStatusWorker.js"
    }

    Rectangle {

        id: listItemListHeader
        color: "transparent"
        height: 45
        z: 10
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        Image {
            height: parent.height
            width: parent.width
            fillMode: Image.Tile
            source: "rowbg3.png"
        }

        Text {
            text: list.title
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 24
            color: "#0077aa"
            anchors {
                fill: parent
                leftMargin: 55
            }
        }

    }
    ListView {
        id: listItemListView
        snapMode: ListView.SnapToItem
        highlightFollowsCurrentItem: true
        z: 0
        anchors {
            top: listItemListHeader.bottom
            left: parent.left
            right: parent.right
            bottom: listItemToolBar.top
        }

        model: listsItemModel

        delegate: RowItem {
            height: 45

            CheckBox {
                id: checkBox
                platformInverted: true
                width: 44
                height: 44
                checked: parseInt(completed) === 0 ? false : true
                onClicked: {
                    if (checked) {
                        rowTitle.color = "#666666"
                        rowTitle.font.strikeout = true
                    } else {
                        rowTitle.color = "#222222"
                        rowTitle.font.strikeout = false
                    }

                    var status = checked ? 1 : 0
                    updateListItemComplete(index, pk, status)
                }
            }

            Text {
                id: rowTitle
                text: title
                height: 44
                font.pixelSize: 20
                font.strikeout: parseInt(completed) === 0 ? false : true
                color: parseInt(completed) === 0 ? "#222222" : "#666666"
                verticalAlignment: Text.AlignVCenter
                anchors {
                    left: checkBox.right
                    leftMargin: 10
                }
            }
        }
    }

    Rectangle {
        id: textInputPlaceHolder
        color: "transparent"
        height: 41
        z: 1
        y: 45 * (parseInt(listsItemModel.count) + 1)
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    ToolBar {
        anchors.bottom: parent.bottom
        id: listItemToolBar
        z: 1
        tools: ToolBarLayout {
            ToolButton {
                flat: true
                iconSource: "toolbar-back"
                onClicked: {
                   listPageStack.pop()
                }
            }

            ToolButton {
                property string clickMode: "add"
                id: listItemToolButtonAdd
                flat: true
                iconSource: "toolbar-add"
                onClicked: {
                    if (clickMode == "add") {
                        createItemForm(list)
                    } else if (clickMode == "save") {
                        var child = textInputPlaceHolder.children[0]
                        child.addListItem(child.text)
                        child.closeSoftwareInputPanel()
                        child.destroy()

                        listItemToolButtonAdd.iconSource = "toolbar-add"
                        listItemToolButtonAdd.clickMode = "add"
                    }
                }
            }

            ToolButton {
                flat: true
                iconSource: "toolbar-menu"
                onClicked: {

                }
            }
        }
    }
}
