package views.ui 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	[Embed(source = "../../../assets/Views.swf", symbol = "ToolTip")]
	public class ToolTip extends MovieClip 
	{
		public var tooltipText:TextField;
		public var tooltipBackground:MovieClip;
		
		public function ToolTip() 
		{
			super();
			this.mouseChildren = false;
			this.mouseEnabled = false;
		}
		
		public function setText(text:String):void
		{
			tooltipText.text = text;
			tooltipBackground.width = tooltipText.textWidth + 5;
		}
		
	}

}