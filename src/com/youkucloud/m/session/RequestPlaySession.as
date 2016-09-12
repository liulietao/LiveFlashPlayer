package com.youkucloud.m.session
{
	import com.youkucloud.evt.SessionEvt;
	import com.youkucloud.util.JSONUtil;
	import com.youkucloud.util.LogUtil;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.net.URLVariables;

	public class RequestPlaySession extends BaseSession
	{
		private var  _log:LogUtil = new LogUtil("RequestPlaySession");
		
		public function RequestPlaySession(url:String, token:String)
		{
			super();
			
			super.url = url;
			super.token = token;
		}
		
		override protected function createURLVariables():URLVariables
		{
			var variables:URLVariables = new URLVariables(); 
			variables.playtk = token;
			variables.proto   = "rtmp";
			
			return variables;
		}
		
		override protected function httpRequestComplete(event:Event):void
		{
			_log.debug("httpRequestComplete, ", event.target.data );     
			
			var data:* = JSONUtil.decode(event.target.data);
			
			var e:SessionEvt = new SessionEvt(SessionEvt.REQUEST_PLAY_COMPLETE);
			e.data = data;
			dispatchEvent(e);
			
			super.httpRequestComplete(event);
		}
		
		override protected function httpRequestError(error:ErrorEvent):void
		{
			var e:SessionEvt = new SessionEvt(SessionEvt.REQUEST_PLAY_ERROR);
			e.data = error;
			dispatchEvent(e);
		
			super.httpRequestError(error);
		}
	}
}