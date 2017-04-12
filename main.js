// GLOBAL VARS ########################

var todolist = []
var journal = []
var ajaxcmd = []
var ajaxlength = 0
var ajaxcurr = 0

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
                statut: rs.rows.item(i).statut,
                journal: false
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
                statut: 0,
                journal: true
            }
            break
        case "remove": delete tmp[journal[i].idx]; break
        case "mod":
            tmp[journal[i].idx].statut = (tmp[journal[i].idx].statut == 1)? 0 : 1
            tmp[journal[i].idx].journal = true
            break
        }
    }
    todoModel.clear()
    for (var key in tmp) {
        todoModel.append(tmp[key])
    }
}

function ajaxinit(url,detail) {
    ajax = new XMLHttpRequest()
    ajax.onreadystatechange = function() {
        if (ajax.readyState == XMLHttpRequest.LOADING) {}
        else if (ajax.readyState == XMLHttpRequest.HEADERS_RECEIVED) {}
        else if (ajax.readyState == XMLHttpRequest.DONE) {
            if (ajax.status == 200) { ajaxsync(ajax.responseText) }
            else {
                dialogmsg.text = "Échec de la\nsynchronisation"
                diagtimer.start()
            }
        }
    }
    ajax.open("POST",url,true)
    ajax.setRequestHeader("Content-type","application/x-www-form-urlencoded")
    ajax.send("detail="+detail)
}

function ajaxsync(res) {
    if (res == "start") { ajaxinit(server+"?cmd=synchro&arg="+appid,lastsync) }
    else if (res == "action") {
        tododb.transaction(function(tx) {
            var check = true
            var rs = tx.executeSql("SELECT COUNT(*) AS res FROM todo WHERE idx=?;",[ajaxcmd[0].idx])
            switch (ajaxcmd[0].action) {
            case "add":
                if (rs.rows.item(0).res > 0) { check = false }
                break
            case "remove":
                if (rs.rows.item(0).res == 0) { check = false }
                break
            }
            if (check) {
                var url = server+"?cmd="+ajaxcmd[0].action+"&arg="+ajaxcmd[0].idx
                ajaxinit(url,ajaxcmd[0].detail)
            }
            else { ajaxsync("ok") }
        })
    }
    else if (res == "finish") {
        dialogmsg.text = "Finalisation ..."
        ajaxinit(server+"?cmd=synchro&arg=all",lastsync)
    }
    else if (res == "ok") {
        ajaxcurr++
        dialogmsg.text = "Envoi des modifications\n("+ajaxcurr+"/"+ajaxlength+")"
        var cmd = ajaxcmd.shift()
        tododb.transaction(function(tx) {
            var req = [cmd.idx,cmd.action]
            tx.executeSql("DELETE FROM journal WHERE idx=? AND action=?;",req)
        })
        if (ajaxcmd.length == 0) { ajaxsync("finish") }
        else { ajaxsync("action") }
    }
    else if (res[0] == "{") {
        try {
            var rep = JSON.parse(res)
            tododb.transaction(function(tx) {
                for (var i=0;i<rep.list.length;i++) {
                    dialogmsg.text = "Récupération des ordres\n("+i+"/"+rep.list.length+")"
                    var req = []
                    switch (rep.list[i].action) {
                    case "add":
                        req = [rep.list[i].idx,rep.list[i].detail,false]
                        tx.executeSql("INSERT INTO todo VALUES(?,?,?);",req)
                        break
                    case "mod":
                        var rs = tx.executeSql("SELECT * FROM todo WHERE idx=?;",[rep.list[i].idx])
                        req = [!rs.rows.item(0).statut,rep.list[i].idx]
                        tx.executeSql("UPDATE todo SET statut=? WHERE idx=?;",req)
                        break
                    case "remove":
                        tx.executeSql("DELETE FROM todo WHERE idx=?;",[rep.list[i].idx])
                        break
                    }
                }
                if (rep.last == 0) {
                    lastsync = rep.last
                    tx.executeSql("UPDATE parameters SET value=? WHERE label='last';",[lastsync])
                }
            })
            if (ajaxcmd.length > 0) {
                ajaxlength = ajaxcmd.length
                ajaxcurr = 0
                dialogmsg.text = "Envoi des modifications\n(0/"+ajaxlength+")"
                ajaxsync("action")
            }
            else {
                dialogmsg.text = "Synchronisation terminée"
                diagtimer.start()
            }
        }
        catch (e) {
            dialogmsg.text = "Échec de la\nsynchronisation"
            diagtimer.start()
        }
    }
    else {
        dialogmsg.text = "Échec de la\nsynchronisation"
        diagtimer.start()
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
    ajaxcmd = []
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
    ajaxsync("start")
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

function timerout() {
    getTodoEntries()
    getJournalEntries()
    updateModel()
    dialogrect.visible = false
    dialogblocker.visible = false
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
}
