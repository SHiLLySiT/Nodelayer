package views 
{
	import events.BackgroundImageEvent;
	import events.NodeEvent;
	import events.NodeScaleEvent;
	import events.ToolEvent;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Shader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import models.ProjectModel;
	import models.state.NodeState;
	import types.ToolType;
	import views.ui.Node;
	import flash.events.SecurityErrorEvent;
	import flash.system.Security;
	
	[Embed(source = "../../assets/Views.swf", symbol = "MainView")]
	public class MainView extends View 
	{
		private var _nodes:Dictionary;
		public function get nodes():Dictionary { return _nodes; }
		
		private var _projectModel:ProjectModel;
		private var _overNode:Node;
		private var _selectedNodes:Vector.<Node>;
		private var _selectedNodeOffsets:Vector.<Point>;
		private var _currentConnectToolNode:Node;
		private var _dragOffset:Point;
		private var _isShiftPressed:Boolean;
		private var _isControlPressed:Boolean;
		
		private var _connectionLayer:Sprite;
		private var _backgroundImageLoader:Loader;
		private var _connectToolLineNode:Node;
		
		public function MainView(id:String) 
		{
			super(id);	
		}
		
		override public function initialize():void 
		{
			super.initialize();
			
			this.stage.color = 0xF3F3F3;
			
			_connectToolLineNode = null;
			_nodes = new Dictionary();
			_projectModel = ModelManager.getModel(ProjectModel) as ProjectModel;
			
			_backgroundImageLoader = new Loader();
			_backgroundImageLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onErrorLoadingBackgroundImage);
			
			this.addChild(_backgroundImageLoader);
			
			_connectionLayer = new Sprite();
			this.addChild(_connectionLayer);
			
			this.addEventListener(Event.ENTER_FRAME, onUpdateNodeConnectionsEnter);
			this.addEventListener(Event.EXIT_FRAME, onUpdateNodeConnectionsExit);
			
			_projectModel.addEventListener(NodeScaleEvent.CHANGED, onNodeScaleChanged);
			
			_currentConnectToolNode = null;
			_overNode = null;
			_selectedNodes = new Vector.<Node>();
			_dragOffset = new Point();
			_isShiftPressed = false;
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			this.addEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
			this.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.onMiddleMouseDown);
			this.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.onMiddleMouseUp);
			
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
			
			_projectModel = ModelManager.getModel(ProjectModel) as ProjectModel;
			_projectModel.addEventListener(ToolEvent.TOOL_CHANGED, this.onToolChanged);
			_projectModel.addEventListener(NodeEvent.NODE_ADDED, this.onNodeAdded);
			_projectModel.addEventListener(NodeEvent.NODE_REMOVED, this.onNodeRemoved);
			_projectModel.addEventListener(BackgroundImageEvent.CHANGED, this.onBackgroundImageChanged);
		}
		
		override public function deinitialize():void 
		{
			this.removeEventListener(Event.ENTER_FRAME, onUpdateNodeConnectionsEnter);
			this.removeEventListener(Event.EXIT_FRAME, onUpdateNodeConnectionsExit);
			
			_projectModel.removeEventListener(NodeScaleEvent.CHANGED, onNodeScaleChanged);
			
			this.removeChild(_connectionLayer);
			this.removeChild(_backgroundImageLoader);
			
			_backgroundImageLoader.removeEventListener(IOErrorEvent.IO_ERROR, this.onErrorLoadingBackgroundImage);
			
			this.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			this.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			this.removeEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
			
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			this.stage.removeEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
			
			_projectModel.removeEventListener(ToolEvent.TOOL_CHANGED, this.onToolChanged);
			_projectModel.removeEventListener(NodeEvent.NODE_ADDED, this.onNodeAdded);
			_projectModel.removeEventListener(NodeEvent.NODE_REMOVED, this.onNodeRemoved);
			
			_projectModel = null;
			
			_backgroundImageLoader = null;
			_connectionLayer = null;
			
			super.deinitialize();
		}
		
		public function getNode(id:int):Node
		{
			return _nodes[id];
		}
		
		public function setBackgroundImage(path:String):void
		{
			if (path == "" || path == null)
			{
				_backgroundImageLoader.unload();
			}
			else
			{
				// TODO: this throws an error if the image is in a folder outside of the NLP file folder
				var projectFile:File = new File(_projectModel.projectFilePath);
				var imagePath:String = projectFile.parent.url + "/" + path.replace("../", "")
				LogManager.logInfo(this, "Loading image: " + imagePath);
				if (imagePath.indexOf("../") == -1) {
					_backgroundImageLoader.load(new URLRequest(imagePath));
				} else {
					LogManager.logError(this, "File must be in the same folder as the project (.NPL) file!");
				}
			}
		}
		
		public function removeNode(id:int):void
		{
			var node:Node = _nodes[id];
			node.removeEventListener(MouseEvent.MOUSE_OVER, this.onNodeMouseOver);
			node.removeEventListener(MouseEvent.MOUSE_OUT, this.onNodeMouseOut);
			this.removeChild(node);
			
			delete _nodes[id];
		}
		
		public function addNode(x:Number, y:Number, id:int):Node
		{
			var node:Node = new Node();
			node.id = id;
			node.scaleX = _projectModel.nodeScale;
			node.scaleY = _projectModel.nodeScale;
			node.x = x;
			node.y = y;
			node.mouseChildren = false;
			node.doubleClickEnabled = true;
			node.addEventListener(MouseEvent.MOUSE_OVER, this.onNodeMouseOver);
			node.addEventListener(MouseEvent.MOUSE_OUT, this.onNodeMouseOut);
			this.addChild(node);
			_nodes[id] = node;
			return node;
		}
		
		public function endDrawConnectToolLine():void
		{
			_connectToolLineNode.removeEventListener(Event.ENTER_FRAME, onDrawConnectToolLine);
			_connectToolLineNode = null;
		}
		
		public function startDrawConnectToolLine(startNode:Node):void
		{
			_connectToolLineNode = startNode;
			_connectToolLineNode.addEventListener(Event.ENTER_FRAME, onDrawConnectToolLine);
		}
		
		private function onNodeScaleChanged(e:NodeScaleEvent):void
		{
			for each(var node:Node in _nodes)
			{
				node.scaleX = e.newScale;
				node.scaleY = e.newScale;
			}
		}
		
		private function onErrorLoadingBackgroundImage(e:IOErrorEvent):void
		{
			LogManager.logError(this, "Error loading background image! " + e.errorID);
		}
		
		private function onDrawConnectToolLine(e:Event):void
		{
			var startNode:Node = e.currentTarget as Node;
			_connectionLayer.graphics.lineStyle(3, 0xF57900);
			
			_connectionLayer.graphics.moveTo(startNode.x - _connectionLayer.x, startNode.y - _connectionLayer.y);
			_connectionLayer.graphics.lineTo(this.mouseX - _connectionLayer.x, this.mouseY - _connectionLayer.y);
		}
		
		private function onNodeMouseOut(e:MouseEvent):void
		{
			var node:Node = e.currentTarget as Node;
			_overNode = null;
			var nodeState:NodeState = _projectModel.getNode(node.id);
			if (nodeState.isSelected)
			{
				node.gotoAndStop("_selected");
			}
			else
			{
				node.gotoAndStop("_normal");
			}
		}
		
		private function onNodeMouseOver(e:MouseEvent):void
		{
			var node:Node = e.currentTarget as Node;
			_overNode = node;
			var nodeState:NodeState = _projectModel.getNode(node.id);
			if (nodeState.isSelected)
			{
				node.gotoAndStop("_selectedHover");
			}
			else
			{
				node.gotoAndStop("_normalHover");
			}
		}
		
		private function onUpdateNodeConnectionsEnter(e:Event):void
		{
			_connectionLayer.graphics.clear();
		}
		
		private function onUpdateNodeConnectionsExit(e:Event):void
		{
			_connectionLayer.graphics.lineStyle(3, 0x2E3436);
			
			for each(var node:Node in _nodes)
			{
				// TODO: draw lines diffrent color when connected to selected nodes
				/*if (node.isSelected)
				{
					_connectionLayer.graphics.lineStyle(3, 0xF57900);
				}
				else
				{
					_connectionLayer.graphics.lineStyle(3, 0x2E3436);
				}*/
				
				var nodeState:NodeState = _projectModel.getNode(node.id);
				for each(var id:int in nodeState.connectedNodes)
				{
					// TODO: visually represent twoway/oneway connections
					var connected:NodeState = _projectModel.getNode(id);
					_connectionLayer.graphics.moveTo(node.x - _connectionLayer.x, node.y - _connectionLayer.y);
					_connectionLayer.graphics.lineTo(connected.x - _connectionLayer.x, connected.y - _connectionLayer.y);
				}
			}
		}
		
		
		
		private function onBackgroundImageChanged(e:BackgroundImageEvent):void
		{
			this.setBackgroundImage(_projectModel.backgroundImagePath);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.NUMBER_1:
					if (_isControlPressed) setDocumentScale(1.0);
					break;
					
				case Keyboard.EQUAL:
					if (_isControlPressed) setDocumentScale(this.scaleX + 0.2);
					break;
					
				case Keyboard.MINUS:
					if (_isControlPressed) setDocumentScale(this.scaleX - 0.2);
					break;
					
				case Keyboard.BACKQUOTE:
					var view:View = ViewManager.getViewById("Debug");
					if (view != null)
					{
						ViewManager.removeView(view);
					}
					else
					{
						ViewManager.addView("Debug");
					}
					break;
					
				case Keyboard.CONTROL:
					_isControlPressed = true;
					break;
					
				case Keyboard.SHIFT:
					_isShiftPressed = true;
					break;
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.CONTROL:
					_isControlPressed = false;
					break;
					
				case Keyboard.SHIFT:
					_isShiftPressed = false;
					break;
			}
		}
		
		private function setDocumentScale(newScale:Number):void
		{
			if (newScale < 0.1) 
			{
				this.scaleX = this.scaleY = 0.1;
			} 
			else if (newScale > 4.0) 
			{
				this.scaleX = this.scaleY = 4.0;
			}
			else
			{
				this.scaleX = this.scaleY = newScale;
			}
		}
		
		private function onToolChanged(e:ToolEvent):void
		{
			this.deselectAllNodes();
		}
		
		private function onDragNodeUpdate(e:Event):void
		{
			for (var i:int = 0; i < _selectedNodes.length; i++)
			{
				var newX:Number = this.mouseX + _selectedNodeOffsets[i].x;
				var newY:Number = this.mouseY + _selectedNodeOffsets[i].y;
				newX = (newX < 0) ? 0 : (newX > _projectModel.documentWidth) ? _projectModel.documentWidth : newX;
				newY = (newY < 0) ? 0 : (newY > _projectModel.documentHeight) ? _projectModel.documentHeight : newY;
				
				var node:Node = _selectedNodes[i];
				node.x = newX;
				node.y = newY;
				
				var nodeState:NodeState = _projectModel.getNode(node.id);
				nodeState.x = newX;
				nodeState.y = newY;
			}
		}
		
		private function onDragNodeEnd(e:MouseEvent):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onDragNodeEnd);
			this.stage.removeEventListener(Event.ENTER_FRAME, this.onDragNodeUpdate);
		}
		
		private function onDragView(e:Event):void
		{
			this.x = this.stage.mouseX + _dragOffset.x;
			this.y = this.stage.mouseY + _dragOffset.y;
		}
		
		private function onMiddleMouseDown(e:MouseEvent):void
		{
			_dragOffset.x = this.x - this.stage.mouseX;
			_dragOffset.y = this.y - this.stage.mouseY;
			
			this.addEventListener(Event.ENTER_FRAME, onDragView);
		}
		
		private function onMiddleMouseUp(e:MouseEvent):void
		{
			this.removeEventListener(Event.ENTER_FRAME, onDragView);
		}
		
		private function onMouseWheel(e:MouseEvent):void
		{
			if (_isControlPressed) {
				setDocumentScale(this.scaleX + e.delta * 0.01);
			}
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			switch(_projectModel.currentTool)
			{
				case ToolType.ADD:
					deselectAllNodes();
					break;
					
				case ToolType.MODIFY:
					if (_overNode == null)
					{
						deselectAllNodes();
					}
					break;
			}
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			switch(_projectModel.currentTool)
			{
				case ToolType.ADD:
					var newNodeId:int = createNode((_overNode != null) ? _overNode.id : -1);
					var newNode:Node = this.getNode(newNodeId);
					deselectAllNodes();
					selectNode(newNode);
					dragSelectedNodes();
					break;
					
				case ToolType.MODIFY:
					
					break;
					
				case ToolType.CONNECT:
					if (_currentConnectToolNode != null && _overNode == null)
					{
						this.endDrawConnectToolLine();
						_currentConnectToolNode = null;
					}
					break;
			}
		}
		
		private function onNodeDoubleClick(e:MouseEvent):void
		{
			if (_projectModel.currentTool == ToolType.MODIFY)
			{
				deselectAllNodes();
				selectAllNodesOnPath(e.currentTarget as Node);
			}
		}
		
		private function onNodeRightMouseDown(e:MouseEvent):void
		{
			var node:Node = e.currentTarget as Node;
			switch (_projectModel.currentTool)
			{
				case ToolType.ADD:
					_projectModel.removeNode(node.id);
					break;
					
				case ToolType.MODIFY:
					_projectModel.removeNode(node.id);
					break;
					
				case ToolType.CONNECT:
					this.breakNodeConnections(node.id);
					break;
			}
		}
		
		private function onNodeMouseUp(e:MouseEvent):void
		{
			var node:Node = e.currentTarget as Node;
			switch (_projectModel.currentTool)
			{
				case ToolType.ADD:
					break;
					
				case ToolType.MODIFY:
					break;
					
				case ToolType.CONNECT:
					if (_currentConnectToolNode != null && _currentConnectToolNode != node)
					{
						connectNodes(_currentConnectToolNode.id, node.id);
						this.endDrawConnectToolLine();
						_currentConnectToolNode = null;
					}
					break;
			}
		}
		
		private function onNodeMouseDown(e:MouseEvent):void
		{
			var node:Node = e.currentTarget as Node;
			switch (_projectModel.currentTool)
			{
				case ToolType.ADD:
					break;
					
				case ToolType.MODIFY:
					var nodeState:NodeState = _projectModel.getNode(node.id);
					if (!nodeState.isSelected && !_isShiftPressed) 
					{
						deselectAllNodes();
					} 
					else 
					{
						if (_overNode == null) 
						{
							deselectAllNodes();
						}
					}
					
					if (_overNode != null)
					{
						selectNode(_overNode);
						dragSelectedNodes();
					}
					//selectNode(node);
					//dragSelectedNodes();
					break;
					
				case ToolType.CONNECT:
					if (_currentConnectToolNode == null)
					{
						this.startDrawConnectToolLine(node);
						_currentConnectToolNode = node;
					}
					else if (_currentConnectToolNode == node)
					{
						this.endDrawConnectToolLine();
						_currentConnectToolNode = null;
					}
					else
					{
						connectNodes(_currentConnectToolNode.id, node.id);
						this.endDrawConnectToolLine();
						_currentConnectToolNode = null;
					}
					break;
			}
		}
		
		private function onNodeRemoved(e:NodeEvent):void
		{
			this.removeNode(e.nodeId);
		}
		
		private function onNodeAdded(e:NodeEvent):void
		{
			var nodeState:NodeState = _projectModel.getNode(e.nodeId);
			var node:Node = this.addNode(nodeState.x, nodeState.y, nodeState.id);
			node.addEventListener(MouseEvent.MOUSE_OVER, this.onNodeMouseOver);
			node.addEventListener(MouseEvent.MOUSE_OUT, this.onNodeMouseOut);
			node.addEventListener(MouseEvent.MOUSE_DOWN, this.onNodeMouseDown);
			node.addEventListener(MouseEvent.MOUSE_UP, this.onNodeMouseUp);
			node.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, this.onNodeRightMouseDown);
			node.addEventListener(MouseEvent.DOUBLE_CLICK, this.onNodeDoubleClick);
		}
		
		private function breakNodeConnections(node:int):void 
		{
			var nodeState:NodeState = _projectModel.getNode(node);
			for each (var c:int in nodeState.connectedNodes) {
				var state:NodeState = _projectModel.getNode(c);
				var i:int = state.connectedNodes.indexOf(node);
				state.connectedNodes.splice(i, 1);
			}
			nodeState.connectedNodes.length = 0;
		}
		
		private function connectNodes(node1:int, node2:int):void
		{
			var node1State:NodeState = _projectModel.getNode(node1);
			var node2State:NodeState = _projectModel.getNode(node2);
			if (!node1State.hasConnection(node2) && !node2State.hasConnection(node1)) 
			{
				node1State.connectedNodes.push(node2);
				node2State.connectedNodes.push(node1);
			}
		}
		
		private function createNode(connection:int = -1):int
		{
			var id:int = _projectModel.getNodeID();
			
			var nodeState:NodeState = new NodeState();
			nodeState.id = id;
			nodeState.x = this.mouseX;
			nodeState.y = this.mouseY;
			_projectModel.addNode(nodeState);
			
			if (connection != -1) 
			{
				// make two-way connection
				var otherNode:NodeState = _projectModel.getNode(connection);
				otherNode.connectedNodes.push(nodeState.id);
				nodeState.connectedNodes.push(otherNode.id);
			}
			
			return id;
		}
		
		private function dragSelectedNodes():void
		{
			_selectedNodeOffsets = new Vector.<Point>();
			for each (var n:Node in _selectedNodes)
			{
				_selectedNodeOffsets.push(new Point(n.x - this.mouseX, n.y - this.mouseY));
			}
			
			this.stage.addEventListener(MouseEvent.MOUSE_UP, this.onDragNodeEnd);
			this.stage.addEventListener(Event.ENTER_FRAME, this.onDragNodeUpdate);
		}
		
		private function selectNode(node:Node):void
		{
			var nodeState:NodeState = _projectModel.getNode(node.id);
			if (!nodeState.isSelected) 
			{
				_selectedNodes.push(node);
				node.gotoAndStop("_selectedHover");	
				nodeState.isSelected = true;
			}
		}
		
		private function deselectAllNodes():void
		{
			for each(var n:Node in this.nodes)
			{
				deselectNode(n);
			}
		}
		
		private function deselectNode(node:Node):void
		{
			_selectedNodes.length = 0;
			node.gotoAndStop("_normal");
			
			var nodeState:NodeState = _projectModel.getNode(node.id);
			nodeState.isSelected = false;
		}
		
		private function selectAllNodesOnPath(node:Node):void
		{
			var nodeState:NodeState = _projectModel.getNode(node.id);
			if (nodeState.isSelected) return;
			
			_selectedNodes.push(node);
			selectNode(node);
			
			for each (var id:int in nodeState.connectedNodes)
			{
				var c:Node = this.getNode(id);
				if (c != null) selectAllNodesOnPath(c);
			}
		}
		
	}

}