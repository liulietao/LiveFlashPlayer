package com.youkucloud.evt
{
	import flash.events.Event;
	
	/**
	 * 播放器状态事件类 
	 * 
	 */	
	public class PlayerStateEvt extends Event
	{
		public static const PLAYER_STATE_CHANGE:String = "player_state_change";
		
		public var state:String;
		
		public function PlayerStateEvt(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}