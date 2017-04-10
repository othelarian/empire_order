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
    property bool master
    property int widthbtn: 80
    property int heightbtn: 30
    property color bluebtn: "#3af"
    // functions
    function dbinit(db) {
        //
        //
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
        console.log("sync")
        //
    }
    function addTask() {
        //
        console.log("add a task")
        //
    }
    function modTask() {
        //
        console.log("mod a task")
        //
    }
    function remTask() {
        //
        console.log("rem a task")
        //
    }

    Component.onCompleted: {
        //
        console.log("init local storage")
        //
    }
    // elements
    ListModel { id: todoModel }
    StackView {
        id: mainStack
        initialItem: connexView
        anchors.fill: parent
        Item {
            id: connexView
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
            TextEdit {
                id: addEdit
                anchors.top: addTitle.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: addBtns.top
                anchors.margins: 10
                //
                //
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
}
