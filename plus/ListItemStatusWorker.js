Qt.include("ListStorage.js")

WorkerScript.onMessage = function(message) {
    listItemUpdateComplete(message.pk, message.status)
}
