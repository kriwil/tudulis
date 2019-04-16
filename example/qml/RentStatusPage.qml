/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.0
import com.nokia.symbian 1.0 // Symbian components

import "RentBook.js" as RentBookJS

Page {
    id: rentStatusPage

    property bool useCache: true

    function fillListModel()
    {
        listView.model = emptyListModel;
        listModel.clear();

        RentBookJS.rentItems = db.rentItems(useCache);

        // Get rents
        var rentsData = db.dateRents(calendarItem.year, calendarItem.month, calendarItem.day);


        // Fill rent status list
        var rentItem;
        var rentsDataItem;
        var rentExists = false;
        for(var i=0;i<RentBookJS.rentItems.length;i++) {
            rentItem = RentBookJS.rentItems[i];
            rentExists = false;
            for(var j=0;j<rentsData.length;j++) {
                rentsDataItem = rentsData[j];
                if (rentItem.index == rentsDataItem.itemId) {
                    // Rent exists
                    var renterData = db.renter(rentsDataItem.renterId);
                    listModel.append({"titleText":rentItem.name,
                                     "name":renterData.name,
                                     "phone":renterData.phone,
                                     "rent":true,
                                     "renterId":renterData.index,
                                     "rentItemId":rentItem.index,
                                     "rentBlockId":rentsDataItem.rentBlockIndex,
                                     "rentId":rentsDataItem.index});
                    rentExists = true;
                    renterData = null;
                    break;
                }
                rentsDataItem = null;
            }
            // Free item
            if (!rentExists) {
                listModel.append({"titleText":rentItem.name,
                                 "name":"",
                                 "phone":"",
                                 "rent":false,
                                 "renterId":-1,
                                 "rentItemId":rentItem.index,
                                 "rentBlockId":-1,
                                 "rentId":-1});
            }
            rentItem = null;
        }


        if (listModel.count < 1) {
            addResourcesBtn.opacity = 1;
            listView.opacity = 0;
        }
        else {
            addResourcesBtn.opacity = 0;
            listView.opacity = 1;
        }

        listView.model = listModel;

        //rentItems = null;
        rentsData = null;

    }

    // Opens context menu for list
    function showContextMenu()
    {
        var currIndex = listView.currentIndex;
        var listModelItem = listModel.get(currIndex);
        if (listModelItem.rent)
            contextMenu.title = "Edit booking";
        else
            contextMenu.title = "Add booking";

        contextMenu.open();
    }


    // Page content

    // Update page data on page PageStatus.Activating state
    onStatusChanged: {
        if (status==PageStatus.Activating) {
            fillListModel();
        }
    }

    CalendarItem {
        id: calendarItem
        opacity: 0

        onDateChanged: {
            fillListModel();
        }
    }



    // Change date toolbar
    ToolBar {
        id: dateToolbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        tools: ToolBarLayout {
            ToolButton {
                iconSource: "toolbar-previous"
                onClicked: {
                    calendarItem.setPriorDay();
                }
            }
            ToolButton {
                id: dateButton
                text: RentBookJS.localeDate(calendarItem.day,calendarItem.month,calendarItem.year);
                onClicked: {
                    calendarItem.show();
                }
            }
            ToolButton {
                iconSource: "toolbar-next"
                onClicked: {
                    calendarItem.setNextDay();
                }
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
            top: dateToolbar.bottom; bottom: parent.bottom }
        anchors.topMargin:platformStyle.paddingMedium
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
            property int renterId: model.renterId
            property int rentItemId: model.rentItemId
            property string renterName: model.name
            property string renterPhone: model.phone
            property bool rented: model.rent
            property int rentId: model.rentId
            property int rentBlockId: model.rentBlockId

            Image {
                source: rented? "red.png" : "green.png"
                height:  listItem.height - 4
                width: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 4
                anchors.left: parent.left
            }
            Column {
                anchors.leftMargin: 10
                anchors.fill: listItem.paddingItem
                ListItemText {
                    mode: listItem.mode
                    role: "Title"
                    text: model.titleText
                }
                ListItemText {
                    mode: listItem.mode
                    role: "SubTitle"
                    text: {
                        if (listItem.rented)
                            return "Rented by: " +model.name;
                        else
                            return "Available";
                    }
                }
            }
            subItemIndicator: true
            onClicked: {
                pageStack.push(Qt.resolvedUrl("BookPage.qml"),{renterId:listItem.renterId,
                               renterName:listItem.renterName,
                               renterPhone:listItem.renterPhone,
                               rentItemId:listItem.rentItemId,
                               year:calendarItem.year,
                               month:calendarItem.month,
                               day:calendarItem.day,
                               rentBlockId: listItem.rentBlockId,
                               rentId:listItem.rentId});
            }
            onPressAndHold : {
                showContextMenu();
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
                text: "Daily Booking Status"
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
            //iconSource: "icon_close.png"
            onClicked: Qt.quit()
        }
        ToolButton {
            flat: false
            //iconSource: "toolbar-settings"
            text: "Resources"
            onClicked: pageStack.push(Qt.resolvedUrl("RentItemsPage.qml"))
        }
        ToolButton {
            flat: true
            iconSource: "../common/info.png"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("InfoPage.qml"));
            }
        }
    }

    ContextMenu {
        id: contextMenu
        property string title
        MenuLayout {
            MenuItem {
                text: contextMenu.title
                onClicked: {
                    var currIndex = listView.currentIndex;
                    var listModelItem = listModel.get(currIndex);
                    pageStack.push(Qt.resolvedUrl("BookPage.qml"),{renterId:listModelItem.renterId,
                                   renterName:listModelItem.name,
                                   renterPhone:listModelItem.phone,
                                   rentItemId:listModelItem.rentItemId,
                                   year:calendarItem.year,
                                   month:calendarItem.month,
                                   day:calendarItem.day,
                                   rentId:listModelItem.rentId});


                }
            }
        }
    }
}
