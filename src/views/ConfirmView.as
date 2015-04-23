package views 
{
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	[Embed(source = "../../assets/Views.swf", symbol = "ConfirmView")]
	public class ConfirmView extends View 
	{
		public var titleText:TextField;
		public var contentText:TextField;
		public var okButton:InteractiveObject;
		public var cancelButton:InteractiveObject;
		
		private var _onAccept:Function;
		private var _onDecline:Function;
		private var _mouseBlock:Shape;
		
		public function ConfirmView(id:String) 
		{
			super(id);
		}
		
		override public function initialize():void 
		{
			super.initialize();
			
			this.x = this.stage.width * 0.5 - this.width * 0.5;
			this.y = this.stage.height * 0.5 - this.height * 0.5;
			
			_mouseBlock = new Shape();
			this.updateMouseBlock();
			this.addChildAt(_mouseBlock, 0);
			
			this.okButton.addEventListener(MouseEvent.CLICK, this.onAcceptButtonClick);
			this.cancelButton.addEventListener(MouseEvent.CLICK, this.onDeclineButtonClick);
			
			//this.stage.addEventListener(Event.RESIZE, this.onStageResized);
		}
		
		override public function deinitialize():void 
		{
			this.okButton.removeEventListener(MouseEvent.CLICK, this.onAcceptButtonClick);
			this.cancelButton.removeEventListener(MouseEvent.CLICK, this.onDeclineButtonClick);
			//this.stage.removeEventListener(Event.RESIZE, this.onStageResized);
			
			super.deinitialize();
		}
		
		public function setContent(title:String, content:String, onAccept:Function = null, onDecline:Function = null):void
		{
			this.titleText.text = title;
			this.contentText.text = content;
			this._onAccept = onAccept;
			this._onDecline = onDecline;
		}
		
		private function onAcceptButtonClick(e:MouseEvent):void
		{
			if (this._onAccept != null) this._onAccept();
			ViewManager.removeView(this);
		}
		
		private function onDeclineButtonClick(e:MouseEvent):void
		{
			if (this._onDecline != null) this._onDecline();
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