package views 
{
	import events.ToolEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import models.ProjectModel;
	import types.ToolType;
	
	[Embed(source = "../../assets/Views.swf", symbol = "ToolbarView")]
	public class ToolbarView extends DraggableView 
	{
		public var addToolButton:MovieClip;
		public var modifyToolButton:MovieClip;
		public var connectToolButton:MovieClip;
		
		private var _projectModel:ProjectModel;
		private var _toolButtons:Vector.<MovieClip>;
		
		public function ToolbarView(id:String) 
		{
			super(id);
		}
		
		override public function initialize():void 
		{
			super.initialize();
			
			_projectModel = ModelManager.getModel(ProjectModel) as ProjectModel;
			_projectModel.addEventListener(ToolEvent.TOOL_CHANGED, this.onToolChanged);
			
			setupToolButton(addToolButton);
			setupToolButton(modifyToolButton);
			setupToolButton(connectToolButton);
			
			// add tool is default
			addToolButton.gotoAndStop(3);
			
			_toolButtons = new <MovieClip>[addToolButton, modifyToolButton, connectToolButton];
		}
		
		override public function deinitialize():void 
		{
			super.deinitialize();
		}
		
		private function setupToolButton(button:MovieClip):void
		{
			button.stop();
			button.mouseChildren = false;
			button.useHandCursor = true;
			button.buttonMode = true;
			
			button.addEventListener(MouseEvent.CLICK, this.onToolButtonClick);
			button.addEventListener(MouseEvent.MOUSE_OVER, this.onToolButtonOver);
			button.addEventListener(MouseEvent.MOUSE_OUT, this.onToolButtonOut);
		}
		
		private function onToolChanged(e:ToolEvent):void
		{
			switch (e.oldTool)
			{
				case ToolType.ADD: addToolButton.gotoAndStop(1); break;
				case ToolType.MODIFY: modifyToolButton.gotoAndStop(1); break;
				case ToolType.CONNECT: connectToolButton.gotoAndStop(1); break;
			}
			
			switch (e.newTool)
			{
				case ToolType.ADD: addToolButton.gotoAndStop(3); break;
				case ToolType.MODIFY: modifyToolButton.gotoAndStop(3); break;
				case ToolType.CONNECT: connectToolButton.gotoAndStop(3); break;
			}
		}
		
		private function onToolButtonClick(e:MouseEvent):void
		{
			var button:MovieClip = e.currentTarget as MovieClip;
			if (button == addToolButton)
			{
				_projectModel.currentTool = ToolType.ADD;
			}
			else if (button == modifyToolButton)
			{
				_projectModel.currentTool = ToolType.MODIFY;
			}
			else if (button == connectToolButton)
			{
				_projectModel.currentTool = ToolType.CONNECT;
			}
		}
		
		private function onToolButtonOver(e:MouseEvent):void
		{
			var button:MovieClip = e.currentTarget as MovieClip;
			button.gotoAndStop((button.currentFrame == 1) ? 2 : 4);
		}
		
		private function onToolButtonOut(e:MouseEvent):void
		{
			var button:MovieClip = e.currentTarget as MovieClip;
			button.gotoAndStop((button.currentFrame == 2) ? 1 : 3);
		}
	}

}