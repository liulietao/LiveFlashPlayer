package com.youkucloud.m.session
{
	import com.youkucloud.consts.UserRole;
	import com.youkucloud.consts.session.RequestPublishReturnCode;
	import com.youkucloud.evt.EventBus;
	import com.youkucloud.evt.MediaEvt;
	import com.youkucloud.evt.SessionEvt;
	import com.youkucloud.m.vo.SessionVO;
	import com.youkucloud.m.vo.UserVO;
	import com.youkucloud.util.LogUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class SessionMaganer extends EventDispatcher
	{
		private var  _log:LogUtil = new LogUtil("SessionMaganer");
		
		private var requestPublish:RequestPublishSession = null;
		private var requestPlay:RequestPlaySession = null;
		private var keepalive:KeepAliveSession = null;
		
		private var _sessionVO:SessionVO;
		private var _userVO:UserVO;
		
		private var _timmer:Timer = null;
		
		public function SessionMaganer()
		{
		}
		
		public function init(vo:SessionVO):void
		{
			this._sessionVO = vo;
			
			requestPublish = new RequestPublishSession(vo.requestPublishURL, vo.schedtk);
			requestPublish.addEventListener(SessionEvt.REQUEST_PUBLISH_COMPLETE, eventHandler);
			requestPublish.addEventListener(SessionEvt.REQUEST_PUBLISH_ERROR, eventHandler);
			
			requestPlay = new RequestPlaySession(vo.requestPlayURL, vo.playtk);
			requestPlay.addEventListener(SessionEvt.REQUEST_PLAY_COMPLETE, eventHandler);
			requestPlay.addEventListener(SessionEvt.REQUEST_PLAY_ERROR, eventHandler);
		}
		
		public function start(userVO:UserVO):void
		{
			_userVO = userVO;
			
			if(_userVO.role == UserRole.PUBLISHER)
			{
				requestPublish.createSession();
			}
			else
			{
				requestPlay.createSession();
			}
		}
		
		public function callStartLater():void
		{
			if(_timmer)
			{
				_timmer.removeEventListener(TimerEvent.TIMER, onCallStartLater);
				_timmer.stop();
			}
			
			_timmer = new Timer(1000, 1);
			_timmer.addEventListener(TimerEvent.TIMER, onCallStartLater);
			_timmer.start();
		}
		
		private function onCallStartLater(e:Event):void
		{
			_timmer.removeEventListener(TimerEvent.TIMER, onCallStartLater);
			_timmer.stop();
			
			if(_userVO.role == UserRole.PUBLISHER)
			{
				requestPublish.createSession();
			}
			else
			{
				requestPlay.createSession();
			}
		}
		
		private function eventHandler(e:SessionEvt):void
		{
			var data:* = e.data;
			
			switch(e.type)
			{
				case SessionEvt.REQUEST_PUBLISH_COMPLETE:
				{
					switch(data.e.code)
					{
						case 0:
						{
							sessionVO.publishURL = data.data.url;
							sessionVO.appURL = sessionVO.publishURL.substring(0, sessionVO.publishURL.lastIndexOf("/"));
							sessionVO.lvid   = sessionVO.publishURL.substring(sessionVO.publishURL.lastIndexOf("/") + 1);
							sessionVO.sstk   = data.data.sstk;
							
							dispatchStartSignal();
							
							startKeepAliveSession();
							break;
						}
						case RequestPublishReturnCode.SCHEDULE_TOKEN_NOT_EXIST:
							dispatchHint("schedtk不存在");
							break;
						case RequestPublishReturnCode.SCHEDULE_TOKEN_EXPIRED:
							dispatchHint("schedtk已过期");
							break;
						case RequestPublishReturnCode.LIVE_CUTDOWN:
							dispatchHint("直播流已经被屏蔽");
							break;
						case RequestPublishReturnCode.SCHEDULE_TOKEN_INCORRECT:
							dispatchHint("schedtk校验失败");
							break;
						default:
							_log.error("eventHandler, ", e.type, data);
							break;
					}
				}
					break;
				case SessionEvt.REQUEST_PLAY_COMPLETE:
				{
					if(data.e.code == 0)
					{
						sessionVO.playRTMPURL = data.data.url;
						sessionVO.appURL = sessionVO.playRTMPURL.substring(0, sessionVO.playRTMPURL.lastIndexOf("/"));
						sessionVO.lvid   = sessionVO.playRTMPURL.substring(sessionVO.playRTMPURL.lastIndexOf("/") + 1);
						sessionVO.sstk   = data.data.sstk;
						
						dispatchStartSignal();
						
						startKeepAliveSession();
					}
					else
					{
						_log.error("eventHandler, ", e.type, data);
					}
				}
					break;
				case SessionEvt.REQUEST_PUBLISH_ERROR:
				case SessionEvt.REQUEST_PLAY_ERROR:
				{
					callStartLater();
				}
					break;
			}
		}
		
		private function dispatchStartSignal():void
		{
			dispatchEvent(new SessionEvt(SessionEvt.SESSION_COMPLETE));
		}
		
		private function dispatchHint(status:String):void
		{
			EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.LIVE_STATUS, status));
		}
		
		private function startKeepAliveSession():void
		{		
			if(keepalive)
			{
				keepalive.removeEventListener(SessionEvt.REQUEST_KEEP_ALIVE_COMPLETE, eventHandler);
				keepalive.removeEventListener(SessionEvt.REQUEST_KEEP_ALIVE_ERROR, eventHandler);
				keepalive.release();
			}
			
			keepalive = new KeepAliveSession(sessionVO.keepaliveURL, sessionVO.sstk, sessionVO.lvid);
			keepalive.addEventListener(SessionEvt.REQUEST_KEEP_ALIVE_COMPLETE, eventHandler);
			keepalive.addEventListener(SessionEvt.REQUEST_KEEP_ALIVE_ERROR, eventHandler);
			
			keepalive.createSessionRegular();
		}

		private function get sessionVO():SessionVO
		{
			return _sessionVO;
		}

		private function set sessionVO(value:SessionVO):void
		{
			_sessionVO = value;
		}

	}
}