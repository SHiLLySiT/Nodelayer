package 
{
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObjectContainer;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import models.ProjectModel;
	import flash.net.navigateToURL;
	
	public class ApplicationMenuManager 
	{
		private var _projectModel:ProjectModel;
		
		public function ApplicationMenuManager() 
		{
			
		}
		
		public function initialize(target:DisplayObjectContainer):void
		{
			this._projectModel = ModelManager.getModel(ProjectModel) as ProjectModel;
			LogManager.logDebug(this, "MODEL:" + this._projectModel);
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
			
			var node100:NativeMenuItem = nodeSizeMenu.submenu.addItem(new NativeMenuItem("100%")); 
			node100.addEventListener(Event.SELECT, this.onNodeScaleChanged);
			
			var node75:NativeMenuItem = nodeSizeMenu.submenu.addItem(new NativeMenuItem("75%")); 
			node75.addEventListener(Event.SELECT, this.onNodeScaleChanged);
			
			var node50:NativeMenuItem = nodeSizeMenu.submenu.addItem(new NativeMenuItem("50%")); 
			node50.addEventListener(Event.SELECT, this.onNodeScaleChanged);
			
			var node25:NativeMenuItem = nodeSizeMenu.submenu.addItem(new NativeMenuItem("25%")); 
			node25.addEventListener(Event.SELECT, this.onNodeScaleChanged);
			// ----
			
			// ----------------------------------------- HELP
			var helpMenu:NativeMenuItem = target.stage.nativeWindow.menu.addItem(new NativeMenuItem("Help")); 
			helpMenu.submenu = new NativeMenu(); 
			
			var onlineDocumentationCommand:NativeMenuItem = helpMenu.submenu.addItem(new NativeMenuItem("Online Documentation")); 
			onlineDocumentationCommand.addEventListener(Event.SELECT, this.onOnlineDocumentation);
			
			var aboutCommand:NativeMenuItem = helpMenu.submenu.addItem(new NativeMenuItem("About")); 
			aboutCommand.addEventListener(Event.SELECT, this.onAbout);
		}
		
		private function onExportXML(e:Event):void
		{
			if (_projectModel.projectFilePath != null) {
				var file:File = new File();
				file.browseForSave("Export XML");
				file.addEventListener(Event.SELECT, this.onXMLLocationSelected);
			} else {
				// TODO: show notification popup
				LogManager.logError(this, "You must save the project before exporting!");
			}
		}
		
		private function onXMLLocationSelected(e:Event):void
		{
			var file:File = e.currentTarget as File;
			file.removeEventListener(Event.SELECT, this.onXMLLocationSelected);
			
			var data:String = _projectModel.exportXML();
			if (file.extension != "xml")
			{
				file.nativePath += ".xml";
			}
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(data);
			stream.close();	
			
			LogManager.logInfo(this, "Successfully export XML: " + file.name);
		}
		
		private function onExportJSON(e:Event):void
		{
			if (_projectModel.projectFilePath != null) {
				var file:File = new File();
				file.browseForSave("Export JSON");
				file.addEventListener(Event.SELECT, this.onJSONLocationSelected);
			} else {
				// TODO: show notification popup
				LogManager.logError(this, "You must save the project before exporting!");
			}
		}
		
		private function onJSONLocationSelected(e:Event):void
		{
			var file:File = e.currentTarget as File;
			file.removeEventListener(Event.SELECT, this.onJSONLocationSelected);
			
			var data:String = _projectModel.exportJSON();
			if (file.extension != "json")
			{
				file.nativePath += ".json";
			}
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(data);
			stream.close();	
			
			LogManager.logInfo(this, "Successfully exported JSON: " + file.name);
		}
		
		private function onNodeScaleChanged(e:Event):void
		{
			var menuItem:NativeMenuItem = e.currentTarget as NativeMenuItem;
			switch (menuItem.label) {
				case "100%": _projectModel.nodeScale = 1.0; break;
				case "75%": _projectModel.nodeScale = 0.75; break;
				case "50%": _projectModel.nodeScale = 0.50; break;
				case "25%": _projectModel.nodeScale = 0.25; break;
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
			var projectFile:File = new File(_projectModel.projectFilePath);
			_projectModel.backgroundImagePath = projectFile.getRelativePath(imagefile, true);
			//_projectModel.backgroundImagePath = file.nativePath;
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
			_projectModel.projectFilePath = null;
			_projectModel.backgroundImagePath = null;
			_projectModel.removeAllNodes();
		}
		
		private function onOpenProject(e:Event):void
		{
			// TODO: prompt user to save current project
			
			var file:File = new File();
			file.browseForOpen("Open Project", [ new FileFilter("Nodelayer Projects", "*.nlp") ]);
			file.addEventListener(Event.SELECT, this.onOpenProjectLocationSelected);
		}
		
		private function onOpenProjectLocationSelected(e:Event):void
		{
			var file:File = e.currentTarget as File;
			file.removeEventListener(Event.SELECT, this.onOpenProjectLocationSelected);
			
			_projectModel.projectFilePath = file.nativePath;
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			
			var data:String = stream.readUTFBytes(stream.bytesAvailable);
			_projectModel.newProject();
			_projectModel.loadProject(data);
			
			stream.close();	
			
			LogManager.logInfo(this, "Successfully loaded project: " + file.name);
		}
		
		private function onSaveProject(e:Event):void
		{
			var file:File = new File();
			file.browseForSave("Save Project");
			file.addEventListener(Event.SELECT, this.onSaveProjectLocationSelected);
		}
		
		private function onSaveProjectLocationSelected(e:Event):void
		{
			var file:File = e.currentTarget as File;
			file.removeEventListener(Event.SELECT, this.onSaveProjectLocationSelected);
			
			var data:String = _projectModel.saveProject();
			if (file.extension != "nlp")
			{
				file.nativePath += ".nlp";
			}
			
			_projectModel.projectFilePath = file.nativePath;
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(data);
			stream.close();	
			
			LogManager.logInfo(this, "Successfully saved project: " + file.name);
		}
		
		private function onQuit(e:Event):void
		{
			// TODO: prompt if not saved
			NativeApplication.nativeApplication.exit();
		}
	}

}