package com.youkucloud.evt.debug
{
	import flash.events.Event;
	
	public class DebugEvt extends Event
	{
		public static const DEBUG:String = "debug";
		
		public var info:String;
		
		public function DebugEvt(type:String, info:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.info = info;
		}
		
		public override function clone():Event
		{
			return new DebugEvt(type, info, bubbles, cancelable);
		}
	}
}