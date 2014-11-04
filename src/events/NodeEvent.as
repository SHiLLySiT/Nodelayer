package events 
{
	import flash.events.Event;
	import models.state.NodeState;
	
	public class NodeEvent extends Event 
	{
		public static const NODE_ADDED:String = "nodeAdded";
		public static const NODE_REMOVED:String = "nodeRemoved";
		
		public var nodeId:int;
		
		public function NodeEvent(type:String, nodeId:int) 
		{ 
			super(type);
			
			this.nodeId = nodeId;
		} 
		
	}
	
}