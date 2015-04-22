package views 
{
	import events.LogManagerEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	
	[Embed(source = "../../assets/Views.swf", symbol = "DebugView")]
	public class DebugView extends View
	{
		public var consoleText:TextField;
		public var background:MovieClip;
		
		public function DebugView(id:String) 
		{
			super(id);
		}
		
		override public function initialize():void 
		{
			super.initialize();
			
			this.stage.addEventListener(Event.RESIZE, onStageResize);
			
			updatePosition();
			
			this.stage.addEventListener(LogManagerEvent.LOG_ADDED, this.onLogAdded);
			
			for each(var log:String in LogManager.logs)
			{
				addMessage(log);
			}
		}
		
		override public function deinitialize():void 
		{
			this.stage.removeEventListener(LogManagerEvent.LOG_ADDED, this.onLogAdded);
			super.deinitialize();
		}
		
		private function onStageResize(e:Event):void
		{
			updatePosition();
		}
		
		private function onLogAdded(e:LogManagerEvent):void
		{
			addMessage(e.log);
		}
		
		public function addMessage(msg:String):void
		{
			this.consoleText.htmlText += msg;
			this.consoleText.scrollV = this.consoleText.maxScrollV;
		}
		
		private function updatePosition():void
		{
			this.y = this.stage.nativeWindow.height - 209;
			background.width = this.stage.nativeWindow.width;
		}
	}

}