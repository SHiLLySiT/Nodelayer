package views 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Shader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import models.ProjectModel;
	import models.state.NodeState;
	import views.ui.Node;
	
	[Embed(source = "../../assets/Views.swf", symbol = "MainView")]
	public class MainView extends View 
	{
		private var _nodes:Dictionary;
		public function get nodes():Dictionary { return _nodes; }
		
		private var _projectModel:ProjectModel;
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
		}
		
		override public function deinitialize():void 
		{
			this.removeEventListener(Event.ENTER_FRAME, onUpdateNodeConnectionsEnter);
			this.removeEventListener(Event.EXIT_FRAME, onUpdateNodeConnectionsExit);
			this.removeChild(_connectionLayer);
			this.removeChild(_backgroundImageLoader);
			
			_backgroundImageLoader.removeEventListener(IOErrorEvent.IO_ERROR, this.onErrorLoadingBackgroundImage);
			
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
			_backgroundImageLoader.load(new URLRequest(path));
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
		
		private function onErrorLoadingBackgroundImage(e:IOErrorEvent):void
		{
			LogManager.logError(this, "Error loading background image!");
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
	}

}