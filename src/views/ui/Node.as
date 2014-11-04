package views.ui
{
	import flash.display.MovieClip;
	
	[Embed(source = "../../../assets/Views.swf", symbol = "Node")]
	public class Node extends MovieClip 
	{
		public var id:int;
		
		public function Node() 
		{
			super();
			this.stop();
			id = -1;
		}
	}

}