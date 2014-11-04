package views 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class View extends Sprite 
	{
		private var _id:String;
		public function get id():String { return _id; }
		
		public function View(id:String) 
		{
			super();
			
			_id = id;
			
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		}
		
		public function initialize():void
		{
			
		}
		
		public function deinitialize():void
		{
			
		}
		
		private function onAddedToStage(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
			initialize();
		}
		
		private function onRemovedFromStage(e:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
			this.deinitialize();
		}
		
	}

}