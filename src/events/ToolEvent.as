package events 
{
	import flash.events.Event;
	import types.ToolType;
	
	public class ToolEvent extends Event 
	{
		public static const TOOL_CHANGED:String = "toolChanged";
		
		public var oldTool:String;
		public var newTool:String;
		
		public function ToolEvent(type:String, prevTool:String, newTool:String) 
		{ 
			super(type);
			
			this.oldTool = prevTool;
			this.newTool = newTool;
		} 
		
	}
	
}