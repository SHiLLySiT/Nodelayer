package 
{
	import controllers.IController;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import views.View;
	
	public class ViewManager 
	{		
		private static var _sceneContainer:DisplayObjectContainer;
		
		private static var _currentScene:DisplayObjectContainer;
		public static function get currentScene():DisplayObjectContainer { return _currentScene; }
		
		private static var _views:Vector.<View>;
		private static var _controllers:Vector.<IController>
		private static var _registeredViews:Dictionary;
		
		public static function initialize(container:DisplayObjectContainer):void
		{
			_sceneContainer = container;
			_registeredViews = new Dictionary();
			_views = new Vector.<View>();
			_controllers = new Vector.<IController>();
		}
		
		/**
		 * Registers a view and controller. This must be called before the view is added!
		 * @param	id
		 * @param	view
		 * @param	controller
		 */
		public static function registerView(id:String, view:Class, controller:Class):void
		{
			_registeredViews[id] = { view:view, controller:controller };
		}
		
		/**
		 * Loads a list of registered views. Example "View1", "View2", "View3" OR "View1", {id:"View2", data:{ someBool:true } }, "View3"
		 * @param	...args	 
		 */
		public static function loadScene(...args):void
		{
			for each(var arg:* in args)
			{
				if (arg is String)
				{
					addView(arg);
				}
				else if (arg is Object)
				{
					addView(arg.id, arg.data);
				}
				else
				{
					LogManager.logError(ViewManager, "Invalid data!");
				}
			}
		}
		
		/**
		 * Adds a view to the current scene. View must be registered first.
		 * @param	id
		 * @param	data
		 * @param	depth
		 */
		public static function addView(id:String, data:Object = null, depth:int = -1):void
		{
			if (_registeredViews[id] == null)
			{
				LogManager.logError(ViewManager, "No view named '" + id + "' registered!");
				return;
			}
			
			if (_currentScene == null) 
			{
				_currentScene = new Sprite();
				_sceneContainer.addChild(_currentScene);
			}
			
			var view:View = new _registeredViews[id].view(id);
			if (depth < 0)
			{
				_currentScene.addChild(view);
			}
			else
			{
				_currentScene.addChildAt(view, depth);
			}
			_views.push(view);
			
			var controller:IController = new _registeredViews[id].controller;
			controller.initialize(id, view, data);
			_controllers.push(controller);
		}
		
		/**
		 * Returns the view of the specified type. Returns null if nothing found.
		 * @param	view
		 * @return
		 */
		public static function getViewByType(type:Class):View
		{
			for each(var v:View in _views)
			{
				if (v is type)
				{
					return v;
				}
			}
			return null;
		}
		
		/**
		 * Returns the view of the specified id. Returns null if nothing found.
		 * @param	view
		 * @return
		 */
		public static function getViewById(id:String):View
		{
			for each(var v:View in _views)
			{
				if (v.id == id)
				{
					return v;
				}
			}
			return null;
		}
		
		/**
		 * Returns the view of the specified type. Returns null if nothing found.
		 * @param	controller
		 * @return
		 */
		public static function getControllerByType(type:Class):IController
		{
			for each(var c:IController in _controllers)
			{
				if (c is type)
				{
					return c;
				}
			}
			return null;
		}
		
		/**
		 * Returns the view of the specified id. Returns null if nothing found.
		 * @param	controller
		 * @return
		 */
		public static function getControllerById(id:String):IController
		{
			for each(var c:IController in _controllers)
			{
				if (c.id == id)
				{
					return c;
				}
			}
			return null;
		}
		
		/**
		 * Removes the view and associated controller of the specified type.
		 * @param	view
		 */
		public static function removeView(view:View):void
		{
			_currentScene.removeChild(view);
			for (var i:int = 0; i < _views.length; i++)
			{
				if (_views[i] == view)
				{
					_views.splice(i, 1);
					_controllers.splice(i, 1);
					return;
				}
			}
		}
	}

}