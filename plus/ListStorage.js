function getDatabase() {
     return openDatabaseSync("tudulisplus", "1.0", "StorageDatabase", 100000);
}

function initialize() {
    var db = getDatabase();
    db.transaction(
        function(tx) {
//            tx.executeSql("DROP TABLE list");
//            tx.executeSql("DROP TABLE listitem");
//            tx.executeSql("DROP TABLE setting");
            tx.executeSql("CREATE TABLE IF NOT EXISTS list(pk INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT)");
            tx.executeSql("CREATE TABLE IF NOT EXISTS listitem(pk INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, completed INTEGER, listpk INTEGER)");
            tx.executeSql("CREATE TABLE IF NOT EXISTS setting(key VARCHAR(32) PRIMARY KEY, value TEXT)");

            var rs = tx.executeSql("SELECT value FROM setting WHERE key='start-count'");
            var start_count = 0;
            if (parseInt(rs.rows.length) === 0) {

                // create 'start-count'
                tx.executeSql("INSERT INTO setting VALUES('start-count', 0)");

                // initial list
                tx.executeSql("INSERT INTO list VALUES(NULL, 'to-do')");
                tx.executeSql("INSERT INTO list VALUES(NULL, 'shopping')");
            } else {
                start_count = parseInt(rs.rows.item(0).value);
            }

            // update start-count
            tx.executeSql("UPDATE setting SET value=?", [start_count + 1]);

        }
    );
}

function setSetting(key, value) {
    var db = getDatabase();
    var result = 0;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT value FROM setting WHERE key=?", [key]);
            if (rs.rowsAffected > 0) {
                result = 1;
            }
        }
    );

    return result;
}

function addList(list) {
    var db = getDatabase();
    var result = 0;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("INSERT INTO list VALUES(NULL, ?)", [list.title]);
            if (rs.rowsAffected > 0) {
                result = 1;
            }
        }
    );

    return result;
}

function getList() {
    var db = getDatabase();
    var result = [];
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT * FROM list");
            if (rs.rows.length > 0) {
                for (var i=0; i<rs.rows.length; i++) {
                    result.push(rs.rows.item(i));
                }
            }
        }
    );

    return result;
}


function addListItem(listitem) {
    var db = getDatabase();
    var result = 0;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("INSERT INTO listitem VALUES(NULL, ?, ?, ?)", [listitem.title, 0, listitem.listpk]);
            if (rs.rowsAffected > 0) {
                result = 1;
            }
        }
    );

    return result;
}

function getListItem(listpk) {
    var db = getDatabase();
    var result = [];
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT * FROM listitem WHERE listpk=?", [listpk]);
            if (rs.rows.length > 0) {
                for (var i=0; i<rs.rows.length; i++) {
                    result.push(rs.rows.item(i));
                }
            }
        }
    );

    return result;
}

function updateListItem(pk, listitem) {
    var db = getDatabase();
    var result = 0;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("UPDATE listitem SET title=?, completed=? WHERE pk=?", [listitem.title, listitem.completed, pk]);
            if (rs.rowsAffected > 0) {
                result = 1;
            }
        }
    );

    return result;
}

function listItemUpdateComplete(pk, complete) {
    var db = getDatabase();
    var result = 0;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("UPDATE listitem SET completed=? WHERE pk=?", [complete, pk]);
            if (rs.rowsAffected > 0) {
                result = 1;
            }
        }
    );

    return result;
}

function deleteList(listpk) {
    var db = getDatabase();
    var result = 0;
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM listitem WHERE listpk=?;', [listpk]);
        if (rs.rowsAffected > 0) {
        }
    });

    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM list WHERE pk=?;', [listpk]);
        if (rs.rowsAffected > 0) {
        }
    });

    return result;
}
