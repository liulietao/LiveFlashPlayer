package com.youkucloud.m.media
{
	import com.youkucloud.consts.UserRole;
	import com.youkucloud.evt.EventBus;
	import com.youkucloud.evt.ModuleEvt;
	import com.youkucloud.evt.view.ViewEvt;
	import com.youkucloud.m.vo.BaseVO;
	import com.youkucloud.m.vo.MediaVO;
	import com.youkucloud.m.vo.MsgVO;
	import com.youkucloud.m.vo.SessionVO;
	import com.youkucloud.m.vo.UserVO;
	import com.youkucloud.util.LogUtil;
	import com.youkucloud.util.Serialize;
	import com.youkucloud.util.VideoUtil;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.media.H264Level;
	import flash.media.H264Profile;
	import flash.media.H264VideoStreamSettings;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Security;
	import flash.system.SecurityPanel;

	/**
	 * 直播媒体基类 
	 * 
	 */	
	public class BaseLiveMedia extends BaseMedia
	{
		private var  log:LogUtil = new LogUtil("BaseLiveMedia");
		
		protected var _outgoingStream:NetStream;		
		protected var _incomingStream:NetStream;
		protected var _userVO:UserVO;
		protected var _camera:Camera;
		protected var _mic:Microphone;
		
		public function BaseLiveMedia(mediaType:String)
		{
			super(mediaType);
		}
		
		override public function init(mediaVO:MediaVO, sessionVO:SessionVO):void
		{
			super.init(mediaVO, sessionVO);
			
			_isLive = true;
			
			_nc = new NetConnection();
			_nc.client = this;
			_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_nc.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_nc.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			
//			EventBus.getInstance().dispatchEvent(new ViewEvt(ViewEvt.SHOW_LOGIN_COMPONENT));
		}
		
		override public function connectToMediaServer(vo:BaseVO=null):void
		{
			if(vo == null)
			{
				log.error('live', '不允许匿名登录');
				return;
			}
			
			_userVO = vo as UserVO;
		}
		
		protected function errorHandler(evt:Event):void
		{
			log.error('BaseLiveMedia', evt.toString());
		}
		
		/** 状态处理函数 **/
		protected function statusHandler(evt:NetStatusEvent):void
		{
			log.error("statusHandler", evt.toString());
		}
		
		protected function connectServerSuccess():void
		{
			_isConnected = true;
			super.getVideo(VideoUtil.getResolution(_mediaVO.videoQuality).width, VideoUtil.getResolution(_mediaVO.videoQuality).height);
			_display.addChild(_video);		
			EventBus.getInstance().dispatchEvent(new ViewEvt(ViewEvt.REMOVE_LOGIN_COMPONENT));
			
			super.dispatchLiveStatus('连接服务器成功');
		}
		
		override public function play():void
		{
			log.debug("play");
			_incomingStream.resume();
			
			if(_userVO.role == UserRole.PUBLISHER)
			{
				_video.attachCamera(_camera);
				_outgoingStream.attachCamera(_camera);
				_outgoingStream.attachAudio(_mic);
			}
			
			super.play();
		}
		
		override public function pause():void
		{
			log.debug("pause");
			_incomingStream.pause();
			
			if(_userVO.role == UserRole.PUBLISHER)
			{
				_video.attachCamera(null);
				_outgoingStream.attachCamera(null);
				_outgoingStream.attachAudio(null);
			}
			
			super.pause();
		}
		
		/**
		 * 设置视频的音量 
		 * @param volume 音量大小 0~100
		 * 
		 */		
		override public function setVolume(volume:int):void
		{
			if(_incomingStream != null && _incomingStream.soundTransform.volume != volume / 100)
			{
				_incomingStream.soundTransform = new SoundTransform(volume / 100);				
			}
		}
		
		/**
		 * 设置麦克风的音量
		 */
		override public function setMicVolume(volume:int):void
		{
			if(_userVO.role == UserRole.PUBLISHER)
			{
				_mic.gain = volume;
			}
		}
		
		protected function publishStream():void
		{		
			if (Camera.isSupported)
			{
				_camera = Camera.getCamera();
				if (!_camera) 
				{
					super.dispatchLiveStatus('没有安装摄像头，无法直播!!!')	
				}
				else if (_camera.muted)
				{
					Security.showSettings(SecurityPanel.PRIVACY);
					_camera.addEventListener(StatusEvent.STATUS, cameraStatusHandler);
				}
				else 
				{
					attachCameraAndPublish();
				}		
			}
			else 
			{
				log.info('P2PLiveMedia', "The Camera is not supported on this device.");
			}
			
			if(Microphone.isSupported)
			{
				_mic = Microphone.getMicrophone();
				
				if(!_mic)
				{
					super.dispatchLiveStatus('没有安装麦克风，无法直播!!!')
				}
				else if(_mic.muted)
				{
					Security.showSettings(SecurityPanel.PRIVACY);
					_mic.addEventListener(StatusEvent.STATUS, micStatusHandler);
				}
				else 
				{
					attachMicAndPublish();
				}	
			}
		}
		
		private function cameraStatusHandler(evt:StatusEvent):void
		{
			if (evt.code == "Camera.Unmuted") 
			{
				attachCameraAndPublish(); 
				_camera.removeEventListener(StatusEvent.STATUS, cameraStatusHandler);
			}
		}
		
		private function micStatusHandler(evt:StatusEvent):void
		{
			if (evt.code == "Microphone.Unmuted") 
			{
				attachMicAndPublish(); 
				_mic.removeEventListener(StatusEvent.STATUS, micStatusHandler);
			}
		}
		
		/** 连接到摄像头发布视频 **/
		protected function attachCameraAndPublish():void
		{
			log.debug("attachCameraAndPublish : " + _sessionVO.lvid + ", " 
				+ _video.width + "*" + _video.height + " " + 15 + "fps");
			
			_camera.setMode(_video.width, _video.height, 15, true);
			_camera.setQuality(VideoUtil.getBitrateThreshold(_video.width, _video.height), 90);
			_camera.setKeyFrameInterval(30);
			
			var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
			h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_3_1);
			_outgoingStream.videoStreamSettings = h264Settings;
			
			_video.attachCamera(_camera);
			_outgoingStream.attachCamera(_camera);
			_outgoingStream.publish(_sessionVO.lvid);
			
//			var metaData:Object = new Object();  
//			metaData.codec = _outgoingStream.videoStreamSettings.codec;  
//			metaData.profile =  h264Settings.profile;  
//			metaData.level = h264Settings.level;  
//			metaData.fps = _camera.fps;  
//			metaData.bandwith = _camera.bandwidth;  
//			metaData.height = _camera.height;  
//			metaData.width = _camera.width;  
//			metaData.keyFrameInterval =_camera.keyFrameInterval;   
//			_outgoingStream.send( "@setDataFrame", "onMetaData", metaData);
		}
		
		protected function attachMicAndPublish():void
		{
			log.debug("attachMicAndPublish : ", _sessionVO.lvid);
			
			_mic.rate  = 22;
			_mic.codec = SoundCodec.SPEEX;
			_mic.encodeQuality = 9;
			_mic.setUseEchoSuppression(true);
			_mic.setSilenceLevel(0, 2000);
			_mic.enableVAD = true;
			_outgoingStream.attachAudio(_mic);
			_outgoingStream.publish(_sessionVO.lvid);
		}
		
		/** 播放流 **/
		protected function playStream():void
		{			
			log.debug("playStream : ", _sessionVO.lvid);
			
			_incomingStream.play(_sessionVO.lvid);		
			
			_incomingStream.useJitterBuffer = true;
			
			_video.attachNetStream(_incomingStream);
		}
		
		/**
		 * 消息回调 
		 * @param data
		 * 
		 */		
		public function messageCallBack(data:*):void
		{			
			if(!data['moduleID'])
			{
				log.error('MainConnection', 'callback--没有模块');
				return;
			}			
			
			var msgVO:MsgVO = Serialize.serialize(data, new MsgVO());
			EventBus.getInstance().dispatchEvent(new ModuleEvt(ModuleEvt.INCOMING_MSG, msgVO.moduleID , msgVO));
		}
		
		public function close():void
		{
			
		}		
	}
}