package  
{
	import events.LogManagerEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getQualifiedClassName;
	import org.flashdevelop.utils.TraceLevel;
	
	public class LogManager
	{
		private static var _logs:Vector.<String>;
		public static function get logs():Vector.<String> { return _logs; }
		
		private static var _target:DisplayObjectContainer;
		
		public function LogManager() 
		{
			
		}
		
		public static function initialize(target:DisplayObjectContainer):void
		{
			_logs = new Vector.<String>();
			_target = target;
		}
		
		public static function logInfo(source:*, message:String):void
		{
			addLog(TraceLevel.INFO + ":[INFO] " + getQualifiedClassName(source) + ": " + message);
		}
		
		public static function logDebug(source:*, message:String):void
		{
			addLog(TraceLevel.DEBUG + ":[DEBUG] " + getQualifiedClassName(source) + ": " + message);
		}
		
		public static function logWarning(source:*, message:String):void
		{
			addLog(TraceLevel.WARNING + ":[WARN] " + getQualifiedClassName(source) + ": " + message);
		}
		
		public static function logError(source:*, message:String):void
		{
			addLog(TraceLevel.ERROR + ":[ERROR] " + getQualifiedClassName(source) + ": " + message);
		}
		
		private static function addLog(str:String):void
		{
			_logs.push(str);
			trace(str);
			
			if (_target.stage.hasEventListener(LogManagerEvent.LOG_ADDED))
			{
				_target.stage.dispatchEvent(new LogManagerEvent(LogManagerEvent.LOG_ADDED, str));
			}
		}
	}

}