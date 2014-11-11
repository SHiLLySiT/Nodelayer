package util 
{
	import flash.desktop.NativeApplication;
	public class ApplicationUtility 
	{
		public static function getVersion():String
		{
			var xml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = xml.namespace();
			return xml.ns::versionNumber;
		}
		
	}

}