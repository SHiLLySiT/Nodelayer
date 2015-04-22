package views 
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import util.ApplicationUtility;
	[Embed(source = "../../assets/Views.swf", symbol = "AboutView")]
	public class AboutView extends DraggableView 
	{
		public var versionText:TextField;
		public var okButton:InteractiveObject;
		
		public function AboutView(id:String) 
		{
			super(id);	
			
			this.dragTarget = this;
		}
		
		override public function initialize():void 
		{
			super.initialize();
			
			this.versionText.text = "v" + ApplicationUtility.getVersion();
			this.okButton.addEventListener(MouseEvent.CLICK, this.onOkButtonClick);
		}
		
		override public function deinitialize():void 
		{
			this.okButton.removeEventListener(MouseEvent.CLICK, this.onOkButtonClick);
			super.deinitialize();
		}
		
		private function onOkButtonClick(e:MouseEvent):void
		{
			ViewManager.removeView(this);
		}
		
	}

}