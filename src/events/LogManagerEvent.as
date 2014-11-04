package events 
{
	import flash.events.Event;
	import types.ToolType;
	
	public class LogManagerEvent extends Event 
	{
		public static const LOG_ADDED:String = "logManagerLogAdded";
		
		public var log:String;
		
		public function LogManagerEvent(type:String, log:String) 
		{ 
			super(type);
			
			this.log = log;
		} 
		
	}
	
}