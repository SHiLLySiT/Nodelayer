package events 
{
	import flash.events.Event;
	public class BackgroundImageEvent extends Event
	{
		public static const CHANGED:String = "backgroundImageChanged";
		
		public function BackgroundImageEvent(type:String) 
		{ 
			super(type);
		} 
		
	}

}