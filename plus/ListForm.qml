import QtQuick 1.1
import com.nokia.symbian 1.1
import "." 1.1
import "ListStorage.js" as ListStorageJS

CustomPage {
    id: listForm

    function addList() {
        var title = listFormTitleInput.text.toLowerCase()

        var list = {"title": title}
        listsModel.append(list)
        ListStorageJS.addList(list)

        listPageStack.pop()
    }

    TextField {
        id: listFormTitleInput
        height: 41
        focus: true
        font.capitalization: Font.AllLowercase
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            leftMargin: 50
            rightMargin: 5
            topMargin: 2
        }

        Keys.onPressed: {
            if (event.key == Qt.Key_Enter) {
                listFormTitleInput.closeSoftwareInputPanel()
                addList()
            }
        }
    }

    ToolBar {
        anchors.bottom: parent.bottom
        id: listFormToolBar
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
                flat: true
                iconSource: "ok.svg"
                onClicked: {
                    addList()
                }
            }
        }
    }

    Component.onCompleted: {

    }
}
