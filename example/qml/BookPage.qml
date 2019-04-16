/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.0
import com.nokia.symbian 1.0 // Symbian components
import com.nokia.extras 1.0 // Extras

import "RentBook.js" as RentBookJS

Page {
    id: bookPage

    property QueryDialog deleteDialog

    property int rentItemId

    property int rentId;
    property int rentBlockId;

    property int renterId
    property string renterName
    property string renterPhone

    property int year
    property int month
    property int day


    function freePage()
    {
        delete deleteDialog;
    }

    function doBack()
    {
        freePage();
        pageStack.pop();
    }

    function storeDataToDatabase()
    {
        if (renterId != -1) {
            // Update renter data
            db.updateRenter(renterId,nameField.text,phoneField.text);
        }
        else {
            // Insert new renter
            renterId = db.insertRenter(nameField.text,phoneField.text);

            // Add new rents
            addRentsToDatabase();
        }
        doBack();
    }

    function addRentsToDatabase()
    {
        // Insert new rent
        var selDayIndex = tumblerColumn.selectedIndex;
        var date = new Date();
        var rentBlockId = db.nextId();
        for(var i=0;i<selDayIndex+1;i++) {
            date.setFullYear(year, month-1, day+i); // year, month (0-based), day + i
            db.insertRent(date.getFullYear(),date.getMonth()+1,date.getDate(),
                          rentBlockId,rentItemId,renterId);
        }
    }


    function showDeleteDialog()
    {
        if (!deleteDialog) {
            deleteDialog = deleteDialogComponent.createObject(bookPage)
        }
        deleteDialog.message = "Delete whole booking?"
        deleteDialog.open()
    }

    function deleteRent()
    {
        db.deleteRentBlock(rentBlockId);
        doBack();
    }

    function fillFreeDays()
    {
        tumblerColumn.items = emptyDayList;
        freeDayList.clear();
        var date = null;

        if (renterId!=-1) {
            // Edit rent view
            var firstDate = db.firstBookedRentBlockDate(rentBlockId);
            date = new Date(firstDate);
            title.text = "Booking begings " + date.toDateString();

            var lastDate = db.lastBookedRentBlockDate(rentBlockId);
            date = new Date(lastDate);
            endDataText.text = date.toDateString();
            date = null;
        }
        else {
            // New rent view
            title.text = "Booking begings " + RentBookJS.localeDate(day, month, year);
            for(var i=0;i<7;i++) {
                date = new Date();
                date.setFullYear(year, month-1, day + i); // year, month (0-based), day + i
                var isFree = db.isFreeRentDate(rentItemId,
                                               date.getFullYear(),
                                               date.getMonth()+1,
                                               date.getDate())
                if (isFree) {
                    freeDayList.append({"index":i,
                                           "value":date.toDateString(),
                                           "year":date.getFullYear(),
                                           "month":date.getMonth()+1,
                                           "day":date.getDate()});
                } else {
                    break;
                }
                date = null;
            }
        }
        tumblerColumn.items = freeDayList;
    }

    onStatusChanged: {
        if (status==PageStatus.Active) {
            // Fill view after small delay
            delayedDataFill.restart();
        }
    }

    Timer {
        id: delayedDataFill
        interval: 200
        repeat: false
        onTriggered: {
            fillFreeDays();
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
                deleteRent();
            }
        }
    }

    Flickable {
        id: flickable
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: parent.height > parent.width ? parent.height : parent.width
        clip: true

        Column {
            id: column
            spacing: platformStyle.paddingLarge
            width: parent.width - 20
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: title
                font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeLarge }
                color: platformStyle.colorNormalLight
                text: " "
            }
            Text {
                id: nameText
                text: "Name"
                font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeMedium }
                color: platformStyle.colorNormalLight
            }
            TextField {
                id: nameField
                height: nameText.height * 1.5;
                width: parent.width
                placeholderText: "Enter name"
                text: renterName
            }
            Text {
                id: nameReadOnlyField
                font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeLarge }
                color: platformStyle.colorNormalLight
                text: renterName
                x: 10
            }
            Text {
                id: phoneText
                text: "Phone"
                font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeMedium }
                color: platformStyle.colorNormalLight
            }
            TextField {
                id: phoneField
                height: phoneText.height * 1.5;
                width: parent.width
                // Accept only numers
                inputMethodHints: Qt.ImhPreferNumbers
                text: renterPhone
            }
            Text {
                id: phoneReadOnlyField
                font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeLarge }
                color: platformStyle.colorNormalLight
                height: phoneText.height * 1.5;
                width: parent.width
                text: renterPhone
                x: 10
            }
            Text {
                id: tumblerText
                text: "Booking ends "
                font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeMedium }
                color: platformStyle.colorNormalLight
            }
            Text {
                id: endDataText
                opacity: 0
                font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeMedium }
                color: platformStyle.colorNormalLight
            }
            Tumbler  {
                id: dateTumbler
                opacity: 0
                columns: tumblerColumn
                anchors.horizontalCenter: parent.horizontalCenter
            }
            TumblerColumn {
                id: tumblerColumn
                items: freeDayList
            }
            ListModel {
                id: freeDayList
            }
            ListModel {
                id: emptyDayList
            }
            ToolButton {
                id: callbtn
                opacity: 0
                anchors.horizontalCenter: parent.horizontalCenter
                property bool isCalling: false
                flat: false
                text: (isCalling)? "Disconnect" : "Call...    "
                onClicked:  {
                    if (telephony) {
                        if (isCalling) {
                            isCalling = false;
                            telephony.endCall();
                        } else {
                            if(phoneField.text.length < 2) {
                                callInfobanner.close();
                                callInfobanner.text = "Check the phone number";
                                callInfobanner.timeout = 3 *1000;
                                callInfobanner.open();

                            } else {
                                isCalling = true;
                                telephony.startCall(phoneField.text);
                            }
                        }
                    }
                }
            }

        } // Column

    } // Flickable

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: flickable
    }


    Connections {
        target: telephony
        onError:  {
            callbtn.isCalling = false;
            pageStack.raiseApplication();
        }
        onCallDialling: {
            callbtn.isCalling = true;
            pageStack.raiseApplication();
        }
        onCallConnected: {
            callbtn.isCalling = true;
            //pageStack.raiseApplication();
        }
        onCallDisconnected: {
            callbtn.isCalling = false;
            pageStack.raiseApplication();
        }
    }

    InfoBanner {
        id: callInfobanner
    }

    // Page specific toolbar
    tools: {
        if (state=="NEW")
            return toolBarNewlayout;
        else
            return toolBarViewlayout;
    }

    ToolBarLayout {
        id: toolBarNewlayout
        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: doBack();
        }
        ToolButton {
            flat: false
            text: "Save"
            onClicked:  {
                storeDataToDatabase();
            }
        }
    }

    ToolBarLayout {
        id: toolBarViewlayout
        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: doBack();
        }
        ToolButton {
            flat: false
            text: "Edit"
            onClicked:  {
                bookPage.state = "EDIT";
            }
        }
    }

    ToolBarLayout {
        id: toolBarEditlayout
        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: doBack();
        }
        ToolButton {
            flat: false
            text: "Save"
            onClicked:  {
                storeDataToDatabase();
            }
        }
        ToolButton {
            id: deleteBtn
            flat: false
            text: "Delete"
            onClicked: showDeleteDialog();
        }
    }

    states: [
        State {
            name: "NEW"
            when: (renterId == -1)
            //StateChangeScript { name: "setToolBar"; script: {toolBar.tools = toolBarNewlayout} }
            PropertyChanges { target: endDataText; opacity: 0}
            PropertyChanges { target: callbtn; opacity: 0}
            PropertyChanges { target: dateTumbler; opacity: 1}

            PropertyChanges { target: nameReadOnlyField; opacity: 0}
            PropertyChanges { target: phoneReadOnlyField; opacity: 0}
        },
        State {
            name: "VIEW"
            when: (renterId != -1)
            //StateChangeScript { name: "setToolBar"; script: {toolBar.tools = toolBarViewlayout} }
            PropertyChanges { target: endDataText; opacity: 1}
            PropertyChanges { target: callbtn; opacity: 1}
            PropertyChanges { target: dateTumbler; opacity: 0}

            PropertyChanges { target: nameField; opacity: 0}
            PropertyChanges { target: nameReadOnlyField; opacity: 1}
            PropertyChanges { target: phoneField; opacity: 0}
            PropertyChanges { target: phoneReadOnlyField; opacity: 1}
        },
        State {
            name: "EDIT"
            StateChangeScript { name: "setToolBar"; script: {toolBar.tools = toolBarEditlayout} }
            PropertyChanges { target: endDataText; opacity: 1}
            PropertyChanges { target: callbtn; opacity: 1}
            PropertyChanges { target: dateTumbler; opacity: 0}

            PropertyChanges { target: nameReadOnlyField; opacity: 0}
            PropertyChanges { target: phoneReadOnlyField; opacity: 0}
        }
    ]


    transitions: [
        Transition {
            to: "NEW"
            SequentialAnimation {
                PauseAnimation { duration: 400 }
                NumberAnimation { target: dateTumbler;
                    property:"opacity"; from: 0; to: 1; duration:1000}
            }
        }
    ]

}
