import QtQuick 1.1
import com.nokia.symbian 1.1
import "." 1.1
import "ListStorage.js" as ListStorageJS

CustomPage {

    id: listTabPage

    function updateListItemModel(listpk) {
        var listitems = ListStorageJS.getListItem(listpk)
        listsItemModel.clear()
        for (var i=0; i<listitems.length; i++) {
            listsItemModel.append(listitems[i])
        }
        listsItemModel.sync()
    }

    ContextMenu {
        id: listMenu
        MenuLayout {
            MenuItem {
                text: "Rename"
                onClicked: {
                    console.log(listsListView.currentIndex)
                }
            }
            MenuItem {
                text: "Delete"
                onClicked: {
                    var list = listsModel.get(listsListView.currentIndex)
                    ListStorageJS.deleteList(list.pk)
                    listsModel.remove(listsListView.currentIndex)
                }
            }
        }
    }

    ListView {
        id: listsListView
        snapMode: ListView.SnapToItem
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: toolBar.top
        }

        model: listsModel

        delegate: RowItem {
            height: 45

            Text {
                id: numberBox
                text: index + 1
                width: 44
                height: 44
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: title
                height: 44
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 20
                color: "#222222"
                anchors {
                    left: numberBox.right
                    leftMargin: 10
                }
            }

            onClicked: {
                var list = listsModel.get(index)
                updateListItemModel(list.pk)
                listPageStack.push(Qt.resolvedUrl("ListItem.qml"), {'list': list})
            }

            onPressAndHold: {
                listMenu.open()
            }
        }
    }

    ToolBar {
        anchors.bottom: parent.bottom
        id: toolBar
        z: 1
        tools: ToolBarLayout {
            ToolButton {
                flat: true
                iconSource: "toolbar-back"
                onClicked: {
                   Qt.quit()
                }
            }

            ToolButton {
                flat: true
                iconSource: "toolbar-add"
                onClicked: {
                    listPageStack.push(Qt.resolvedUrl("ListForm.qml"))
                }
            }

            ToolButton {
                flat: true
                iconSource: "toolbar-menu"
            }
        }
    }

    Component.onCompleted: {
        var lists = ListStorageJS.getList()
        for (var i=0; i<lists.length; i++) {
            listsModel.append(lists[i])
        }
    }
}
