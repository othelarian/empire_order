import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Window 2.2
import QtQuick.LocalStorage 2.0

Window {
    id: root
    visible: true
    //visibility: "Maximized"
    width: 800; height: 600
    title: "Empire Order"
    // properties
    property bool master: true
    property int widthbtn: 80
    property int heightbtn: 30
    property color bluebtn: "#3af"
    property var tododb
    property string appid
    property string lastsync
    // functions
    function dbinit(db) {
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE todo (idx TEXT,info TEXT,statut BOOLEAN);")
            tx.executeSql("CREATE TABLE journal (date TIMESTAMP,idx TEXT,action TEXT,detail TEXT);")
            tx.executeSql("CREATE TABLE parameters (label TEXT,value TEXT);")
            tx.executeSql("INSERT INTO parameters values('last','0');")
            var dte = new Date()
            var txt = dte.getFullYear()
            txt += ((dte.getMonth() < 0)? "0":"")+dte.getMonth()
            txt += ((dte.getDate() < 0)? "0":"")+dte.getDate()
            txt += ((dte.getHours() < 0)? "0":"")+dte.getHours()
            txt += ((dte.getMinutes() < 0)? "0":"")+dte.getMinutes()
            txt += ((dte.getSeconds() < 0)? "0":"")+dte.getSeconds()
            tx.executeSql("INSERT INTO parameters values('appid',?);",[txt])
        })
        db.changeVersion("","1.0")
    }
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
        //
        dialogblocker.visible = true
        dialogrect.visible = true
        dialogmsg.text = "Synchronisation\nen cours ..."
        //
        console.log("sync")
        //
        // TEST
        diagtimer.start()
        // TEST
        //
    }
    function addTask() { updateJournal('add',addEdit.text); mainStack.pop(); }
    function modTask() {
        //
        // TODO : check if a mod is already in the journal
        //
        console.log("mod a task")
        //
    }
    function remTask() {
        //
        // TODO : check if the task is in the journal
        //
        console.log("rem a task")
        //
    }
    function updateJournal(action,detail) {
        tododb.transaction(function(tx) {
            var req = [root.appid,action,detail]
            tx.executeSql("INSERT INTO journal VALUES(CURRENT_TIMESTAMP,?,?,?);",req)
        })
    }
    Component.onCompleted: {
        tododb = LocalStorage.openDatabaseSync("OthyTodoListDB","1.0","",1000000,dbinit)
        tododb.transaction(function(tx) {
            //
            // TODO : update the todo list from the table todo
            // TODO : update the todo list from the table journal
            //
            var rs = tx.executeSql("SELECT * FROM parameters;")
            for (var i=0;i<rs.rows.length;i++) {
                //
                switch (rs.rows.item(i).label) {
                case "appid": root.appid = rs.rows.item(i).value; break
                case "last": root.lastsync = rs.rows.item(i).value; break
                }
                //
            }
            //
            console.log("appid: "+root.appid)
            console.log("last sync: "+root.lastsync)
            //
        })
    }
    // elements
    ListModel { id: todoModel }
    Timer {
        id: diagtimer; interval: 2000; running: false; repeat: false
        onTriggered: {
            dialogrect.visible = false
            dialogblocker.visible = false
        }
    }
    StackView {
        id: mainStack
        //initialItem: connexView
        initialItem: todolistView
        anchors.fill: parent
        Item {
            id: connexView
            visible: false
            Label {
                id: identTitle
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 12
                font.bold: true
                text: "Empire Order"
            }
            TextField {
                id: identEdit
                anchors.top: identTitle.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                onAccepted: root.testIdent()
            }
            Rectangle {
                height: root.heightbtn; width: root.widthbtn+30
                anchors.top: identEdit.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.bluebtn
                radius: 3
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.testIdent()
                }
                Text {
                    anchors.centerIn: parent
                    color: "white"
                    font.pointSize: 12
                    font.bold: true
                    text: "Connexion"
                }
            }
        }
        Item {
            id: todolistView
            visible: false
            Label {
                id: orderTitle
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 12
                font.bold: true
                text: "Quels sont les ordres ?"
            }
            ListView {
                id: todolist
                anchors.top: orderTitle.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: todoBtns.top
                anchors.margins: 10
                clip: true
                model: todoModel
                delegate: Rectangle {
                    //
                    //
                }
            }
            Row {
                id: todoBtns
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Rectangle {
                    height: root.heightbtn; width: root.widthbtn
                    color: root.bluebtn
                    radius: 3
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.synchronize()
                    }
                    Text {
                        anchors.centerIn: parent
                        color: "white"
                        font.pointSize: 12
                        font.bold: true
                        text: "Sync"
                    }
                }
                Rectangle {
                    visible: master
                    height: root.heightbtn; width: root.widthbtn
                    color: root.bluebtn
                    radius: 3
                    MouseArea {
                        anchors.fill: parent
                        onClicked: mainStack.push(addtodoView)
                    }
                    Text {
                        anchors.centerIn: parent
                        color: "white"
                        font.pointSize: 12
                        font.bold: true
                        text: "Ajouter"
                    }
                }
            }
        }
        Item {
            id: addtodoView
            visible: false
            Label {
                id: addTitle
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 12
                font.bold: true
                text: "Nouvel ordre :"
            }
            TextField {
                id: addEdit
                anchors.top: addTitle.bottom
                anchors.margins: 10
                anchors.horizontalCenter: parent.horizontalCenter
                width: (parent.width < 250)? parent.width*0.9 : 250
                height: 80
                wrapMode: TextInput.WordWrap
                maximumLength: 80
                onAccepted: root.addTask()
            }
            Row {
                id: addBtns
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Rectangle {
                    height: root.heightbtn; width: root.widthbtn
                    color: root.bluebtn
                    radius: 3
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.addTask()
                    }
                    Text {
                        anchors.centerIn: parent
                        color: "white"
                        font.pointSize: 12
                        font.bold: true
                        text: "Ajouter"
                    }
                }
                Rectangle {
                    height: root.heightbtn; width: root.widthbtn
                    color: root.bluebtn
                    radius: 3
                    MouseArea {
                        anchors.fill: parent
                        onClicked: mainStack.pop()
                    }
                    Text {
                        anchors.centerIn: parent
                        color: "white"
                        font.pointSize: 12
                        font.bold: true
                        text: "Annuler"
                    }
                }
            }
        }
    }
    // dialogs
    Rectangle {
        id: dialogblocker
        visible: false
        anchors.fill: parent
        color: "black"
        opacity: 0.5
    }
    Rectangle {
        id: dialogrect
        visible: false
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        height: 140
        width: 200
        color: "white"
        border.color: "black"
        border.width: 2
        Text {
            id: dialogmsg
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
