package views 
{
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	[Embed(source = "../../assets/Views.swf", symbol = "AlertView")]
	public class AlertView extends View 
	{
		public var titleText:TextField;
		public var contentText:TextField;
		public var okButton:InteractiveObject;
		
		private var _onDismissed:Function;
		private var _mouseBlock:Shape;
		
		public function AlertView(id:String) 
		{
			super(id);
		}
		
		override public function initialize():void 
		{
			super.initialize();
			
			this.x = this.stage.width * 0.5 - this.width * 0.5;
			this.y = this.stage.height * 0.5 - this.height * 0.5;
			
			this.okButton.addEventListener(MouseEvent.CLICK, this.onOkButtonClick);
			
			_mouseBlock = new Shape();
			this.updateMouseBlock();
			this.addChildAt(_mouseBlock, 0);
			
			//this.stage.addEventListener(Event.RESIZE, this.onStageResized);
		}
		
		override public function deinitialize():void 
		{
			this.okButton.removeEventListener(MouseEvent.CLICK, this.onOkButtonClick);
			//this.stage.removeEventListener(Event.RESIZE, this.onStageResized);
			
			this.removeChildren();
			
			super.deinitialize();
		}
		
		public function setContent(title:String, content:String, onDismissed:Function = null):void
		{
			this.titleText.text = title;
			this.contentText.text = content;
			this._onDismissed = onDismissed;
		}
		
		private function onOkButtonClick(e:MouseEvent):void
		{
			if (this._onDismissed != null) this._onDismissed();
			ViewManager.removeView(this);
		}
		
		private function updateMouseBlock():void
		{
			// TODO: resize blocking volume based on window dimensions
			var width:Number = this.stage.width; //this.stage.nativeWindow.width;
			var height:Number = this.stage.height; //this.stage.nativeWindow.height;
			var graphics:Graphics = _mouseBlock.graphics;
			graphics.clear();
			graphics.beginFill(0x000000);
			graphics.drawRect(this.stage.x - width * 0.5 + this.width * 0.5, 
			this.stage.y - height * 0.5 + this.height * 0.5, width, height);
			graphics.endFill();
			_mouseBlock.alpha = 0.5;
		}
		
		//private function onStageResized(e:Event):void
		//{
		//	this.updateMouseBlock();
		//}
	}

}