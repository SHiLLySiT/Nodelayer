package controllers 
{
	import events.BackgroundImageEvent;
	import events.NodeEvent;
	import events.ToolEvent;
	import flash.desktop.NativeApplication;
	import flash.display.Loader;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import models.ProjectModel;
	import models.state.NodeState;
	import types.ToolType;
	import views.MainView;
	import views.ui.Node;
	import views.View;
	
	public class MainController implements IController
	{
		private var _id:String;
		public function get id():String { return _id; }
		
		private var _view:MainView;
		public function get view():View { return _view; }
		
		private var _projectModel:ProjectModel;
		private var _overNode:Node;
		private var _selectedNodes:Vector.<Node>;
		private var _currentConnectToolNode:Node;
		private var _dragOffset:Point;
		
		public function MainController() 
		{
			
		}
		
		public function initialize(id:String, view:View, data:Object = null):void
		{
			_id = id;
			_currentConnectToolNode = null;
			_overNode = null;
			_selectedNodes = new Vector.<Node>();
			_dragOffset = new Point();
			
			_view = view as MainView;
			_view.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			_view.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			_view.addEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
			_view.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.onMiddleMouseDown);
			_view.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.onMiddleMouseUp);
			
			_view.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			
			_projectModel = ModelManager.getModel(ProjectModel) as ProjectModel;
			_projectModel.addEventListener(ToolEvent.TOOL_CHANGED, this.onToolChanged);
			_projectModel.addEventListener(NodeEvent.NODE_ADDED, this.onNodeAdded);
			_projectModel.addEventListener(NodeEvent.NODE_REMOVED, this.onNodeRemoved);
			_projectModel.addEventListener(BackgroundImageEvent.CHANGED, this.onBackgroundImageChanged);
			
			// --------------------------- MENUS
			_view.stage.nativeWindow.menu = new NativeMenu(); 
			
			// ---- FILE
			var fileMenu:NativeMenuItem = _view.stage.nativeWindow.menu.addItem(new NativeMenuItem("File")); 
			fileMenu.submenu = new NativeMenu(); 
			
			var newCommand:NativeMenuItem = fileMenu.submenu.addItem(new NativeMenuItem("New")); 
			newCommand.addEventListener(Event.SELECT, this.onNew); 
			
			var openCommand:NativeMenuItem = fileMenu.submenu.addItem(new NativeMenuItem("Open")); 
			openCommand.addEventListener(Event.SELECT, this.onOpen);  
			
			var saveCommand:NativeMenuItem = fileMenu.submenu.addItem(new NativeMenuItem("Save")); 
			saveCommand.addEventListener(Event.SELECT, this.onSave);  
			
			var quitCommand:NativeMenuItem = fileMenu.submenu.addItem(new NativeMenuItem("Quit")); 
			quitCommand.addEventListener(Event.SELECT, this.onQuit);  
			
			// ---- EDIT
			var editMenu:NativeMenuItem = _view.stage.nativeWindow.menu.addItem(new NativeMenuItem("Edit")); 
			editMenu.submenu = new NativeMenu(); 
			
			var loadImageCommand:NativeMenuItem = editMenu.submenu.addItem(new NativeMenuItem("Load Image")); 
			loadImageCommand.addEventListener(Event.SELECT, this.onLoadImage);
			
			// ---- HELP
			var helpMenu:NativeMenuItem = _view.stage.nativeWindow.menu.addItem(new NativeMenuItem("Help")); 
			helpMenu.submenu = new NativeMenu(); 
			
			var aboutCommand:NativeMenuItem = helpMenu.submenu.addItem(new NativeMenuItem("About")); 
			aboutCommand.addEventListener(Event.SELECT, this.onAbout);
		}
		
		public function deinitialize():void
		{
			_view.removeEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			_view.removeEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
			_view.removeEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
			
			_view.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			
			_projectModel.removeEventListener(ToolEvent.TOOL_CHANGED, this.onToolChanged);
			_projectModel.removeEventListener(NodeEvent.NODE_ADDED, this.onNodeAdded);
			_projectModel.removeEventListener(NodeEvent.NODE_REMOVED, this.onNodeRemoved);
			
			_projectModel = null;
			_view = null;
		}
		
		private function onLoadImage(e:Event):void
		{
			var file:File = new File();
			file.browseForOpen("Choose Background Image", [ new FileFilter("Images", "*.jpg;*.gif;*.png") ]);
			file.addEventListener(Event.SELECT, this.onImageSelected);
		}
		
		private function onImageSelected(e:Event):void
		{
			var file:File = e.currentTarget as File;
			// TODO: get relative path to project file
			_projectModel.backgroundImagePath = file.nativePath;
		}
		
		private function onAbout(e:Event):void
		{
			
		}
		
		private function onNew(e:Event):void
		{
			_projectModel.removeAllNodes();
		}
		
		private function onOpen(e:Event):void
		{
			// TODO: prompt user to save current project
			
			var file:File = new File();
			file.browseForOpen("Open Project", [ new FileFilter("Nodelayer Projects", "*.nlp") ]);
			file.addEventListener(Event.SELECT, this.onOpenLocationSelected);
		}
		
		private function onOpenLocationSelected(e:Event):void
		{
			var file:File = e.currentTarget as File;
			file.removeEventListener(Event.SELECT, this.onOpenLocationSelected);
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			
			var data:String = stream.readUTFBytes(stream.bytesAvailable);
			_projectModel.newProject();
			_projectModel.loadProject(data);
			
			stream.close();	
		}
		
		private function onSave(e:Event):void
		{
			var file:File = new File();
			file.browseForSave("Save Project");
			file.addEventListener(Event.SELECT, this.onSaveLocationSelected);
		}
		
		private function onSaveLocationSelected(e:Event):void
		{
			var file:File = e.currentTarget as File;
			file.removeEventListener(Event.SELECT, this.onSaveLocationSelected);
			
			var data:String = _projectModel.saveProject();
			if (file.extension != ".nlp")
			{
				file.nativePath += ".nlp";
			}
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(data);
			stream.close();	
		}
		
		private function onQuit(e:Event):void
		{
			// TODO: prompt if not saved
			NativeApplication.nativeApplication.exit();
		}
		
		private function onBackgroundImageChanged(e:BackgroundImageEvent):void
		{
			_view.setBackgroundImage(_projectModel.backgroundImagePath);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
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
			}
		}
		
		private function onToolChanged(e:ToolEvent):void
		{
			
		}
		
		private function onDragNodeUpdate(e:Event):void
		{
			for each(var node:Node in _selectedNodes)
			{
				node.x = _view.mouseX;
				node.y = _view.mouseY;
				
				var nodeState:NodeState = _projectModel.getNode(node.id);
				nodeState.x = node.x;
				nodeState.y = node.y;
			}
		}
		
		private function onDragNodeEnd(e:MouseEvent):void
		{
			_view.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onDragNodeEnd);
			_view.stage.removeEventListener(Event.ENTER_FRAME, this.onDragNodeUpdate);
		}
		
		private function onDragView(e:Event):void
		{
			_view.x = _view.stage.mouseX + _dragOffset.x;
			_view.y = _view.stage.mouseY + _dragOffset.y;
		}
		
		private function onMiddleMouseDown(e:MouseEvent):void
		{
			_dragOffset.x = _view.x - _view.stage.mouseX;
			_dragOffset.y = _view.y - _view.stage.mouseY;
			
			_view.addEventListener(Event.ENTER_FRAME, onDragView);
		}
		
		private function onMiddleMouseUp(e:MouseEvent):void
		{
			_view.removeEventListener(Event.ENTER_FRAME, onDragView);
		}
		
		private function onMouseWheel(e:MouseEvent):void
		{
			// TODO: scaling
			//_view.scaleX = _view.scaleY += e.delta * 0.01;
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			switch(_projectModel.currentTool)
			{
				case ToolType.ADD:
					deselectAllNodes();
					break;
					
				case ToolType.MODIFY:
					
					break;
			}
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			switch(_projectModel.currentTool)
			{
				case ToolType.ADD:
					var newNodeId:int = createNode((_overNode != null) ? _overNode.id : -1);
					var newNode:Node = _view.getNode(newNodeId);
					deselectAllNodes();
					selectNode(newNode);
					dragSelectedNodes();
					break;
					
				case ToolType.MODIFY:
					if (_overNode == null)
					{
						deselectAllNodes();
					}
					break;
					
				case ToolType.CONNECT:
					if (_currentConnectToolNode != null && _overNode == null)
					{
						_view.endDrawConnectToolLine();
						_currentConnectToolNode = null;
					}
					break;
			}
		}
		
		/*private function onNodeDoubleClick(e:MouseEvent):void
		{
			_selectedNodes.length = 0;
			selectAllNodesOnPath(e.currentTarget as Node);
		}*/
		
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
						_view.endDrawConnectToolLine();
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
				case ToolType.MODIFY:
					deselectAllNodes();
					selectNode(node);
					dragSelectedNodes();
					break;
					
				case ToolType.CONNECT:
					if (_currentConnectToolNode == null)
					{
						_view.startDrawConnectToolLine(node);
						_currentConnectToolNode = node;
					}
					else if (_currentConnectToolNode == node)
					{
						_view.endDrawConnectToolLine();
						_currentConnectToolNode = null;
					}
					else
					{
						connectNodes(_currentConnectToolNode.id, node.id);
						_view.endDrawConnectToolLine();
						_currentConnectToolNode = null;
					}
					break;
			}
		}
		
		private function onNodeMouseOut(e:MouseEvent):void
		{
			var node:Node = e.currentTarget as Node;
			_overNode = null;
		}
		
		private function onNodeMouseOver(e:MouseEvent):void
		{
			var node:Node = e.currentTarget as Node;
			_overNode = node;
		}
		
		private function onNodeRemoved(e:NodeEvent):void
		{
			_view.removeNode(e.nodeId);
		}
		
		private function onNodeAdded(e:NodeEvent):void
		{
			var nodeState:NodeState = _projectModel.getNode(e.nodeId);
			var node:Node = _view.addNode(nodeState.x, nodeState.y, nodeState.id);
			node.addEventListener(MouseEvent.MOUSE_OVER, this.onNodeMouseOver);
			node.addEventListener(MouseEvent.MOUSE_OUT, this.onNodeMouseOut);
			node.addEventListener(MouseEvent.MOUSE_DOWN, this.onNodeMouseDown);
			node.addEventListener(MouseEvent.MOUSE_UP, this.onNodeMouseUp);
			node.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, this.onNodeRightMouseDown);
			//node.addEventListener(MouseEvent.DOUBLE_CLICK, this.onNodeDoubleClick);
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
			nodeState.x = _view.stage.mouseX;
			nodeState.y = _view.stage.mouseY;
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
			_view.stage.addEventListener(MouseEvent.MOUSE_UP, this.onDragNodeEnd);
			_view.stage.addEventListener(Event.ENTER_FRAME, this.onDragNodeUpdate);
		}
		
		private function selectNode(node:Node):void
		{
			_selectedNodes.push(node);
			node.gotoAndStop("_selectedHover");
			
			var nodeState:NodeState = _projectModel.getNode(node.id);
			nodeState.isSelected = true;
		}
		
		private function deselectAllNodes():void
		{
			for each(var n:Node in _view.nodes)
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
		
		/*
		private function selectAllNodesOnPath(node:Node):void
		{
			if (node.isSelected) return;
			
			_selectedNodes.push(node);
			selectNode(node);
			
			var nodeState:NodeState = _projectModel.getNode(node.id);
			for each (var n:NodeState in nodeState.connectedNodes)
			{
				var c:Node = _view.getNode(n.id);
				if (c != null) selectAllNodesOnPath(c);
			}
		}
		
		
		private function selectConnectedNodes(node:Node):void
		{
			var nodeState:NodeState = _projectModel.getNode(node.id);
			for each (var n:Node in nodeState.connectedNodes)
			{
				_view.getNode(n.id).isSelected = true;
			}
		}
		*/
	}

}