import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import Qt.WebSockets 1.0

ApplicationWindow {
	id: window
	visible: true
	width: 640
	height: 400
	title: qsTr("chat.benary.org (%1)").arg(username)
	property string username: "user_" + parseInt(Math.random()*10000)
	
	ColumnLayout
	{
		id: columnlayout
		anchors.fill: parent
		
		TextArea
		{
			id: messages
			Layout.fillHeight: true
			Layout.fillWidth: true
			
			readOnly: true
		}
		
		RowLayout
		{
			id: rowlayout
			Layout.fillHeight: true
			Layout.fillWidth: true
			
			TextField
			{
				id: input
				Layout.fillWidth: true
				validator: RegExpValidator
				{
					regExp: /.+/
				}
				
				onAccepted:
				{
					var m =
					{
						'time': new Date(),
						'user': window.username,
						'message': input.text,
					};
					input.text = "";
					messages.append("<%1> %2: %3".arg(m.time).arg(m.time).arg(m.message));
					socket.sendTextMessage('42["chatmsg",%1]'.arg(JSON.stringify(m)));
				}
			}
			
			Button
			{
				id: username
				text: qsTr("Change Username")
				
				onClicked: userdialog.open()
			}
			
		}
	}
	
	Dialog
	{
		id: userdialog
		
		standardButtons: StandardButton.Save | StandardButton.Discard
		
		onAccepted:
		{
			if(userfield.text != "")
			{
				window.username = userfield.text
			}
			else
			{
				userfield.text = window.username;
			}
		}
		
		TextField
		{
			id: userfield
			text: window.username
			validator: RegExpValidator
			{
				regExp: /[a-z0-9._-]+/
			}
		}
	}

	WebSocket
	{
		id: socket
		active: true
		url: 'wss://chat.benary.org/socket.io/?transport=websocket'
		
		onStatusChanged:
		{
			switch(status)
			{
				case WebSocket.Connecting:
					messages.append(qsTr("connecting..."));
					break;
				case WebSocket.Open:
					messages.append(qsTr("connected"));
					break;
				case WebSocket.Closing:
					messages.append(qsTr("closing..."));
					break;
				case WebSocket.Closed:
					messages.append(qsTr("closed"));
					socket.active = true;
					break;
				case WebSocket.Error:
					messages.append(qsTr("Error: %1").arg(errorString));
					break;
			}
		}
		
		onTextMessageReceived:
		{
			if(message.match(/^42\["chatmsg",/))
			{
				var json = message.replace(/^42\["chatmsg",/,'[')
				var msgs = JSON.parse(json);
				msgs.forEach(function(m)
				{
					messages.append("<%1> %2: %3".arg(m.time).arg(m.user).arg(m.message));
				});
			}
		}
	}
}
