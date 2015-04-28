package 
{
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObjectContainer;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import models.ProjectModel;
	import flash.net.navigateToURL;
	import types.ExportType;
	import views.AlertView;
	import views.ConfirmView;
	
	public class ApplicationMenuManager 
	{
		private var _projectModel:ProjectModel;
		private var _isControlPressed:Boolean;
		private var _target:DisplayObjectContainer;
		
		private var _lastExport:File;
		private var _lastExportType:String;
		private var _isQuitting:Boolean;
		
		private var _node100:NativeMenuItem;
		private var _node75:NativeMenuItem;
		private var _node50:NativeMenuItem;
		private var _node25:NativeMenuItem;
		
		public function ApplicationMenuManager() 
		{
			
		}
		
		public function initialize(target:DisplayObjectContainer):void
		{
			this._target = target;
			this._projectModel = ModelManager.getModel(ProjectModel) as ProjectModel;
			this._isControlPressed = false;
			this._isQuitting = false;
			
			target.stage.nativeWindow.addEventListener(Event.CLOSING, this.onNativeQuit);
			
			target.stage.nativeWindow.menu = new NativeMenu(); 
			
			// ----------------------------------------- FILE
			var fileMenu:NativeMenuItem = target.stage.nativeWindow.menu.addItem(new NativeMenuItem("File")); 
			fileMenu.submenu = new NativeMenu(); 
			
			var newCommand:NativeMenuItem = fileMenu.submenu.addItem(new NativeMenuItem("New")); 
			newCommand.addEventListener(Event.SELECT, this.onNew); 
			
			var openCommand:NativeMenuItem = fileMenu.submenu.addItem(new NativeMenuItem("Open Project")); 
			openCommand.addEventListener(Event.SELECT, this.onOpenProject);  
			
			var saveCommand:NativeMenuItem = fileMenu.submenu.addItem(new NativeMenuItem("Save Project")); 
			saveCommand.addEventListener(Event.SELECT, this.onSaveProject);
			
			// ---- EXPORT
			var exportAsMenu:NativeMenuItem = fileMenu.submenu.addItem(new NativeMenuItem("Export as ...")); 
			exportAsMenu.submenu = new NativeMenu();
			
			var exportXMLCommand:NativeMenuItem = exportAsMenu.submenu.addItem(new NativeMenuItem("XML")); 
			exportXMLCommand.addEventListener(Event.SELECT, this.onExportXML); 
			
			var exportJSONCommand:NativeMenuItem = exportAsMenu.submenu.addItem(new NativeMenuItem("JSON")); 
			exportJSONCommand.addEventListener(Event.SELECT, this.onExportJSON); 
			// ----
			
			var quitCommand:NativeMenuItem = fileMenu.submenu.addItem(new NativeMenuItem("Quit")); 
			quitCommand.addEventListener(Event.SELECT, this.onQuit);  
			
			// ----------------------------------------- EDIT
			var editMenu:NativeMenuItem = target.stage.nativeWindow.menu.addItem(new NativeMenuItem("Edit")); 
			editMenu.submenu = new NativeMenu(); 
			
			var loadImageCommand:NativeMenuItem = editMenu.submenu.addItem(new NativeMenuItem("Load Image")); 
			loadImageCommand.addEventListener(Event.SELECT, this.onLoadImage);
			
			// ---- NODE SCALE
			var nodeSizeMenu:NativeMenuItem = editMenu.submenu.addItem(new NativeMenuItem("Node Scale")); 
			nodeSizeMenu.submenu = new NativeMenu();
			
			this._node100 = nodeSizeMenu.submenu.addItem(new NativeMenuItem("100%")); 
			this._node100.addEventListener(Event.SELECT, this.onNodeScaleChanged);
			this._node100.checked = true;
			
			this._node75 = nodeSizeMenu.submenu.addItem(new NativeMenuItem("75%")); 
			this._node75.addEventListener(Event.SELECT, this.onNodeScaleChanged);
			
			this._node50 = nodeSizeMenu.submenu.addItem(new NativeMenuItem("50%")); 
			this._node50.addEventListener(Event.SELECT, this.onNodeScaleChanged);
			
			this._node25 = nodeSizeMenu.submenu.addItem(new NativeMenuItem("25%")); 
			this._node25.addEventListener(Event.SELECT, this.onNodeScaleChanged);
			// ----
			
			// ----------------------------------------- HELP
			var helpMenu:NativeMenuItem = target.stage.nativeWindow.menu.addItem(new NativeMenuItem("Help")); 
			helpMenu.submenu = new NativeMenu(); 
			
			var onlineDocumentationCommand:NativeMenuItem = helpMenu.submenu.addItem(new NativeMenuItem("Online Documentation")); 
			onlineDocumentationCommand.addEventListener(Event.SELECT, this.onOnlineDocumentation);
			
			var aboutCommand:NativeMenuItem = helpMenu.submenu.addItem(new NativeMenuItem("About")); 
			aboutCommand.addEventListener(Event.SELECT, this.onAbout);
			
			// ----------------------------------------------------------- KEYBOARD SHORTCUTS
			target.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			target.stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
		}
		
		private function newProjectConfirm():void
		{
			_projectModel.removeAllNodes();
			_projectModel.projectDirectory = null;
			_projectModel.backgroundImageFile = null;
			_projectModel.unsavedChanges = false;
			_projectModel.nodeScale = 1.0;
		}
		
		private function saveProject(directory:File):void
		{
			_projectModel.unsavedChanges = false;
			
			// copy image to project folder if it doesnt already exist
			if (_projectModel.backgroundImageFile != null
			&& _projectModel.backgroundImageFile.nativePath.indexOf(directory.nativePath) == -1) 
			{
				var file:File = new File(directory.nativePath + "/" + _projectModel.backgroundImageFile.name);
				_projectModel.backgroundImageFile.copyTo(file, true);
				_projectModel.backgroundImageFile = file;
			}
			
			this._projectModel.projectDirectory = directory;
			
			var projectFile:File = new File(directory.nativePath + "/" + directory.name + ".nlp");
			var data:String = _projectModel.saveProject(directory);
			
			var stream:FileStream = new FileStream();
			stream.open(projectFile, FileMode.WRITE);
			stream.writeUTFBytes(data);
			stream.close();	
			
			LogManager.logInfo(this, "Successfully saved project: " + directory.name);
		}
		
		private function openProjectConfirm():void
		{
			var directory:File = new File();
			directory.browseForDirectory("Open Project");
			directory.addEventListener(Event.SELECT, this.onOpenProjectLocationSelected);
		}
		
		private function exportProject(file:File, exportType:String):void 
		{
			var data:String = null;
			switch (exportType)
			{
				case ExportType.XML:
					data = _projectModel.exportXML();
					if (file.extension != "xml") file.nativePath += ".xml";
					break;
					
				case ExportType.JSON:
					data = _projectModel.exportJSON();
					if (file.extension != "json") file.nativePath += ".json";
					break;
			}
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(data);
			stream.close();	
			
			LogManager.logInfo(this, "Successfully exported project! (" + this._lastExportType + ")");
		}
		
		private function quit():void
		{
			if (!this._isQuitting) {
				if (_projectModel.unsavedChanges) {
					this._isQuitting = true
					var confirm:ConfirmView = ViewManager.addView("Confirm") as ConfirmView;
					confirm.setContent("Unsaved changes", "All your changes will be lost. Are you sure you want to quit?", NativeApplication.nativeApplication.exit, this.quitDecline);
				} else {
					NativeApplication.nativeApplication.exit();
				}
			}
		}
		
		private function quitDecline():void
		{
			this._isQuitting = false;
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.S:
					if (this._isControlPressed) {
						this.onSaveProject(null);
					}
					break;
					
				case Keyboard.E:
					if (this._isControlPressed && this._lastExport != null) {
						this.exportProject(this._lastExport, this._lastExportType);
					} else {
						LogManager.logInfo(this, "You must export the project manually first!");
						var alert:AlertView = ViewManager.addView("Alert") as AlertView;
						alert.setContent("Unable to re-export", "You must export the project manually first!");
					}
					break;
					
				case Keyboard.CONTROL:
					this._isControlPressed = true;
					break;
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.CONTROL:
					this._isControlPressed = false;
					break;
			}
		}
		
		private function onExportXML(e:Event):void
		{
			this._lastExportType = ExportType.XML;
			var file:File = new File();
			file.browseForSave("Export XML");
			file.addEventListener(Event.SELECT, this.onExportLocationSelected);
		}
		
		private function onExportJSON(e:Event):void
		{
			this._lastExportType = ExportType.JSON;
			var file:File = new File();
			file.browseForSave("Export JSON");
			file.addEventListener(Event.SELECT, this.onExportLocationSelected);
		}
		
		private function onExportLocationSelected(e:Event):void
		{
			var file:File = e.currentTarget as File;
			file.removeEventListener(Event.SELECT, this.onExportLocationSelected);
			
			this._lastExport = file;
			
			this.exportProject(file, this._lastExportType);
		}
		
		private function onNodeScaleChanged(e:Event):void
		{
			this._node100.checked = false;
			this._node75.checked = false;
			this._node50.checked = false;
			this._node25.checked = false;
			
			var menuItem:NativeMenuItem = e.currentTarget as NativeMenuItem;
			switch (menuItem.label) {
				case "100%": _projectModel.nodeScale = 1.0; this._node100.checked = true; break;
				case "75%": _projectModel.nodeScale = 0.75; this._node75.checked = true; break;
				case "50%": _projectModel.nodeScale = 0.50; this._node50.checked = true; break;
				case "25%": _projectModel.nodeScale = 0.25; this._node25.checked = true; break;
			}
		}
		
		private function onLoadImage(e:Event):void
		{
			var file:File = new File();
			file.browseForOpen("Choose Background Image", [ new FileFilter("Images", "*.jpg;*.gif;*.png") ]);
			file.addEventListener(Event.SELECT, this.onImageSelected);
		}
		
		private function onImageSelected(e:Event):void
		{
			var imagefile:File = e.currentTarget as File;
			_projectModel.backgroundImageFile = imagefile;
		}
		
		private function onOnlineDocumentation(e:Event):void
		{
			navigateToURL(new URLRequest("https://github.com/SHiLLySiT/Nodelayer/wiki"));
		}
		
		private function onAbout(e:Event):void
		{
			if (ViewManager.getViewById("About") == null)
			{
				// TODO: width/height of this isn't correct?
				var posX:Number = NativeApplication.nativeApplication.activeWindow.width * 0.5 - 100;
				var posY:Number = NativeApplication.nativeApplication.activeWindow.height * 0.5 - 100;
				ViewManager.addView("About");
			}
		}
		
		private function onNew(e:Event):void
		{
			if (this._projectModel.unsavedChanges)
			{
				var confirm:ConfirmView = ViewManager.addView("Confirm") as ConfirmView;
				confirm.setContent("Unsaved changes", "All your changes will be lost. Are you sure you want to create a new project?", this.newProjectConfirm);
			} 
			else 
			{
				this.newProjectConfirm();
			}
		}
		
		private function onOpenProject(e:Event):void
		{
			if (this._projectModel.unsavedChanges)
			{
				var confirm:ConfirmView = ViewManager.addView("Confirm") as ConfirmView;
				confirm.setContent("Unsaved changes", "All your changes will be lost. Are you sure you want to open a project?", this.openProjectConfirm);
			} 
			else 
			{
				this.openProjectConfirm();
			}
		}
		
		private function onOpenProjectLocationSelected(e:Event):void
		{
			_projectModel.unsavedChanges = false;
			
			var directory:File = e.currentTarget as File;
			directory.removeEventListener(Event.SELECT, this.onOpenProjectLocationSelected);
			
			var projectFile:File = new File(directory.nativePath + "/" + directory.name + ".nlp");
			
			if (!projectFile.exists)
			{
				LogManager.logError(this, "No .nlp file find in folder selected!");
				var alert:AlertView = ViewManager.addView("Alert") as AlertView;
				alert.setContent("No project file found", "There was no .nlp file found in the folder selected");
				return;
			}
			
			this._projectModel.projectDirectory = directory;
			
			var stream:FileStream = new FileStream();
			stream.open(projectFile, FileMode.READ);
			var data:String = stream.readUTFBytes(stream.bytesAvailable);
			_projectModel.newProject();
			_projectModel.loadProject(directory, data);
			stream.close();	
			
			_projectModel.unsavedChanges = false;
			
			LogManager.logInfo(this, "Successfully loaded project: " + directory.name);
		}
		
		private function onSaveProject(e:Event):void
		{
			if (this._projectModel.projectDirectory != null)
			{
				this.saveProject(this._projectModel.projectDirectory);
			} 
			else 
			{
				var directory:File = new File();
				directory.browseForDirectory("Save Project");
				directory.addEventListener(Event.SELECT, this.onSaveProjectLocationSelected);
			}
		}
		
		private function onSaveProjectLocationSelected(e:Event):void
		{
			var directory:File = e.currentTarget as File;
			directory.removeEventListener(Event.SELECT, this.onSaveProjectLocationSelected);
			
			this.saveProject(directory);
		}
		
		private function onNativeQuit(e:Event):void
		{
			e.preventDefault();
			this.quit();
		}
		
		private function onQuit(e:Event):void
		{
			this.quit();
		}
	}

}