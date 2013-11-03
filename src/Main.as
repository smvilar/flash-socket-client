package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class Main extends Sprite
	{
		private const IP:String = "localhost";
		private const PORT:int = 50000;
		
		private var _connection:Connection;
		private var _reconnectionAccum:int = 0;
		private var _processingMatch:Boolean;
		private var _initted:Boolean;
		private var _matched:Boolean;
		private var _localName:String;
		private var _remoteName:String;
		
		private var _localActor:Actor;
		private var _remoteActor:Actor;
		private var _keysPressed:Array = [];
		
		public function Main()
		{
			_connection = new Connection(IP, PORT);
			_connection.messageCallback = handleMessage;
			
			addEventListener(Event.ENTER_FRAME, update);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function update(event:Event):void
		{
			if (_connection.online)
			{
				if (!_initted)
					init();
				
				if (!_matched)
					searchRemote();
				
				updateLocal();
			}
			else
			{
				reconnect();
			}
		}
		
		private function reconnect():void
		{
			if (_reconnectionAccum++ > 30)
			{
				trace("not online, reconnecting...");
				_connection = new Connection(IP, PORT);
				_reconnectionAccum = 0;
			}
		}
		
		private function init():void
		{
			_localName = "Player" + int(Math.random() * 200);
			_connection.setName(_localName);
			
			_localActor = new Actor(0xff0000);
			addChild(_localActor);
			
			_initted = true;
		}
		
		private function searchRemote():void
		{
			if (!_processingMatch)
			{
				trace("get all client names");
				_connection.getAllClientNames();
				_processingMatch = true;
			}
		}
		
		private function updateLocal():void
		{
			var speed:int = 10;
			if (_keysPressed[Keyboard.W]) {
				_localActor.y -= speed;
			}
			if (_keysPressed[Keyboard.A]) {
				_localActor.x -= speed;
			}
			if (_keysPressed[Keyboard.S]) {
				_localActor.y += speed;
			}
			if (_keysPressed[Keyboard.D]) {
				_localActor.x += speed;
			}
			
			if (_matched)
				_connection.sendMessageTo(_remoteName, "actorAt", [_localActor.x, _localActor.y]);
		}
		
		private function handleMessage(message:String, params:Object):void
		{
			switch (message) {
				case "allNames":
				{
					trace("all names received");
					_processingMatch = false;
					for each (var name:String in params as Array) {
						if (name != _localName) {
							trace("found: " + name);
							_remoteName = name;
							_matched = true;
							break;
						}
					}
					break;
				}
				case "actorAt":
				{
					if (_remoteActor == null) {
						_remoteActor = new Actor(0x00ff00);
						addChild(_remoteActor);
					}
					_remoteActor.x = parseInt(params[0]);
					_remoteActor.y = parseInt(params[1]);
					break;
				}
			}
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			if (!_initted) return;
			_keysPressed[event.keyCode] = true;
		}
		
		private function onKeyUp(event:KeyboardEvent):void
		{
			if (!_initted) return;
			_keysPressed[event.keyCode] = false;
		}
	}
}