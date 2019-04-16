/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.0
import com.nokia.symbian 1.0 // Symbian components
import com.nokia.extras 1.0 // Extras

import "RentBook.js" as RentBookJS

Page {
    id: rentItemsPage

    //property Menu pageMenu
    property QueryDialog deleteDialog
    property QueryDialog deleteDBDialog

    property bool useCache: false

    function freePage()
    {
        //delete pageMenu;
        delete deleteDialog;
        delete deleteDBDialog;
    }

    // Free menu and pop
    function doBack()
    {
        freePage();
        pageStack.pop();
    }
    
    // Update page data
    function fillListModel()
    {
        listView.model = emptyListModel;
        listModel.clear();

        RentBookJS.rentItems = db.rentItems(useCache);

        for(var i=0;i<RentBookJS.rentItems.length;i++) {
            var item = RentBookJS.rentItems[i];
            listModel.append({"name":item.name,
                                 "id":item.index,
                                 "cost":item.cost});

            item = null;
        }


        if (listModel.count < 1)
            addResourcesBtn.opacity = 1;
        else
            addResourcesBtn.opacity = 0;

        listView.model = listModel;
    }

    // Show edit or add new rent page
    function showRendDetails()
    {
        var currIndex = listView.currentIndex;
        var currentItem = listModel.get(currIndex);
        pageStack.push(Qt.resolvedUrl("RentItemPage.qml"),
                       { rentId : currentItem.id, rentName : currentItem.name, rentCost : currentItem.cost });

    }

    // Show dialog for deleting rent item
    function showDeleteDialog()
    {
        var currIndex = listView.currentIndex;
        var currentItem = listModel.get(currIndex);
        if (currIndex != -1) {
            if (!deleteDialog) {
                deleteDialog = deleteDialogComponent.createObject(rentItemsPage)
            }
            deleteDialog.message = "Delete " + currentItem.name + "?"
            deleteDialog.open()
        }
    }

    // Show dialog for deleting whole database
    function showDeleteDBDialog()
    {
        if (!deleteDBDialog) {
            deleteDBDialog = deleteDBDialogComponent.createObject(rentItemsPage)
        }
        deleteDBDialog.open()

    }

    // Delete rent item from database
    function deleteRentFromDatabase()
    {
        var currIndex = listView.currentIndex;
        var currentItem = listModel.get(currIndex);
        if (currIndex != -1) {
            db.deleteRentItem(currentItem.id);
        }
        fillListModel();
    }


    // Update page data on page PageStatus.Activating state
    onStatusChanged: {
        if (status==PageStatus.Activating) {
            fillListModel();
        }
    }


    // Page content

    Component {
        id: deleteDialogComponent
        QueryDialog {
            titleText: "Delete?"
            message: ""
            acceptButtonText: "Delete"
            rejectButtonText: "Cancel"
            onAccepted: {
                deleteRentFromDatabase();
            }
        }
    }

    Component {
        id: deleteDBDialogComponent
        QueryDialog {
            titleText: "Delete whole database?"
            message: "Delete all rent items and bookings?"
            acceptButtonText: "Delete all"
            rejectButtonText: "Cancel"
            onAccepted: {
                db.deleteDB();
                db.open();
                fillListModel();
            }
        }
    }

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: listView
    }

    ListView {
        id: listView
        anchors { left: parent.left; right: parent.right;
            top: parent.top; bottom: parent.bottom }
        clip: true
        delegate: listDelegate
        model: listModel
        header: listHeading
        focus: true
    }

    ListModel {
        id: listModel
    }

    ListModel {
        id: emptyListModel
    }

    Component {
        id: listDelegate
        ListItem {
            id: listItem
            ListItemText {
                x: platformStyle.paddingLarge
                anchors.verticalCenter: listItem.verticalCenter
                mode: listItem.mode
                role: "Title"
                text: name
            }
            subItemIndicator: true
            onClicked: {
                showRendDetails();
            }
            onPressAndHold : {
                contextMenu.open();
            }

        }
    }

    ContextMenu {
        id: contextMenu
        MenuLayout {
            MenuItem {
                text: "Edit"
                onClicked: {
                    showRendDetails();
                }
            }
            MenuItem {
                text: "Delete"
                onClicked: {
                    showDeleteDialog();
                }
            }
        }
    }

    Component {
        id: listHeading
        ListHeading {
            width: parent.width
            ListItemText {
                anchors.fill: parent.paddingItem
                role: "Heading"
                text: "Resource Management"
            }
        }
    }


    Item {
        id: addResourcesBtn
        anchors.centerIn: parent
        opacity: 0
        Text {
            id: textid
            text: "No resources"
            color: "white"
            anchors.centerIn: parent
        }
        ToolButton {
            text: "Add"
            flat: false
            iconSource: "toolbar-add"
            anchors.top: textid.bottom
            anchors.horizontalCenter: textid.horizontalCenter
            anchors.topMargin: 20
            onClicked: {
                pageStack.push(Qt.resolvedUrl("RentItemPage.qml"));
            }
        }
    }


    // Page specific toolbar
    tools: ToolBarLayout {
        id: toolBarlayout
        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: doBack();
        }
        ToolButton {
            flat: true
            iconSource: "toolbar-add"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("RentItemPage.qml"));
            }
        }
        ToolButton {
            iconSource: "toolbar-delete"
            onClicked: {
                showDeleteDBDialog();
            }
        }

        /*
        ToolButton {
            iconSource: "toolbar-menu"
            onClicked: {
                if (!pageMenu)
                    pageMenu = pageMenuComponent.createObject(root)
                pageMenu.open()
            }
        }
        */
    }

    // Page specific menu
    /*
    Component {
        id: pageMenuComponent
        Menu {
            content: MenuLayout {
                MenuItem { text: "Info";
                    onClicked:
                    {
                        pageStack.push(Qt.resolvedUrl("InfoPage.qml"));
                    }
                }
                MenuItem { text: "Delete all resources";
                    onClicked:
                    {
                        showDeleteDBDialog();
                    }
                }
                MenuItem { text: "Back";
                    onClicked:
                    {
                        doBack();
                    }
                }
            }
        }
    }
    */

}
