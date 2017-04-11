// GLOBAL VARS ########################

var todolist = []
var journal = []
var ajaxstate = ""
var ajaxcmd = []

// HELPERS ############################

function idsgen() {
    var dte = new Date()
    var txt = dte.getFullYear()
    txt += ((dte.getMonth() < 10)? "0":"")+dte.getMonth()
    txt += ((dte.getDate() < 10)? "0":"")+dte.getDate()
    txt += ((dte.getHours() < 10)? "0":"")+dte.getHours()
    txt += ((dte.getMinutes() < 10)? "0":"")+dte.getMinutes()
    txt += ((dte.getSeconds() < 10)? "0":"")+dte.getSeconds()
    return txt
}

function dbinit(db) {
    db.transaction(function(tx) {
        tx.executeSql("CREATE TABLE todo (idx TEXT,info TEXT,statut BOOLEAN);")
        tx.executeSql("CREATE TABLE journal (date TIMESTAMP,idx TEXT,action TEXT,detail TEXT);")
        tx.executeSql("CREATE TABLE parameters (label TEXT,value TEXT);")
        tx.executeSql("INSERT INTO parameters values('last','0');")
        tx.executeSql("INSERT INTO parameters values('appid',?);",[idsgen()])
    })
    db.changeVersion("","1.0")
}

function updateJournal(idx,action,detail) {
    tododb.transaction(function(tx) {
        var req = [idx,action,detail]
        tx.executeSql("INSERT INTO journal VALUES(CURRENT_TIMESTAMP,?,?,?);",req)
    })
}

function getTodoEntries() {
    todolist = []
    tododb.transaction(function(tx) {
        var rs = tx.executeSql("SELECT * FROM todo ORDER BY idx;")
        for (var i=0;i<rs.rows.length;i++) {
            var obj = {
                idx: rs.rows.item(i).idx,
                texte: rs.rows.item(i).info,
                statut: rs.rows.item(i).statut
            }
            todolist.push(obj)
        }
    })
}

function getJournalEntries() {
    journal = []
    tododb.transaction(function(tx) {
        var rs = tx.executeSql("SELECT * FROM journal ORDER BY date;")
        for (var i=0;i<rs.rows.length;i++) {
            var obj = {
                idx: rs.rows.item(i).idx,
                action: rs.rows.item(i).action,
                detail: rs.rows.item(i).detail
            }
            journal.push(obj)
        }
    })
}

function updateModel() {
    var tmp = {}
    var i
    for (i=0;i<todolist.length;i++) { tmp[todolist[i].idx] = todolist[i] }
    for (i=0;i<journal.length;i++) {
        switch (journal[i].action) {
        case "add":
            tmp[journal[i].idx] = {
                idx: journal[i].idx,
                texte: journal[i].detail,
                statut: false
            }
            break
        case "remove": delete tmp[journal[i].idx]; break
        case "mod":
            tmp[journal[i].idx].statut = !tmp[journal[i].idx].statut
            break
        }
    }
    todoModel.clear()
    for (var key in tmp) {
        todoModel.append(tmp[key])
    }
}

function ajaxsync(res) {
    if (res == "start") {
        //
        //ajax.send("GET",server)
        //
    }
    else if (res == "ok") {
        //
        //
    }
    else if (res[0] == "{") {
        //
        // TODO : parse json
        //
        console.log("json parsing")
        console.log(res)
        //
    }
    else {
        //
        // TODO : connexion failed
        //
        console.log("network error")
        console.log(res)
        //
    }
}

// METHODS ############################

function testIdent() {
    var push = false
    if (identEdit.text == "tsuki") {
        root.master = true
        push = true
    }
    else if (identEdit.text == "poilu") {
        root.master = false
        push = true
    }
    if (push) mainStack.push(todolistView)
}

function synchronize() {
    dialogblocker.visible = true
    dialogrect.visible = true
    dialogmsg.text = "Synchronisation\nen cours ..."
    //
    ajaxcmd = [{action: 'sync'}]
    //
    tododb.transaction(function(tx) {
        var rs = tx.executeSql("SELECT * FROM journal ORDER BY date;")
        for (var i=0;i<rs.rows.length;i++) {
            var obj = {
                idx: rs.rows.item(i).idx,
                action: rs.rows.item(i).action,
                detail: rs.rows.item(i).detail
            }
            ajaxcmd.push(obj)
        }
    })
    //
    ajaxsync("start")
    //
    // TEST
    //diagtimer.start()
    // TEST
    //
}

function addTask() {
    var nidx = root.appid+"-"+idsgen()
    updateJournal(nidx,'add',addEdit.text)
    mainStack.pop()
    var obj = {idx: nidx, action: "add", detail: addEdit.text }
    journal.push(obj)
    updateModel()
}

function modTask(idx) {
    tododb.transaction(function(tx) {
        var rs = tx.executeSql("SELECT COUNT(*) AS res FROM journal WHERE idx=? AND action='mod';",[idx])
        if (rs.rows.item(0).res == 1) {
            tx.executeSql("DELETE FROM journal WHERE idx=? AND action='mod';",[idx])
        }
        else { updateJournal(idx,'mod','') }
        getJournalEntries()
        updateModel()
    })
}

function remTask(idx) {
    tododb.transaction(function(tx) {
        var rs = tx.executeSql("SELECT COUNT(*) AS res FROM journal WHERE idx=? AND action='add';",[idx])
        if (rs.rows.item(0).res == 1) {
            tx.executeSql("DELETE FROM journal WHERE idx=? AND action='add';",[idx])
        }
        else { updateJournal(idx,'remove','') }
        rs = tx.executeSql("SELECT COUNT(*) AS res FROM journal WHERE idx=? AND action='mod';",[idx])
        if (rs.rows.item(0).res == 1) {
            tx.executeSql("DELETE FROM journal WHERE idx=? AND action='mod';",[idx])
        }
        getJournalEntries()
        updateModel()
    })
}

function initWindow() {
    tododb = LocalStorage.openDatabaseSync("OthyTodoListDB","1.0","",1000000,Script.dbinit)
    tododb.transaction(function(tx) {
        var rs = tx.executeSql("SELECT * FROM parameters;")
        for (var i=0;i<rs.rows.length;i++) {
            switch (rs.rows.item(i).label) {
            case "appid": root.appid = rs.rows.item(i).value; break
            case "last": root.lastsync = rs.rows.item(i).value; break
            }
        }
    })
    getTodoEntries()
    getJournalEntries()
    updateModel()
    // set ajax object
    ajax = new XMLHttpRequest()
    ajax.onreadystatechange = function() {
        if (ajax.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
        }
        else if (ajax.readyState == XMLHttpRequest.DONE) {
            if (ajax.status == 200) {
                //ajaxsync(ajax.responseText)
            }
            else {
                //
                // TODO : network failed
                //
            }
        }
    }
    //
    ajax.open("GET",server)
    ajax.send()
    //
}
