package com.youkucloud.m
{
	import com.adobe.images.PNGEncoder;
	import com.hurlant.util.Base64;
	import com.youkucloud.consts.ConnectionStatus;
	import com.youkucloud.consts.DebugConst;
	import com.youkucloud.consts.MediaType;
	import com.youkucloud.consts.PlayerState;
	import com.youkucloud.consts.StreamStatus;
	import com.youkucloud.evt.EventBus;
	import com.youkucloud.evt.MediaEvt;
	import com.youkucloud.evt.PlayerStateEvt;
	import com.youkucloud.evt.SessionEvt;
	import com.youkucloud.evt.debug.DebugEvt;
	import com.youkucloud.evt.js.JSEvt;
	import com.youkucloud.evt.view.BulletEvt;
	import com.youkucloud.m.js.JSAPI;
	import com.youkucloud.m.media.BaseMedia;
	import com.youkucloud.m.media.P2PLiveMedia;
	import com.youkucloud.m.media.RtmpLiveMedia;
	import com.youkucloud.m.session.SessionMaganer;
	import com.youkucloud.m.vo.AdVO;
	import com.youkucloud.m.vo.ErrorHintVO;
	import com.youkucloud.m.vo.FeedbackVO;
	import com.youkucloud.m.vo.LogoVO;
	import com.youkucloud.m.vo.MediaVO;
	import com.youkucloud.m.vo.NodeVO;
	import com.youkucloud.m.vo.QrcodeVO;
	import com.youkucloud.m.vo.SessionVO;
	import com.youkucloud.m.vo.SubtitleVO;
	import com.youkucloud.m.vo.UserVO;
	import com.youkucloud.m.vo.VideoAdVO;
	import com.youkucloud.util.Config;
	import com.youkucloud.util.LogUtil;
	import com.youkucloud.util.MultifunctionalLoader;
	import com.youkucloud.util.StageReference;
	import com.youkucloud.util.Strings;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;

	public class Model
	{
		public var playerconfig:Object; // point to Config._config
		public var js:JSAPI = JSAPI.getInstance();
		
		public var media:BaseMedia;
		private var _mediaMap:Object = {};		
		private var _mediaVO:MediaVO = new MediaVO();
		private var _logoVO:LogoVO = new LogoVO();
		private var _errorHintVO:ErrorHintVO = new ErrorHintVO();
		private var _adVO:AdVO = new AdVO();
		private var _videoadVO:VideoAdVO = new VideoAdVO();
		private var _qrcodeVO:QrcodeVO = new QrcodeVO();
		private var _nodeVO:NodeVO = new NodeVO();
		private var _feedbackVO:FeedbackVO = new FeedbackVO();
		private var _subtitleVO:SubtitleVO = new SubtitleVO();
		private var _userVO:UserVO = new UserVO();
		private var _sessionVO:SessionVO = new SessionVO;
		private var _sessionManager:SessionMaganer = null;
		/** 播放器皮肤 **/
		private var _skin:MovieClip;
		private var _state:String = PlayerState.IDLE;
		private var _isMute:Boolean = false;
		
		protected var _srtTimeArray:Array;
		protected var _srtTimeArrayLength:int = 0;
		protected var _defaultLangTextArray:Array;	
		protected var _secondLangTextArray:Array;
		
		private var log:LogUtil = new LogUtil("Model");
		
		public function Model()
		{
			setMedia();
		}

		private function setMedia():void
		{
			_mediaMap[MediaType.RTMP_LIVE] = new RtmpLiveMedia(MediaType.RTMP_LIVE);
			_mediaMap[MediaType.P2PLIVE] = new P2PLiveMedia(MediaType.P2PLIVE);
		}
		
		private function addListeners():void
		{
			media.addEventListener(MediaEvt.MEDIA_INFO, mediaInfoHandler);
			media.addEventListener(MediaEvt.MEDIA_STATE, mediaStateHandler);
			js.addEventListener(JSEvt.SCREENSHOT, screenshotHandler);
			js.addEventListener(JSEvt.QRCODE, qrcodeHandler);
			js.addEventListener(JSEvt.PAUSE, pauseHandler);
			js.addEventListener(JSEvt.PLAY, playHandler);
			js.addEventListener(JSEvt.BULLETCURTAIN, bulletcurtainHandler);
		}
		
		private function mediaInfoHandler(evt:MediaEvt):void
		{
			developermode && (log.info('Model---start', evt.data + '-->状态:->' + state));
			switch(evt.data)
			{
				case StreamStatus.START_LOAD_MEDIA:
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.LOAD_MEDIA));	
					break;
				case StreamStatus.LOAD_MEDIA_IOERROR:
					sendErrorAndDebugMsg(DebugConst.LOAD_MEDIA_IOERROR + ":" + mediaVO.url);
					break;
				case StreamStatus.STREAM_NOT_FOUND:
					sendErrorAndDebugMsg(DebugConst.STREAM_NOT_FOUND + ":" + mediaVO.url);
					break;
				case StreamStatus.HANDLE_ENCRYPTED_MEDIA_ERROR:
					sendErrorAndDebugMsg(DebugConst.HANDLE_ENCRYPTED_MEDIA_ERROR + ":" + mediaVO.url);
					break;
				case StreamStatus.BUFFER_EMPTY: 	//缓冲
				case StreamStatus.PLAY_START:
					if(state == PlayerState.PAUSED)
					{
						EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_LOADING));
					}
					else
					{
						state = PlayerState.BUFFERING;
					}
					break;
				case StreamStatus.PUBLISH_START:
				case StreamStatus.BUFFER_FULL:     //缓冲满
					if(state == PlayerState.PAUSED)
					{
						EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_BUFFER_FULL));
					}
					else
					{
						state = PlayerState.PLAYING;
					}
					break;
				case StreamStatus.PLAY_COMPLETE:
					state = PlayerState.IDLE; 
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_COMPLETE));	
					break;
				case StreamStatus.PLAY_NEARLY_COMPLETE:
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_NEARLY_COMPLETE));
					break;
				case StreamStatus.NOT_NEARLY_COMPLETE:
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.NOT_NEARLY_COMPLETE));
					break;
				case StreamStatus.RTMPSERVER_CONNECTION_SUCCESS:
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.LOAD_LIVE_MEDIA));
					break;				
				//handle connection
				case ConnectionStatus.CLOSED:
					sendErrorAndDebugMsg(DebugConst.CONNECTION_CLOSED + ":" + mediaVO.url);
					startSession();
					break;
				case ConnectionStatus.REJECTED:
					sendErrorAndDebugMsg(DebugConst.CONNECTION_REJECTED + ":" + mediaVO.url);
					startSession();
					break;
				case ConnectionStatus.SECURITY_ERROR:
					sendErrorAndDebugMsg(DebugConst.CONNECTION_SECURITY_ERROR + ":" + mediaVO.url);
					startSession();
					break;
				case ConnectionStatus.FAILED:
					sendErrorAndDebugMsg(DebugConst.CONNECTION_FAILED + ":" + mediaVO.url);
					startSession();
					break;
				case StreamStatus.FPVERSION_TOO_LOW:
					js.fpVersionTooLow();
				default:
					break;
			}
		}
		
		/** 派发错误事件和调试信息事件 **/
		private function sendErrorAndDebugMsg(debugMsg:String):void
		{
			EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_ERROR));
			EventBus.getInstance().dispatchEvent(new DebugEvt(DebugEvt.DEBUG, debugMsg));
		}
		
		/** 流状态发生变化 **/
		private function mediaStateHandler(evt:MediaEvt):void
		{
			state = evt.data;
		}
		
		/** 截图处理 **/
		private function screenshotHandler(evt:JSEvt):void
		{
			media.pause();
			var bitmapData:BitmapData;
			var screenshotByteArray:ByteArray;
			try
			{
				bitmapData = new BitmapData(evt.data.width, evt.data.height ,true, 0);
				bitmapData.draw(media.display);
				
				screenshotByteArray = PNGEncoder.encode(bitmapData);
				var imgstr:String = "data:image/png;base64," + (Base64.encodeByteArray(screenshotByteArray));
				js.showScreenshot(imgstr);
			}
			catch(err:Error)
			{
				developermode && (log.error("Model", "截图出错",  err.toString()));
				
				if(bitmapData != null)
				{
					bitmapData.dispose(); //释放内存
					bitmapData = null;
				}
				
				if(screenshotByteArray != null)
				{
					screenshotByteArray.clear(); //释放内存
					screenshotByteArray = null;
				}
				
				media.play();
			}
		}
		
		private function qrcodeHandler(evt:JSEvt):void
		{
			EventBus.getInstance().dispatchEvent(evt);
		}
		
		private function pauseHandler(evt:JSEvt):void
		{
			media.pause();
		}
		
		private function playHandler(evt:JSEvt):void
		{
			media.play();
		}
		
		private function bulletcurtainHandler(evt:JSEvt):void
		{
			var msg:String = evt.data.msg;
			if(media.isLive)
			{
				if(!media.isConnected)
				{
					ExternalInterface.call('alert', '服务器未连接');
					return;
				}
				
				media.sendChatMsg(_userVO.name, msg);
			}			
			
			evt.data.msg = '我说：' + msg;
			EventBus.getInstance().dispatchEvent(new BulletEvt(BulletEvt.CHAT_MSG_INCOMING, evt.data));
		}
		
		/**
		 * 根据媒体类型 激活相应的媒体模块 
		 * @param mediaType 媒体类型
		 * 
		 */		
		public function setActiveMedia():void
		{
			if(!hasMedia(_mediaVO.type))
				_mediaVO.type = MediaType.RTMP_LIVE;
			
			//加载字幕
			if(_subtitleVO.url)
			{
				var loader:MultifunctionalLoader = new MultifunctionalLoader(false);
				loader.registerFunctions(loadSrtComplete, loadSrtError);
				loader.load(_subtitleVO.url);
			}
			
			media = _mediaMap[_mediaVO.type];	
			media.vol = volume;
			addListeners();			
			media.init(_mediaVO, _sessionVO);
//			//程序启动后，自动进行RTMP/RTMFP视频推流或者播放流
//			media.connectToMediaServer(_userVO);
			
			//获取上传地址或者播放地址 
			startSession();
		}
		
		/**
		 * 从WEB获取推流地址或播流地址 
		 */
		private function startSession():void
		{
			if(!_sessionManager)
			{
				_sessionManager = new SessionMaganer;
				_sessionManager.init(_sessionVO);
				_sessionManager.addEventListener(SessionEvt.SESSION_COMPLETE, onSessionManagerEventHandler);
				_sessionManager.start(_userVO);
			}
			else
			{
				_sessionManager.callStartLater();
			}
		}
		
		private function onSessionManagerEventHandler(e:Event):void
		{
			//RTMP/RTMFP视频推流或者播放流
			media.connectToMediaServer(_userVO);
		}
		
		protected function loadSrtComplete(data:String):void
		{
			var srtTimeArr:Array = [];
			var srtTextArr:Array = [];
			
			var arr:Array = data.split('\r\n');
			var len:int = arr.length;
			for(var i:int = 0; i < len; i++)
			{
				if(int(arr[i]) || !arr[i]) //过滤掉字幕中的数字序列和空字符串
				{
					continue;
				}
				
				if(arr[i].indexOf('-->') != -1)
				{
					var temp:Array = arr[i].split('-->');
					srtTimeArr.push(Strings.string2Number(temp[0]), Strings.string2Number(temp[1]));
				}
				else
				{
					srtTextArr.push(arr[i]);
				}
			}
			
			if(_subtitleVO.isBilingual)
			{
				_srtTimeArray = [];
				_defaultLangTextArray = [];
				_secondLangTextArray  =[];
				
				var timeArrayLen:int = srtTimeArr.length;
				for(var j:int = 0; j <= timeArrayLen-4; j+=4)
				{
					_srtTimeArray.push(srtTimeArr[j], srtTimeArr[j+1]);
				}
				
				var textArrayLen:int = srtTextArr.length;
				for(var k:int = 0; k < textArrayLen; k++)
				{
					(k % 2 == 0) ? _defaultLangTextArray.push(srtTextArr[k]) : _secondLangTextArray.push(srtTextArr[k]); 
				}
				
				//释放内存
				srtTextArr = [];
				srtTextArr = [];
			}
			else
			{
				_srtTimeArray = srtTimeArr;
				_defaultLangTextArray = srtTextArr;
			}
			
			_srtTimeArrayLength = _srtTimeArray.length;
		}
		
		private function loadSrtError(errorMsg:String):void
		{
			developermode && log.error('Model', '加载字体出错', errorMsg);
		}
		
		private function hasMedia(mediaType:String):Boolean
		{
			return (_mediaMap[mediaType] is BaseMedia);
		}
		
		public function get mediaVO():MediaVO
		{
			return _mediaVO;
		}
		
		public function get logoVO():LogoVO
		{
			return _logoVO;
		}
		
		public function get errorHintVO():ErrorHintVO
		{
			return _errorHintVO;
		}	
		
		public function set skin(mc:MovieClip):void
		{
			_skin = mc;
		}
		
		public function get skin():MovieClip
		{
			return _skin;
		}
		
		public function get state():String
		{
			return _state;
		}
		
		public function get adVO():AdVO
		{
			return _adVO;
		}
		
		public function set volume(vol:int):void
		{
			if(playerconfig.volume != vol)
			{
				playerconfig.volume = vol;
				Config.saveCookie("volume", vol);
			}
		}
		
		public function get volume():int
		{
			return playerconfig.volume;
		}
		
		public function set state(value:String):void
		{
			if(_state != value)
			{
				_state = value;
				EventBus.getInstance().dispatchEvent(new PlayerStateEvt(PlayerStateEvt.PLAYER_STATE_CHANGE));	
			}		
		}		
		
		public function get videoadVO():VideoAdVO
		{
			return _videoadVO;
		}
		
		public function set videoadVO(value:VideoAdVO):void
		{
			_videoadVO = value;
		}
		
		/**
		 * 是否开启开发者模式 
		 * @return 
		 * 
		 */		
		public function get developermode():Boolean
		{
			return playerconfig.developermode;
		}
		
		/**
		 * 版本号 
		 * @return 
		 * 
		 */		
		public function get version():String
		{
			return playerconfig.version;
		}
		
		
		/**
		 * 在normal screen的情况下，计时器时间到后是否自动隐藏controlbar 
		 * @return 
		 * 
		 */		
		public function get autohide():Boolean
		{
			if(int(playerconfig.autohide))
				return true;
			else
				return	false;
		}
		
		/**
		 * 是否全屏 
		 * @return 
		 * 
		 */		
		public function get isFullScreen():Boolean
		{
			return StageReference.stage.displayState == StageDisplayState.FULL_SCREEN;
		}
		
		/**
		 * 视频是否播放完 
		 * @return 
		 * 
		 */		
		public function get isMediaComplete():Boolean
		{
			return media.isComplete;
		}
		
		/**
		 * 视频是否处在静音状态 
		 * @return 
		 * 
		 */		
		public function get isMute():Boolean
		{
			return _isMute;
		}
		
		public function set isMute(value:Boolean):void
		{
			_isMute = value;
			EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_MUTE));
		}
		
		public function get qrcodeVO():QrcodeVO
		{
			return _qrcodeVO;
		}
		
		public function get nodeVO():NodeVO
		{
			return _nodeVO;
		}
		
		public function get feedbackVO():FeedbackVO
		{
			return _feedbackVO;
		}
		
		public function get subtitleVO():SubtitleVO
		{
			return _subtitleVO;
		}
		
		/**
		 * srt字幕时间数组 
		 * @return 
		 * 
		 */		
		public function get srtTimeArray():Array
		{
			return _srtTimeArray;
		}
		
		/**
		 * 将srt字幕时间数组的长度缓存，避免重复遍历数组  
		 * @return 字幕时间数组的长度 
		 * 
		 */		
		public function get srtTimeArrayLength():int
		{
			return _srtTimeArrayLength;
		}
		
		/**
		 * 存储默认字幕文字信息的数组 
		 * @return 
		 * 
		 */		
		public function get defaultLangTextArray():Array
		{
			return _defaultLangTextArray;
		}
		
		/**
		 * 双语字幕时存储第二字幕文字信息的数组 
		 * @return 
		 * 
		 */		
		public function get secondLangTextArray():Array
		{
			return _secondLangTextArray;
		}
		
		public function get userVO():UserVO
		{
			return _userVO;
		}

		public function get sessionVO():SessionVO
		{
			return _sessionVO;
		}

		public function set sessionVO(value:SessionVO):void
		{
			_sessionVO = value;
		}
	}
}