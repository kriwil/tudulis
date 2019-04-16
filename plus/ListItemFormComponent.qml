import QtQuick 1.1
import com.nokia.symbian 1.1
import "ListStorage.js" as ListStorageJS

TextField {

    property variant list: {'pk': 0, 'title': ''}

    function addListItem(text) {
        var title = text.toLowerCase()

        if (title) {

            var listitem = {"title": title, "listpk": list.pk, "completed": 0}
            listsItemModel.append(listitem)
            ListStorageJS.addListItem(listitem)
            listItemListView.currentIndex = listsItemModel.count - 1

        }

        //listPageStack.pop()
    }

    id: listItemFormInput
    height: 41
    focus: true
    font.capitalization: Font.AllLowercase
    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        bottom: parent.bottom
        leftMargin: 50
        rightMargin: 5
        topMargin: 2
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_Enter) {
            addListItem(listItemFormInput.text)
            listItemFormInput.closeSoftwareInputPanel()
            listItemFormInput.destroy()

            listItemToolButtonAdd.iconSource = "toolbar-add"
            listItemToolButtonAdd.clickMode = "add"
        }
    }

    Component.onCompleted: {
        listItemToolButtonAdd.iconSource = "ok.svg"
        listItemToolButtonAdd.clickMode = "save"

        listItemFormInput.openSoftwareInputPanel()
    }
}
