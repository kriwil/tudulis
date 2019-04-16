/**
 * Copyright (c) 2011 Nokia Corporation.
 */

import QtQuick 1.0
import com.nokia.symbian 1.0 // Symbian components

Window {
    id: root

    signal raise;

    // Common application statusbar
    StatusBar {
        id: statusBar
        anchors.top: root.top
    }

    Text {
        id: titleId
        text: "RentBook"
        font { family: platformStyle.fontFamilyRegular; pixelSize: platformStyle.fontSizeMedium }
        color: platformStyle.colorNormalLight
        anchors.top: statusBar.top
        anchors.left: parent.left
        anchors.leftMargin: platformStyle.paddingSmall
    }

    // Page stack for all pages
    PageStack {
        id: pageStack

        function raiseApplication()
        {
            root.raise();
        }

        toolBar: commonToolBar
        anchors { left: parent.left; right: parent.right;
            top: titleId.bottom; bottom: commonToolBar.top }

        anchors.topMargin:platformStyle.paddingMedium
        anchors.bottomMargin:platformStyle.paddingSmall

        Component.onCompleted: {
            // Push the first page on the stack
            pageStack.push(Qt.resolvedUrl("RentStatusPage.qml"));
        }
    }

    // Common toolbar for the pages
    ToolBar {
         id: commonToolBar
         anchors.bottom: parent.bottom
    }


}
