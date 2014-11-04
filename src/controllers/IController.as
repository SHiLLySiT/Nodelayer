package controllers 
{
	import views.View;
	
	public interface IController 
	{
		function get view():View;
		function get id():String;
		function initialize(id:String, view:View, data:Object = null):void;
		function deinitialize():void;
	}
	
}