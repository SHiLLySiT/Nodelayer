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
			var file:File = new File();
			file.browseForSave("Export XML");
			file.addEventListener(Event.SELECT, this.onXMLLocationSelected);
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
			var file:File = new File();
			file.browseForSave("Export JSON");
			file.addEventListener(Event.SELECT, this.onJSONLocationSelected);
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
			_projectModel.backgroundImageFile = null;
			_projectModel.removeAllNodes();
		}
		
		private function onOpenProject(e:Event):void
		{
			// TODO: prompt user to save current project
			
			var directory:File = new File();
			directory.browseForDirectory("Open Project");
			directory.addEventListener(Event.SELECT, this.onOpenProjectLocationSelected);
		}
		
		private function onOpenProjectLocationSelected(e:Event):void
		{
			var directory:File = e.currentTarget as File;
			directory.removeEventListener(Event.SELECT, this.onOpenProjectLocationSelected);
			
			var projectFile:File = new File(directory.nativePath + "/" + directory.name + ".nlp");
			
			var stream:FileStream = new FileStream();
			stream.open(projectFile, FileMode.READ);
			var data:String = stream.readUTFBytes(stream.bytesAvailable);
			_projectModel.newProject();
			_projectModel.loadProject(directory, data);
			stream.close();	
			
			LogManager.logInfo(this, "Successfully loaded project: " + directory.name);
		}
		
		private function onSaveProject(e:Event):void
		{
			var directory:File = new File();
			directory.browseForDirectory("Save Project");
			directory.addEventListener(Event.SELECT, this.onSaveProjectLocationSelected);
		}
		
		private function onSaveProjectLocationSelected(e:Event):void
		{
			var directory:File = e.currentTarget as File;
			directory.removeEventListener(Event.SELECT, this.onSaveProjectLocationSelected);
			
			// copy image to project folder if it doesnt already exist
			if (_projectModel.backgroundImageFile.nativePath.indexOf(directory.nativePath) == -1) 
			{
				var file:File = new File(directory.nativePath + "/" + _projectModel.backgroundImageFile.name);
				_projectModel.backgroundImageFile.copyTo(file, true);
				_projectModel.backgroundImageFile = file;
			}
			
			var projectFile:File = new File(directory.nativePath + "/" + directory.name + ".nlp");
			var data:String = _projectModel.saveProject(directory);
			
			var stream:FileStream = new FileStream();
			stream.open(projectFile, FileMode.WRITE);
			stream.writeUTFBytes(data);
			stream.close();	
			
			LogManager.logInfo(this, "Successfully saved project: " + directory.name);
		}
		
		private function onQuit(e:Event):void
		{
			// TODO: prompt if not saved
			NativeApplication.nativeApplication.exit();
		}
	}

}