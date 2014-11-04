package  
{
	import models.IModel;
	
	public class ModelManager 
	{
		private static var _models:Vector.<IModel>;
		
		public static function initialize():void
		{
			_models = new Vector.<IModel>();
		}
		
		public static function addModel(model:IModel):void
		{
			model.initialize();
			_models.push(model);
		}
		
		public static function getModel(model:Class):IModel
		{
			for each(var m:IModel in _models)
			{
				if (m is model)
				{
					return m;
				}
			}
			return null;
		}
		
	}

}