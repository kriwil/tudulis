import QtQuick 1.1
import com.nokia.symbian 1.1
import "ListStorage.js" as ListStorageJS

Window {
    id: root
    platformInverted: true

    StatusBar {
        anchors.top: parent.top
        id: statusBar
        z: 1
    }

    TabBar {
        anchors.top: statusBar.bottom
        id: tabBar
        z: 1

        TabButton {
            tab: listPageStack
            text: "Lists"
        }
        TabButton {
            tab: notesPage
            text: "Notes"
        }
    }

    TabGroup {
        id: tabGroup
        z: 0
        anchors {
            top: tabBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        PageStack {
            id: listPageStack
            initialPage: ListTabPage {}
        }

        Page {
            id: notesPage
            Text {
                anchors.fill: parent
                text: qsTr("Hello notes world!")
                color: platformStyle.colorNormalLight
                font.pixelSize: 20
            }
        }
    }

    ListModel {
        id: listsModel
    }

    ListModel {
        id: listsItemModel
    }

    Component.onCompleted: {
        ListStorageJS.initialize()
    }

}
