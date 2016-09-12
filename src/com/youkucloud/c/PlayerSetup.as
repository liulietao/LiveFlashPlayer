package com.youkucloud.c
{
	import com.youkucloud.m.Model;
	import com.youkucloud.m.skin.BaseSkin;
	import com.youkucloud.m.skin.DefaultSkin;
	import com.youkucloud.util.Config;
	import com.youkucloud.util.LogUtil;
	import com.youkucloud.util.JSONUtil;
	import com.youkucloud.v.View;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class PlayerSetup extends EventDispatcher
	{
		private var  _log:LogUtil = new LogUtil("PlayerSetup");
		
		private var _taskQueue:TaskQueue;
		private var _m:Model;
		private var _v:View;
		
		public function PlayerSetup(m:Model, v:View)
		{
			super();
			
			this._m = m;
			this._v  = v;
		}
		
		public function setup():void
		{
			_taskQueue = new TaskQueue();
			_taskQueue.addEventListener(Event.COMPLETE, onTasksCompleteHandler);
			
			_taskQueue.queueTask(loadConfig, loadConfigComplete);
			_taskQueue.queueTask(loadSkin, loadSkinComplete);
			_taskQueue.queueTask(setupView);
			
			_taskQueue.runTasks();
		}
		
		private function loadConfig():void
		{
			var configger:Config = new Config();
			configger.addEventListener(Event.COMPLETE, _taskQueue.success);
			configger.loadConfig();
		}		
		
		/** 加载配置信息complete **/
		private function loadConfigComplete(evt:Event):void
		{
			_m.playerconfig = (evt.target as Config).config;
			
			//session
			_m.sessionVO.playtk  = _m.playerconfig.playtk;
			_m.sessionVO.schedtk = _m.playerconfig.schedtk;
			_m.sessionVO.requestPublishURL = decodeURIComponent(_m.playerconfig.requestpublishurl);
			_m.sessionVO.requestPlayURL    = decodeURIComponent(_m.playerconfig.requestplayurl);
			_m.sessionVO.keepaliveURL	   = decodeURIComponent(_m.playerconfig.keepaliveurl);
			
			//media
			_m.mediaVO.vid = _m.playerconfig.vid;
			_m.mediaVO.type = _m.playerconfig.type;
			_m.mediaVO.autostart = int(_m.playerconfig.autostart) ? true : false;
			_m.mediaVO.checkPolicyFile = int(_m.playerconfig.accesspx) ? true : false;
			_m.mediaVO.videoQuality = int(_m.playerconfig.videoquality);
			
			//
			if(_m.playerconfig.len != undefined)
				_m.mediaVO.len = int(_m.playerconfig.len);
			
			//qrcode
			_m.qrcodeVO.url = decodeURIComponent(_m.playerconfig.qrcodeurl);
			
			//feedback
			_m.feedbackVO.url = decodeURIComponent(_m.playerconfig.feedbackurl);
			
			//字幕地址
			if(_m.playerconfig.subtitleurl)
			{
				_m.subtitleVO.url = decodeURIComponent(_m.playerconfig.subtitleurl);
				_m.subtitleVO.isBilingual = (int(_m.playerconfig.bilingual) ? true : false);
			}
			
			if(_m.playerconfig.urls) //多段视频
			{
				_m.mediaVO.urlArray = (JSONUtil.decode(_m.playerconfig.urls)) as Array;
			}
			else
			{
				_m.mediaVO.url = _m.playerconfig.url;
			}
			
			//for encrypted video
			_m.mediaVO.omittedLength = _m.playerconfig.omittedLength;
			_m.mediaVO.seed = _m.playerconfig.seed;
			
			//videoad vo
			_m.videoadVO.enabled = int(_m.playerconfig.vads_enabled) ? true : false;
			//不使用默认的JSON包，因为在某些情况下，会出现ReferenceError
			_m.videoadVO.adsArray = (JSONUtil.decode(_m.playerconfig.videoads) as Array);			
			_m.videoadVO.btnurl = _m.playerconfig.learnmore;
			
			//ad
			_m.adVO.adArray =  (JSONUtil.decode(_m.playerconfig.ads) as Array);		
			
			//node
			_m.nodeVO.nodeArray = (JSONUtil.decode(_m.playerconfig.nodes) as Array);
			
			//logo
			_m.logoVO.url = _m.playerconfig.logo.url; //这里应该是logo的url
			_m.logoVO.buttonMode = _m.playerconfig.logo.buttonMode;
			_m.logoVO.margin = _m.playerconfig.logo.margin;
			_m.logoVO.link = _m.playerconfig.logo.link;
			
			//error hint
			if(_m.playerconfig.errorHint)
				_m.errorHintVO.url = _m.playerconfig.errorHint.url;		
			
			//groupname for p2p
			_m.userVO.groupName = _m.playerconfig.groupname;
			//user role and name
			_m.userVO.role = _m.playerconfig.userrole;
			_m.userVO.name = _m.playerconfig.username;
		}		
		
		/** 加载皮肤 **/
		private function loadSkin():void
		{
			var sparrowSkin:BaseSkin = new DefaultSkin();
			sparrowSkin.addEventListener(Event.COMPLETE, _taskQueue.success);
			sparrowSkin.load();
		}
		
		/** 加载皮肤complete **/
		private function loadSkinComplete(evt:Event):void
		{
			_m.skin = (evt.target as DefaultSkin).skin;
		}		
		
		private function setupView():void
		{
			try
			{
				_v.setup();				
			}
			catch(err:Error)
			{
				_m.developermode && (_log.error('PlayerSetup', 'setup view出错', err.toString()));
			}
			
			_taskQueue.success();
		}		
		
		/** 队列里所有任务都已完成 **/
		private function onTasksCompleteHandler(evt:Event):void
		{
			dispatchEvent(evt);
		}		
	}
}