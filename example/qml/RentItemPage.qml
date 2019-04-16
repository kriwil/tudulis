/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.0
import com.nokia.symbian 1.0 // Symbian components

Page {
    id: rentItemPage

    property QueryDialog deleteDialog

    property int rentId : -1
    property string rentName
    property int rentCost : 0

    function freePage()
    {
        delete deleteDialog;
    }

    function doBack()
    {
        freePage();
        pageStack.pop();
    }

    // Add or update rent data into database
    function addRentToDatabase()
    {
        if (rentId != -1) {
            db.updateRentItem(rentId,nameField.text,priceField.text)
        }
        else {
            db.insertRentItem(nameField.text,priceField.text);
        }

        doBack();
    }

    // Show delete rent data dialog
    function showDeleteDialog()
    {
        if (!deleteDialog) {
            deleteDialog = deleteDialogComponent.createObject(rentItemPage)
        }
        deleteDialog.message = "Delete " + nameField.text + "?"
        deleteDialog.open()
    }

    // Delete rent data from database
    function deleteRentFromDatabase()
    {
        db.deleteRentItem(rentId);
        doBack();
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



    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: 20
        flickableDirection: Flickable.VerticalFlick
        contentWidth: parent.width-40
        contentHeight: parent.height > parent.width ? parent.height - 40 : parent.width - 40
        clip: true

        Rectangle {
            id: background
            anchors.fill: parent
            radius: 8
            color: "transparent"
            border.width: 2
            border.color: "white"
        }

        Column {
            id: column
            spacing: 20
            width: parent.width - 20
            x: 10
            y: 10

            Text {
                id: title
                font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeLarge }
                color: platformStyle.colorNormalLight
                text:"Resource for rent"
            }

            Rectangle {
                height: 40
                width: parent.width
                color: "transparent"
            }

            Text {
                id: nameText
                text: "Name"
                font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeMedium }
                color: platformStyle.colorNormalLight
            }
            TextField {
                id: nameField
                placeholderText: "Enter name"
                height: nameText.height * 1.5;
                width: parent.width
                text: rentName
            }
            Text {
                id: nameReadOnlyField
                font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeLarge }
                color: platformStyle.colorNormalLight
                text: rentName
                x: 10
            }
            Text {
                id: priceText
                width: parent.width
                text: "Price"
                font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeMedium }
                color: platformStyle.colorNormalLight
            }
            TextField {
                id: priceField
                height: priceText.height * 1.5
                width: parent.width
                // Accept only numers
                inputMethodHints: Qt.ImhPreferNumbers
                text: {
                    if (rentCost==0)
                        return "";
                    else
                        return rentCost;
                }
            }
            Text {
                id: priceReadOnlyField
                font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeLarge }
                color: platformStyle.colorNormalLight
                x: 10
                text: {
                    if (rentCost==0)
                        return "";
                    else
                        return rentCost;
                }
            }
        } // Column
    } // Flickable

    ScrollDecorator {
        flickableItem: flickable
    }


    // Page specific toolbar
    tools: {
        if (state=="NEW")
            return toolBarNewlayout;
        else
            return toolBarViewlayout;
    }

    // Page specific toolbar
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
            onClicked: addRentToDatabase();

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
                rentItemPage.state = "EDIT";
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
            onClicked: addRentToDatabase();

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
            when: (rentId == -1)
            PropertyChanges { target: nameReadOnlyField; opacity: 0}
            PropertyChanges { target: priceReadOnlyField; opacity: 0}
        },
        State {
            name: "VIEW"
            when: (rentId != -1)
            PropertyChanges { target: nameField; enabled: false}
            PropertyChanges { target: priceField; enabled: false}
            PropertyChanges { target: nameField; opacity: 0}
            PropertyChanges { target: priceField; opacity: 0}
            PropertyChanges { target: nameReadOnlyField; opacity: 1}
            PropertyChanges { target: priceReadOnlyField; opacity: 1}
        },
        State {
            name: "EDIT"
            StateChangeScript { name: "setToolBar"; script: {toolBar.tools = toolBarEditlayout} }
            PropertyChanges { target: deleteBtn; enabled: true}
            PropertyChanges { target: nameReadOnlyField; opacity: 0}
            PropertyChanges { target: priceReadOnlyField; opacity: 0}
        }
    ]

}
