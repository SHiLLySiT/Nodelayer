package controllers 
{
	import views.AboutView;
	import views.View;
	
	public class AboutController implements IController
	{
		private var _id:String;
		public function get id():String { return _id; }
		
		private var _view:AboutView;
		public function get view():View { return _view; }
		
		public function AboutController() 
		{
			
		}
		
		public function initialize(id:String, view:View, data:Object = null):void
		{
			_id = id;
			_view = view as AboutView;
			
			if (data != null)
			{
				if (data.hasOwnProperty("x")) _view.x = data.x;
				if (data.hasOwnProperty("y")) _view.y = data.y;
			}
		}
		
		public function deinitialize():void
		{
			_view = null;
		}
		
	}

}