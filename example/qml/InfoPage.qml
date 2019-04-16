/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.0
import com.nokia.symbian 1.0 // Symbian components

Page {
    id: infoPage

    function doBack()
    {
        pageStack.pop();
    }

    // Page content

    Rectangle {
        id: container
        color: "black"
        anchors {
            fill: parent
            topMargin: 20
            bottomMargin: 20
            leftMargin: 20
            rightMargin: 20
        }

        Flickable {
            id: flickable

            clip: true

            anchors {
                fill: parent
            }

            contentHeight: text.height

            Text {
                id: text

                width: flickable.width
                color: "white"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                style: Text.Raised
                styleColor: "black"
                font.pixelSize: width * 0.05
                text: "<h2>RentBook " + appversion + "</h2>" +
                      "<p>RentBook is a Nokia example application that allows "+
                      "user to add items for rent into a database and, for example, "+
                      "keep track of for whom the item is rented on a certain date." +
                      "</p>" +
                      "<p>" +
                      "The UI is implemented using Qt Quick components 1.0 library "+
                      "and the Symbian version follows the new Symbian design guidelines. "+
                      "The data is stored into a SQLite database." +
                      "</p>" +
                      "<p>For more information about the project see the " +
                      "<a href=\"https://projects.developer.nokia.com/rentbook\">" +
                      "RentBook project page</a>"+
                      "</p>" +
                      "<h3>Instructions</h3>" +
                      "<p>" +
                      "When the application is first installed, the database is empty. "+
                      "The user can then start defining items for rent in the resource management view. "+
                      "After one or more items have been created, the items can be booked "+
                      "for certain dates. The rent period can be defined for 1-7 days." +
                      "</p>"

                onLinkActivated: Qt.openUrlExternally(link)
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
    }
}
