package com.youkucloud.m.session
{
	import com.youkucloud.evt.SessionEvt;
	import com.youkucloud.util.JSONUtil;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLVariables;
	import flash.utils.Timer;

	public class KeepAliveSession extends BaseSession
	{
		private var _timer:Timer;
		
		private var _inteval:uint = 3000;
		
		public function KeepAliveSession(url:String, token:String, streamID:String)
		{
			super();
			
			super.url = url;
			super.token = token;
			super.streamID = streamID;
		}
		
		public function createSessionRegular():void
		{
			if(!_timer)
			{
				_timer = new Timer(_inteval);
				_timer.addEventListener(TimerEvent.TIMER, timerHandler);
			}
			_timer.start();
		}
		
		public function release():void
		{
			if(_timer)
			{
				_timer.removeEventListener(TimerEvent.TIMER, timerHandler);
				_timer.stop();
			}
		}
		
		private function timerHandler(e:Event):void
		{
			super.createSession();
		}
		
		override protected function createURLVariables():URLVariables
		{
			var variables:URLVariables = new URLVariables(); 
			variables.lvid = streamID;
			variables.sstk = token;
			
			return variables;
		}
		
		override protected function httpRequestComplete(event:Event):void
		{
			var data:* = JSONUtil.decode(event.target.data);
			
			var e:SessionEvt = new SessionEvt(SessionEvt.REQUEST_KEEP_ALIVE_COMPLETE);
			e.data = data;
			dispatchEvent(e);
			
			super.httpRequestComplete(event);
		}
		
		override protected function httpRequestError(error:ErrorEvent):void
		{
			var e:SessionEvt = new SessionEvt(SessionEvt.REQUEST_KEEP_ALIVE_ERROR);
			e.data = error;
			dispatchEvent(e);
			
			super.httpRequestError(error);
		}
	}
}