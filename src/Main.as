package 
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.InvokeEvent;
	import models.ProjectModel;
	import models.EditorModel;
	import util.ApplicationUtility;
	import ViewManager;
	import views.AboutView;
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
			
			// --------------------------- MODELS
			ModelManager.initialize();
			ModelManager.addModel(new ProjectModel());
			ModelManager.addModel(new EditorModel());
			
			// --------------------------- VIEWS
			ViewManager.initialize(this);
			ViewManager.registerView("Main", MainView);
			ViewManager.registerView("Toolbar", ToolbarView);
			ViewManager.registerView("Debug", DebugView);
			ViewManager.registerView("About", AboutView);
			
			// --------------------------- LOAD PROGRAM
			var applicationMenuManager:ApplicationMenuManager = new ApplicationMenuManager();
			applicationMenuManager.initialize(this);
			
			ViewManager.loadScene("Main", "Toolbar");
			LogManager.logDebug(this, "Nodelayer " + ApplicationUtility.getVersion() + " started!");
		}
	}
	
}