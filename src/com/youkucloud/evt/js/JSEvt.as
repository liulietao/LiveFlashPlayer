package com.youkucloud.evt.js
{
	import flash.events.Event;
	
	public class JSEvt extends Event
	{
		/**
		 * 截图 
		 */		
		public static const SCREENSHOT:String = "screenshot";
		
		/**
		 * 二维码 
		 */		
		public static const QRCODE:String = "qrcode";
		
		/**
		 * 暂停 
		 */		
		public static const PAUSE:String = "pause_js";
		
		/**
		 * 播放 
		 */		
		public static const PLAY:String = "play_js";
		
		/**
		 * 弹幕 
		 */		
		public static const BULLETCURTAIN:String = "bulletcurtain";
		
		public var data:*;
		
		public function JSEvt(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		override public function clone():Event
		{
			return new JSEvt(type, data, bubbles, cancelable);
		}
	}
}