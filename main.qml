import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Window 2.2
import QtQuick.LocalStorage 2.0

Window {
    id: root
    visible: true
    visibility: "Maximized"
    width: 640
    height: 480
    title: "Empire Order"
    // functions
    function testIdent() {
        //
        console.log(identEdit.text)
        //
        //
    }
    // elements
    Timer {
        //
        //
    }
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
                text: "Empire Order"
            }
            TextField {
                id: identEdit
                anchors.top: identTitle.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Button {
                anchors.top: identEdit.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Connexion"
                onClicked: root.testIdent()
            }
        }
        Item {
            id: todolistView
            //
            //
        }
        Item {
            id: addtodoView
            //
            //
        }
    }
}
