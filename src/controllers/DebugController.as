package controllers 
{
	import events.LogManagerEvent;
	import views.DebugView;
	import views.View;
	
	public class DebugController implements IController
	{
		private var _id:String;
		public function get id():String { return _id; }
		
		private var _view:DebugView;
		public function get view():View { return _view; }
		
		public function DebugController() 
		{
			
		}
		
		public function initialize(id:String, view:View, data:Object = null):void
		{
			_id = id;
			
			_view = view as DebugView;
			
			_view.stage.addEventListener(LogManagerEvent.LOG_ADDED, this.onLogAdded);
			
			for each(var log:String in LogManager.logs)
			{
				addMessage(log);
			}
		}
		
		public function deinitialize():void
		{
			_view.stage.removeEventListener(LogManagerEvent.LOG_ADDED, this.onLogAdded);
			_view = null;
		}
		
		private function onLogAdded(e:LogManagerEvent):void
		{
			addMessage(e.log);
		}
		
		public function addMessage(msg:String):void
		{
			_view.consoleText.htmlText += msg;
			_view.consoleText.scrollV = _view.consoleText.maxScrollV;
		}
	}

}