package models 
{
	import events.BackgroundImageEvent;
	import events.NodeEvent;
	import events.NodeScaleEvent;
	import events.ToolEvent;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import models.EditorModel;
	import models.state.NodeState;
	import types.ToolType;
	import util.ApplicationUtility;
	import views.AlertView;
	
	public class ProjectModel extends EventDispatcher implements IModel
	{
		private var _currentTool:String;
		public function get currentTool():String { return _currentTool; }
		public function set currentTool(value:String):void
		{
			if (_currentTool != value) {
				if (this.hasEventListener(ToolEvent.TOOL_CHANGED))
				{
					this.dispatchEvent(new ToolEvent(ToolEvent.TOOL_CHANGED, _currentTool, value));
				}
				_currentTool = value;
			}
		}
		
		private var _backgroundImageFile:File;
		public function get backgroundImageFile():File { return _backgroundImageFile; }
		public function set backgroundImageFile(value:File):void 
		{
			_backgroundImageFile = value;
			
			if (this.hasEventListener(BackgroundImageEvent.CHANGED))
			{
				this.dispatchEvent(new BackgroundImageEvent(BackgroundImageEvent.CHANGED));
			}
		}
		
		private var _nodeScale:Number;
		public function get nodeScale():Number { return _nodeScale; }
		public function set nodeScale(value:Number):void 
		{ 
			_nodeScale = value; 
			if (this.hasEventListener(NodeScaleEvent.CHANGED))
			{
				this.dispatchEvent(new NodeScaleEvent(NodeScaleEvent.CHANGED, _nodeScale));
			}
		}
		
		private var _unsavedChanges:Boolean;
		public function get unsavedChanges():Boolean { return _unsavedChanges; }
		public function set unsavedChanges(value:Boolean):void { _unsavedChanges = value; }
		
		private var _projectDirectory:File;
		public function get projectDirectory():File { return _projectDirectory; }
		public function set projectDirectory(value:File):void 
		{ 
			_projectDirectory = value; 
			
		}
		
		private var _documentWidth:int;
		public function get documentWidth():int { return _documentWidth; }
		//public function set documentWidth(value:int):void 
		//{
		//	this._documentWidth = value;
		//}
		
		private var _documentHeight:int;
		public function get documentHeight():int { return _documentHeight; }
		//public function set documentHeight(value:int):void 
		//{
		//	this._documentHeight = value;
		//}
		
		private var _nodeCount:int;
		public function get nodeCount():int { return _nodeCount; }
		
		private var _lastNodeID:int;
		private var _nodeStates:Dictionary;
		
		public function ProjectModel() 
		{
			
		}
		
		public function initialize():void
		{
			_documentWidth = 800;
			_documentHeight = 600;
			_currentTool = ToolType.ADD;
			_lastNodeID = 0;
			_nodeStates = new Dictionary();
			_nodeScale = 1.0;
			_backgroundImageFile = null;
			_projectDirectory = null;
			_unsavedChanges = false;
		}
		
		public function newProject():void
		{
			removeAllNodes();
			_lastNodeID = 0;
		}
		
		public function getNodeID():int
		{
			// when projects are loaded, we don't know the id's of nodes
			// so we need to ensure they dont already exist
			// FUTURE: when saving, loop through nodes and re-number them
			while (_nodeStates[_lastNodeID] != null)
			{
				_lastNodeID++;
			}
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
		
		public function exportJSON():String 
		{
			// layers
			var data:String = '{\n\t"layers": {';
			
			// TODO: layer support
			data += '\n\t\t"layer0": {';
			
			// nodes
			var firstNode:Boolean = true;
			for each(var nodeState:NodeState in _nodeStates)
			{
				var attributes:Object = new Object();
				attributes.id = nodeState.id;
				attributes.y = nodeState.y;
				attributes.x = nodeState.x;
				
				data += ((firstNode) ? '' : ',') + '\n\t\t\t"' + nodeState.id + '": {' 
					+ '\n\t\t\t\t"x": ' + nodeState.x + ','
					+ '\n\t\t\t\t"y": ' + nodeState.y + ',';
					
				data += '\n\t\t\t\t"connections": ['
				
				var firstConnection:Boolean = true;
				for each (var connection:int in nodeState.connectedNodes)
				{
					data += ((firstConnection) ? '' : ',') + '\n\t\t\t\t\t"' + connection + '"';
					firstConnection = false;
				}
				data += '\n\t\t\t\t]'
				
				data += '\n\t\t\t}';
				
				firstNode = false;
			}
			data += '\n\t\t}';
			
			data += '\n\t}\n}';
			
			return data;
		}
		
		public function exportXML():String 
		{
			// layers
			var data:String = '<layers>';
			
			// TODO: layer support
			data += '\n\t<layer name="layer0">';
			
			// nodes
			for each(var nodeState:NodeState in _nodeStates)
			{
				var attributes:Object = new Object();
				attributes.id = nodeState.id;
				attributes.y = nodeState.y;
				attributes.x = nodeState.x;
				
				data += '\n\t\t<node id="' + nodeState.id + '" x="' + nodeState.x +'" y="' + nodeState.y + '">';
				
				for each (var connection:int in nodeState.connectedNodes)
				{
					data += '\n\t\t\t<connection id="' + connection +'" />';
				}
				
				data += '\n\t\t</node>';
			}
			data += '\n\t</layer>';
			
			data += '\n</layers>';
			
			return data;
		}
		
		public function saveProject(directory:File):String
		{
			var relativePath:String = (backgroundImageFile == null) ? "" : directory.getRelativePath(backgroundImageFile, true);
			
			var data:String = '<project version="' + ApplicationUtility.getVersion() + '">';
			
			// project settings
			data += '\n\t<settings>'
				+ '\n\t\t<bgImagePath>' + relativePath + '</bgImagePath>'
				+ '\n\t\t<nodeScale>' + _nodeScale + '</nodeScale>'
				+ '\n\t</settings>'
			
			// layers
			data += '\n\t<layers>';
			
			// TODO: layer support
			data += '\n\t\t<layer name="layer0">';
			
			// nodes
			for each(var nodeState:NodeState in _nodeStates)
			{
				var attributes:Object = new Object();
				attributes.id = nodeState.id;
				attributes.y = nodeState.y;
				attributes.x = nodeState.x;
				
				data += '\n\t\t\t<node id="' + nodeState.id + '" x="' + nodeState.x +'" y="' + nodeState.y + '" >';
				
				for each (var connection:int in nodeState.connectedNodes)
				{
					data += '\n\t\t\t\t<connection id="' + connection +'" />';
				}
				
				data += '\n\t\t\t</node>';
			}
			data += '\n\t\t</layer>';
			
			data += '\n\t</layers>';
			
			data += '\n</project>';
			
			return data;
		}
		
		public function loadProject(directory:File, data:String):void
		{
			var xml:XML = new XML(data);
			
			// different version warning
			
			if (xml.@version != ApplicationUtility.getVersion())
			{
				LogManager.logWarning(this, "Project was saved with a different version of Nodelayer!");
				var alert:AlertView = ViewManager.addView("Alert") as AlertView;
				alert.setContent("Project version mismatch", "The project opened was created with a different version of Node Layer!");
			}
			
			// bg image
			backgroundImageFile = directory.resolvePath(xml.settings.bgImagePath);
			nodeScale = xml.settings.nodeScale;
			
			// nodes
			for each (var layer:* in xml.layers.layer)
			{
				for each (var node:* in layer.node)
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