package controllers 
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import models.ProjectModel;
	import types.ToolType;
	import views.ToolbarView;
	import views.View;
	public class ToolbarController implements IController
	{
		private var _id:String;
		public function get id():String { return _id; }
		
		private var _view:ToolbarView;
		public function get view():View { return _view; }
		
		private var _projectModel:ProjectModel;
		
		public function ToolbarController() 
		{
			
		}
		
		public function initialize(id:String, view:View, data:Object = null):void
		{
			_id = id;
			
			_view = view as ToolbarView;
			_view.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			
			_projectModel = ModelManager.getModel(ProjectModel) as ProjectModel;
			
			if (data != null)
			{
				if (data.hasOwnProperty("x")) _view.x = data.x;
				if (data.hasOwnProperty("y")) _view.y = data.y;
			}
		}
		
		public function deinitialize():void
		{
			_view.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			_view = null;
			_projectModel = null;
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.NUMBER_1: 
					_projectModel.currentTool = ToolType.ADD;
					break;
				case Keyboard.NUMBER_2:
					_projectModel.currentTool = ToolType.MODIFY;
					break;
				case Keyboard.NUMBER_3:
					_projectModel.currentTool = ToolType.CONNECT;
					break;
			}
		}
	}

}