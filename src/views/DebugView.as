package views 
{
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
		}
		
		override public function deinitialize():void 
		{
			
			super.deinitialize();
		}
		
		private function onStageResize(e:Event):void
		{
			updatePosition();
		}
		
		private function updatePosition():void
		{
			this.y = this.stage.nativeWindow.height - 209;
			background.width = this.stage.nativeWindow.width;
		}
	}

}