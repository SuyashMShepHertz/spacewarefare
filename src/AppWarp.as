
import com.adobe.serialization.json.JSON;
import com.shephertz.appwarp.WarpClient;
import com.shephertz.appwarp.listener.ConnectionRequestListener;
import com.shephertz.appwarp.listener.NotificationListener;
import com.shephertz.appwarp.listener.RoomRequestListener;
import com.shephertz.appwarp.messages.Chat;
import com.shephertz.appwarp.messages.LiveRoom;
import com.shephertz.appwarp.messages.Lobby;
import com.shephertz.appwarp.messages.Move;
import com.shephertz.appwarp.messages.Room;
import com.shephertz.appwarp.types.ResultCode;

import flash.utils.ByteArray;

var APIKEY:String = "b737804fa68a9314b1230e90fedf2d42fe4246f20f1efb0d5bc53351dce9e98a";
var SECRETEKEY:String = "adfbfe14b4d4bba6b9b652252f71856ece42901ed8c9f63dbb21eaf38a48d941";

var Connected:Boolean = false;
var INITIALIZED:Boolean = false;

var client:WarpClient;
var State:int = 0;
var User:String;
var Name:String;

class connectionListener implements ConnectionRequestListener
{	
	private var caller:Object;
	
	public function connectionListener(c:Object):void
	{
		caller = c;
	}
	
	public function onConnectDone(res:int):void
	{
		if(res == ResultCode.success)
			Connected = true;
		else
			Connected = false;
		
		caller.connectDone(res);
	}
	
	public function onDisConnectDone(res:int):void
	{
		Connected = false;
		caller.disconnectDone(res);
	}
}

class roomListener implements RoomRequestListener
{	
	private var caller:Object;
	private var roomId:String;
	
	public function roomListener(id:String,c:Object):void
	{
		caller = c;	
		roomId = id;
		client.subscribeRoom(roomId);
	}
	
	public function onSubscribeRoomDone(event:Room):void
	{
		if(event.result == ResultCode.success)
		{
			client.joinRoom(roomId);
		}
		else
		{
			caller.joinDone(ResultCode.unknown_error);
		}
	}
	public function onUnsubscribeRoomDone(event:Room):void
	{
		client.leaveRoom(event.roomId);
	}
	public function onJoinRoomDone(event:Room):void
	{
		if(event.result == ResultCode.success)
		{
			caller.joinDone(ResultCode.success);
		}
		else
		{
			caller.joinDone(ResultCode.unknown_error);
		}
	}
	public function onLeaveRoomDone(event:Room):void
	{
		
	}
	public function onGetLiveRoomInfoDone(event:LiveRoom):void
	{
		caller.roomInfoDone(event);
	}
	public function onSetCustomRoomDataDone(event:LiveRoom):void
	{
		
	}
	public function onUpdatePropertyDone(event:LiveRoom):void
	{
		
	}
	
	public function onLockPropertiesDone(result:int):void
	{
		
	}
	public function onUnlockPropertiesDone(result:int):void
	{
		
	}
	public function onUpdatePropertiesDone(event:LiveRoom):void
	{
		client.getLiveRoomInfo(event.room.roomId);
	}
}

class notifylistener implements NotificationListener
{	
	private var caller:Object;
	
	public function notifylistener(c:Object):void
	{
		caller = c;
	}
	
	public function onRoomCreated(event:Room):void
	{
		
	}
	public function onRoomDestroyed(event:Room):void
	{
		
	}
	public function onUserLeftRoom(event:Room, user:String):void
	{
		caller.leftRoom(user);
	}
	public function onUserJoinedRoom(event:Room, user:String):void
	{
		
	}
	public function onUserLeftLobby(event:Lobby, user:String):void
	{
		
	}
	public function onUserJoinedLobby(event:Lobby, user:String):void
	{
				
	}
	public function onChatReceived(event:Chat):void
	{
		if(event.sender != User)
			caller.listen(event.sender,com.adobe.serialization.json.JSON.decode(event.chat));
	}
	public function onUpdatePeersReceived(update:ByteArray):void
	{
			
	}
	public function onUserChangeRoomProperty(room:Room, user:String,properties:Object):void
	{
		
	}
	public function onPrivateChatReceived(sender:String, chat:String):void
	{
		
	}
	public function onUserChangeRoomProperties(room:Room, user:String,properties:Object, lockTable:Object):void
	{
		client.getLiveRoomInfo(room.roomId);
	}
	public function onMoveCompleted(move:Move):void
	{
		
	}
}

package
{
	import com.adobe.serialization.json.JSON;
	import com.shephertz.appwarp.WarpClient;
	import com.shephertz.appwarp.types.ResultCode;
	
	//import flash.external.ExternalInterface;

	public class AppWarp
	{	
		private static var _roomlistener:roomListener;
		private static var _notifylistener:notifylistener;
		private static var _connectionlistener:connectionListener;
		
		private static var caller:Object;
		
		private static function generateRandomString(strlen:Number):String{
			var chars:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
			var num_chars:Number = chars.length - 1;
			var randomChar:String = "";
			for (var i:Number = 0; i < strlen; i++){
				randomChar += chars.charAt(Math.floor(Math.random() * num_chars));
			}
			return randomChar;
		}

		public static function connect(c:Object,id:String,username:String):String
		{
			caller = c;
			Name = username;
			if(Connected == false)
			{
				WarpClient.initialize(APIKEY, SECRETEKEY);
				client = WarpClient.getInstance();
				_connectionlistener = new connectionListener(caller);
				client.setConnectionRequestListener(_connectionlistener);
				if(id == "")
					User = generateRandomString(10);
				else
					User = id;
				
				//ExternalInterface.call("console.log",User);
				client.connect(User);
			}
			else
			{
				caller.connectDone(ResultCode.success);
			}
			
			return User;
		}
		
		public static function join(roomId:String):void
		{
			_roomlistener = new roomListener(roomId,caller);
			client.setRoomRequestListener(_roomlistener);
		}
		
		public static function leave(roomId:String):void
		{
			client.unsubscribeRoom(roomId);
		}
		
		public static function startListening():void
		{
			_notifylistener = new notifylistener(caller);
			client.setNotificationListener(_notifylistener);
		}
		
		public static function Send(obj:Object):void
		{
			if(Connected == true)
			{
				client.sendChat(com.adobe.serialization.json.JSON.encode(obj));
			}
		}
		
		public static function SendMove(x:int,y:int):void
		{
			var obj:Object = new Object;
			obj.type = 1;
			obj.x = x;
			obj.y = y;
			if(Name != "")
				obj.name = Name;
			else 
				obj.name = User;
			
			Send(obj);
		}
		
		public static function SendAttack(player:String):void
		{
			var obj:Object = new Object;
			obj.type = 2;
			obj.p = player;
			if(Name != "")
				obj.name = Name;
			else 
				obj.name = User;
			
			Send(obj);
		}
		
		public static function getRoomInfo(room:String):void
		{
			client.getLiveRoomInfo(room);	
		}
		
		public static function setProp(room:String):void
		{
			var str:String = '{"item1": {"x": 9,"y": 10},"item2": {"x": 5,"y": 8},"item3": {"x": 20,"y": 14},"item4": {"x": 15,"y": 18},"item5": {"x": 25,"y": 10}}';
			client.updateRoomProperties(room,com.adobe.serialization.json.JSON.decode(str),new Array("x","y"));
		}
		
		public static function placeItems(room:String,props:Object,prop:String,x:int,y:int):void
		{
			props[prop].x = x;
			props[prop].y = y;
			client.updateRoomProperties(room,props,null);
		}
		
		public static function getUser():String
		{
			return User;
		}
	}
}