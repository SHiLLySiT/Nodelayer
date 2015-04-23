package 
{
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
		
		private static var _activeViews:Vector.<View>;
		private static var _registeredViews:Dictionary;
		
		public static function initialize(container:DisplayObjectContainer):void
		{
			_sceneContainer = container;
			_registeredViews = new Dictionary();
			_activeViews = new Vector.<View>();
		}
		
		/**
		 * Registers a view and controller. This must be called before the view is added!
		 * @param	id
		 * @param	view
		 * @param	controller
		 */
		public static function registerView(id:String, view:Class):void
		{
			_registeredViews[id] = view;
		}
		
		/**
		 * Loads a list of registered views.
		 * @param	...args	 
		 */
		public static function loadScene(...args):void
		{
			for each(var arg:* in args)
			{
				addView(arg);
			}
		}
		
		/**
		 * Adds a view to the current scene. View must be registered first.
		 * @param	id
		 * @param	data
		 * @param	depth
		 */
		public static function addView(id:String, depth:int = -1):View
		{
			if (_registeredViews[id] == null)
			{
				LogManager.logError(ViewManager, "No view named '" + id + "' registered!");
				return null;
			}
			
			if (_currentScene == null) 
			{
				_currentScene = new Sprite();
				_sceneContainer.addChild(_currentScene);
			}
			
			var view:View = new _registeredViews[id](id);
			if (depth < 0)
			{
				_currentScene.addChild(view);
			}
			else
			{
				_currentScene.addChildAt(view, depth);
			}
			_activeViews.push(view);
			
			return view;
		}
		
		/**
		 * Returns the view of the specified type. Returns null if nothing found.
		 * @param	view
		 * @return
		 */
		public static function getViewByType(type:Class):View
		{
			for each(var v:View in _activeViews)
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
			for each(var v:View in _activeViews)
			{
				if (v.id == id)
				{
					return v;
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
			for (var i:int = 0; i < _activeViews.length; i++)
			{
				if (_activeViews[i] == view)
				{
					_activeViews.splice(i, 1);
					return;
				}
			}
		}
	}

}