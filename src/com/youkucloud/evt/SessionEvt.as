package com.youkucloud.evt
{
	import flash.events.Event;
	
	public class SessionEvt extends Event
	{
		public static const SESSION_COMPLETE:String = "session.complete";
		
		public static const REQUEST_PUBLISH_COMPLETE:String = "request.publish.complete";
		public static const REQUEST_PUBLISH_ERROR:String    = "request.publish.error";
		
		public static const REQUEST_PLAY_COMPLETE:String    = "request.play.complete";
		public static const REQUEST_PLAY_ERROR:String		= "request.play.error";
		
		public static const REQUEST_KEEP_ALIVE_COMPLETE:String  = "request.keepalive.complete";
		public static const REQUEST_KEEP_ALIVE_ERROR:String		= "request.keepalive.error";
		
		private var _data:*;
		
		public function SessionEvt(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

		public function get data():*
		{
			return _data;
		}

		public function set data(value:*):void
		{
			_data = value;
		}

	}
}