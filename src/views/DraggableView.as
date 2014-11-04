package views 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class DraggableView extends View
	{
		private var _dragOffset:Point;
		
		public function DraggableView(id:String) 
		{
			super(id);
			_dragOffset = new Point();
		}
		
		override public function initialize():void 
		{
			super.initialize();
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
		}
		
		override public function deinitialize():void 
		{
			super.deinitialize();
			
			this.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			this.removeEventListener(Event.ENTER_FRAME, this.onDrag);
			this.removeEventListener(MouseEvent.MOUSE_UP, this.onDragStop);
		}
		
		private function onDragStop(e:MouseEvent):void
		{
			this.removeEventListener(Event.ENTER_FRAME, this.onDrag);
			this.removeEventListener(MouseEvent.MOUSE_UP, this.onDragStop);
		}
		
		private function onDrag(e:Event):void
		{
			this.x = this.stage.mouseX + _dragOffset.x;
			this.y = this.stage.mouseY + _dragOffset.y;
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			_dragOffset.x = this.x - this.stage.mouseX;
			_dragOffset.y = this.y - this.stage.mouseY;
			
			this.addEventListener(Event.ENTER_FRAME, this.onDrag);
			this.addEventListener(MouseEvent.MOUSE_UP, this.onDragStop);
		}
	}

}