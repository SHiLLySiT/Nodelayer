package views 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import views.ui.ToolTip;
	
	public class View extends Sprite 
	{
		private const TOOLTIP_DELAY:int = 1000;
		
		private var _id:String;
		public function get id():String { return _id; }
		
		private var _tooltips:Dictionary;
		private var _currentTooltip:ToolTip;
		private var _currentTooltipTarget:MovieClip;
		private var _currentTooltipTime:Number;
		
		public function View(id:String) 
		{
			super();
			
			_id = id;
			_tooltips = new Dictionary();
			
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		}
		
		public function initialize():void
		{
			this.addEventListener(Event.ENTER_FRAME, this.onUpdateCurrentTooltip);
		}
		
		public function deinitialize():void
		{
			this.removeEventListener(Event.ENTER_FRAME, this.onUpdateCurrentTooltip);
			_currentTooltipTarget = null;
			if (_currentTooltip != null)
			{
				this.stage.removeChild(_currentTooltip);
				_currentTooltip = null;
			}
		}
		
		private function onAddedToStage(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
			this.initialize();
		}
		
		private function onRemovedFromStage(e:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
			this.deinitialize();
		}
		
		public function addTooltip(target:MovieClip, text:String):void
		{
			target.addEventListener(MouseEvent.MOUSE_OVER, this.onTooltipMouseOver);
			target.addEventListener(MouseEvent.MOUSE_OUT, this.onTooltipMouseOut);
			_tooltips[target] = text;
		}
		
		private function onUpdateCurrentTooltip(e:Event):void
		{
			if (_currentTooltipTarget != null)
			{
				if (_currentTooltip == null)
				{
					if (new Date().time - _currentTooltipTime >= TOOLTIP_DELAY)
					{
						_currentTooltip = new ToolTip();
						_currentTooltip.x = this.stage.mouseX;
						_currentTooltip.y = this.stage.mouseY - 16;
						_currentTooltip.setText(_tooltips[_currentTooltipTarget]);
						this.stage.addChild(_currentTooltip);
					}
				}
				else
				{
					_currentTooltip.x = this.stage.mouseX;
					_currentTooltip.y = this.stage.mouseY - 16;
				}
			}
		}
		
		private function onTooltipMouseOut(e:MouseEvent):void
		{
			if (_currentTooltip != null)
			{
				this.stage.removeChild(_currentTooltip);
				_currentTooltip = null;
			}
			_currentTooltipTarget = null;
		}
		
		private function onTooltipMouseOver(e:MouseEvent):void
		{
			_currentTooltipTarget = e.target as MovieClip;
			_currentTooltipTime = new Date().time;
		}
	}

}