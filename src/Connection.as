package
{
	import flash.errors.*;
	import flash.events.*;
	import flash.net.Socket;
	
	public class Connection
	{
		private const MESSAGE_SET_NAME:String = "setName";
		private const MESSAGE_SEND_TO:String = "sendTo";
		private const MESSAGE_GET_ALL_NAMES:String = "getAllNames";
		
		private var _socket:Socket = new Socket();
		private var _online:Boolean = false;
		
		private var _messageCallback:Function;
		
		public function get online():Boolean {
			return _online;
		}
		
		public function set messageCallback(value:Function):void {
			_messageCallback = value;
		}
		
		public function Connection(host:String, port:uint) {
			_socket.addEventListener(Event.CLOSE, onSocketClose);
			_socket.addEventListener(Event.CONNECT, onSocketConnect);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, onSocketIOError);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketSecurityError);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			
			_socket.connect(host, port);
		}
		
		public function write(str:String):void {
			try {
				_socket.writeUTF(str);
			} catch (e:IOError) {
				_online = false;
				trace(e);
			}
		}
		
		public function writeObject(obj:*):void {
			try {
				_socket.writeObject(obj);
			} catch (e:IOError) {
				_online = false;
				trace(e);
			}
		}
		
		public function flush():void {
			try {
				_socket.flush();
			} catch (e:IOError) {
				_online = false;
				trace(e);
			}
		}
		
		private function onSocketClose(ev:Event):void {
			_online = false;
			trace("socket close: " + ev);
		}
		
		private function onSocketConnect(ev:Event):void {
			_online = true;
		}
		
		private function onSocketIOError(ev:IOErrorEvent):void {
			trace("socket IO error: " + ev);
		}
		
		private function onSocketSecurityError(ev:SecurityErrorEvent):void {
			trace("socket security error: " + ev);
		}
		
		private function onSocketData(ev:ProgressEvent):void {
			try {
				var msg:String = _socket.readUTF();
				var params:Object = _socket.readObject();
				if (_messageCallback != null)
					_messageCallback(msg, params);
			} catch (e:IOError) {
				trace("onSocketData error: " + e);
			} catch (e:EOFError) {
				trace("onSocketData error: " + e);
			}
		}
		
		public function setName(name:String):void {
			write(MESSAGE_SET_NAME);
			write(name);
			flush();
		}
		
		public function sendMessageTo(name:String, msg:String, params:Object = null):void {
			write(MESSAGE_SEND_TO);
			write(name);
			write(msg);
			writeObject(params);
			flush();
		}
		
		public function getAllClientNames():void {
			write(MESSAGE_GET_ALL_NAMES);
			flush();
		}
	}
}
