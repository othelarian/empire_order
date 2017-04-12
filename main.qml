import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Window 2.2
import QtQuick.LocalStorage 2.0

import "main.js" as Script

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
    property var ajax
    property string server: "http://localhost/empire_order/index.php"
    property string appid
    property string lastsync
    // functions
    Component.onCompleted: Script.initWindow()
    // elements
    ListModel { id: todoModel }
    Timer {
        id: diagtimer; interval: 2000; running: false; repeat: false
        onTriggered: Script.timerout()
    }
    StackView {
        id: mainStack
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
                onAccepted: Script.testIdent()
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
                    onClicked: Script.testIdent()
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
                anchors.bottom: todoBtns.top
                width: 350
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 20
                spacing: 10
                clip: true
                model: todoModel
                delegate: Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    Rectangle {
                        width: 220; height: 40
                        color: (statut)? "#ddd" : "white"
                        border.color: (journal)? "#aaa" : "black"
                        border.width: 2
                        Text {
                            anchors.fill: parent
                            anchors.margins: 5
                            wrapMode: TextInput.WordWrap
                            font.strikeout: statut
                            color: (journal)? "#aaa" : "black"
                            text: texte
                        }
                    }
                    Rectangle {
                        width: 40; height: 40
                        color: root.bluebtn
                        radius: 3
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Script.modTask(idx)
                        }
                        Text {
                            anchors.centerIn: parent
                            color: "white"; font.bold: true; font.pointSize: 12
                            text: (statut)? "U" : "V"
                        }
                    }
                    Rectangle {
                        width: 40; height: 40
                        color: root.bluebtn
                        radius: 3
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Script.remTask(idx)
                        }
                        Text {
                            anchors.centerIn: parent
                            color: "white"; font.bold: true; font.pointSize: 12
                            text: "X"
                        }
                    }
                }
                ScrollBar.vertical: ScrollBar {
                    parent: todolist.parent
                    anchors.top: todolist.top
                    anchors.left: todolist.right
                    anchors.bottom: todolist.bottom
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
                        onClicked: Script.synchronize()
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
                        onClicked: {
                            addEdit.text = ""
                            mainStack.push(addtodoView)
                        }
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
                maximumLength: 50
                onAccepted: Script.addTask()
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
                        onClicked: Script.addTask()
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
