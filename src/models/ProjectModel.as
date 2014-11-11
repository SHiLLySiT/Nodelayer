package models 
{
	import events.BackgroundImageEvent;
	import events.NodeEvent;
	import events.ToolEvent;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import models.EditorModel;
	import models.state.NodeState;
	import types.ToolType;
	import util.ApplicationUtility;
	
	public class ProjectModel extends EventDispatcher implements IModel
	{
		private var _currentTool:String;
		public function get currentTool():String { return _currentTool; }
		public function set currentTool(value:String):void
		{
			if (this.hasEventListener(ToolEvent.TOOL_CHANGED))
			{
				this.dispatchEvent(new ToolEvent(ToolEvent.TOOL_CHANGED, _currentTool, value));
			}
			_currentTool = value;
		}
		
		private var _backgroundImagePath:String;
		public function get backgroundImagePath():String { return _backgroundImagePath; }
		public function set backgroundImagePath(value:String):void 
		{
			_backgroundImagePath = value;
			
			if (this.hasEventListener(BackgroundImageEvent.CHANGED))
			{
				this.dispatchEvent(new BackgroundImageEvent(BackgroundImageEvent.CHANGED));
			}
		}
		
		private var _nodeCount:int;
		public function get nodeCount():int { return _nodeCount; }
		
		private var _lastNodeID:int;
		private var _nodeStates:Dictionary;
		
		public function ProjectModel() 
		{
			
		}
		
		public function initialize():void
		{
			_currentTool = ToolType.ADD;
			_lastNodeID = -1;
			_nodeStates = new Dictionary();
		}
		
		public function newProject():void
		{
			removeAllNodes();
		}
		
		public function getNodeID():int
		{
			_lastNodeID++;
			return _lastNodeID;
		}
		
		public function removeNode(id:int):void
		{
			var node:NodeState = _nodeStates[id];
			delete _nodeStates[id];
			
			_nodeCount--;
			cleanupDeadConnections();
			
			if (this.hasEventListener(NodeEvent.NODE_REMOVED))
			{
				this.dispatchEvent(new NodeEvent(NodeEvent.NODE_REMOVED, id));
			}
		}
		
		public function removeAllNodes():void
		{
			for each (var node:NodeState in _nodeStates)
			{
				if (this.hasEventListener(NodeEvent.NODE_REMOVED))
				{
					this.dispatchEvent(new NodeEvent(NodeEvent.NODE_REMOVED, node.id));
				}
			}
			_nodeCount = 0;
			_nodeStates = new Dictionary();
		}
		
		public function addNode(node:NodeState):void
		{
			_nodeCount++;
			_nodeStates[node.id] = node;
			
			if (this.hasEventListener(NodeEvent.NODE_ADDED))
			{
				this.dispatchEvent(new NodeEvent(NodeEvent.NODE_ADDED, node.id));
			}
		}
		
		public function getNode(id:int):NodeState
		{
			return _nodeStates[id];
		}
		
		public function saveProject():String
		{
			var data:String = '<project version="' + ApplicationUtility.getVersion() + '" bgImagePath="' + _backgroundImagePath + '">';
			for each(var nodeState:NodeState in _nodeStates)
			{
				var attributes:Object = new Object();
				attributes.id = nodeState.id;
				attributes.y = nodeState.y;
				attributes.x = nodeState.x;
				
				data += '\n\t<node id="' + nodeState.id + '" x="' + nodeState.x +'" y="' + nodeState.y + '" >';
				
				for each (var connection:int in nodeState.connectedNodes)
				{
					data += '\n\t\t<connection id="' + connection +'" />';
				}
				
				data += "\n\t</node>";
			}
			data += "\n</project>";
			return data;
		}
		
		public function loadProject(data:String):void
		{
			var xml:XML = new XML(data);
			
			// different version warning
			
			if (xml.@version != ApplicationUtility.getVersion())
			{
				LogManager.logWarning(this, "Project was saved with a different version of Nodelayer!");
			}
			
			// bg image
			backgroundImagePath = xml.@bgImagePath;
			
			// nodes
			for each (var node:* in xml.node)
			{
				var nodeState:NodeState = new NodeState();
				nodeState.id = node.@id;
				nodeState.x = node.@x;
				nodeState.y = node.@y;
				
				for each (var connection:* in node.connection)
				{
					nodeState.connectedNodes.push(connection.@id);
				}
				
				addNode(nodeState);
			}
		}
		
		private function cleanupDeadConnections():void
		{
			for each (var node:NodeState in _nodeStates)
			{
				for (var i:int = 0; i < node.connectedNodes.length; i++)
				{
					if (getNode(node.connectedNodes[i]) == null)
					{
						node.connectedNodes.splice(i, 1);
						i--;
					}
				}
			}
		}
		
	}

}