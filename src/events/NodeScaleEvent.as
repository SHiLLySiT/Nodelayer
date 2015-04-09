package events 
{
	import flash.events.Event;
	import models.state.NodeState;
	
	public class NodeScaleEvent extends Event 
	{
		public static const CHANGED:String = "nodeScaleChanged";
		
		public var newScale:Number;
		
		public function NodeScaleEvent(type:String, newScale:Number) 
		{ 
			super(type);
			
			this.newScale = newScale;
		} 
		
	}
	
}