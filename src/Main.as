package 
{
	import controllers.MainController;
	import controllers.DebugController;
	import controllers.ToolbarController;
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.InvokeEvent;
	import models.ProjectModel;
	import models.EditorModel;
	import ViewManager;
	import views.MainView;
	import views.DebugView;
	import views.ToolbarView;
	
	public class Main extends Sprite 
	{
		public function Main():void 
		{
			super();
			
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, this.onInvoke);
		}
		
		private function onInvoke(e:InvokeEvent):void
		{
			NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, this.onInvoke);
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			LogManager.initialize(this);
			
			// --------------------------- MODLES
			ModelManager.initialize();
			ModelManager.addModel(new ProjectModel());
			ModelManager.addModel(new EditorModel());
			
			// --------------------------- VIEWS
			ViewManager.initialize(this);
			ViewManager.registerView("Main", MainView, MainController);
			ViewManager.registerView("Toolbar", ToolbarView, ToolbarController);
			ViewManager.registerView("Debug", DebugView, DebugController);
			
			// --------------------------- LOAD PROGRAM
			ViewManager.loadScene("Main", { id:"Toolbar", data: { x:250, y:0 }} );
			LogManager.logDebug(this, "Nodelayer started!");
		}
	}
	
}