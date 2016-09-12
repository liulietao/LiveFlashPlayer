package com.youkucloud.m.media
{
	import com.youkucloud.consts.NumberConst;
	import com.youkucloud.consts.PlayerState;
	import com.youkucloud.consts.StreamStatus;
	import com.youkucloud.evt.EventBus;
	import com.youkucloud.evt.MediaEvt;
	import com.youkucloud.m.vo.BaseVO;
	import com.youkucloud.m.vo.MediaVO;
	import com.youkucloud.m.vo.SessionVO;
	import com.youkucloud.util.LogUtil;
	import com.youkucloud.util.MetadataUtil;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.clearInterval;
	
	public class BaseMedia extends EventDispatcher
	{
		private var  _log:LogUtil = new LogUtil("BaseMedia");
		
		protected var _display:Sprite;		
		protected var _mediaType:String;
		/** 流的当前位置 **/
		protected var _pos:Number;
		/** 视频时长 **/
		protected var _duration:Number = 0;
		protected var _mediaVO:MediaVO;
		protected var _sessionVO:SessionVO;
		protected var _nc:NetConnection;
		protected var _stream:NetStream;
		/** video对象的引用 **/
		protected var _video:Video;
		/** 视频缓存到本地的比例 **/
		protected var _bufferPercent:Number;
		/** 流播放头位置定时器 **/
		protected var _posInterval:uint;
		/** Object with keyframe times and positions. **/
		protected var _keyframes:Object;
		/** 根据seek时间获取到的关键帧的timestamp **/
		protected var _kfTime:Number=0;
		/** 根据seek时间获取到的关键帧的fileposition **/
		protected var _kfFilePos:Number=0;
		/** 是否mp4文件 **/
		protected var _ismp4:Boolean;
		/** 是否快要播放完 **/
		protected var _isNearlyComplete:Boolean =  false;
		/** 是否播放完标识，对于分段视频，指的是全部分段播放complete,或者最后一个分段播放complete **/
		protected var _isComplete:Boolean = false;
		protected var _volume:int = 70;
		/** 是否直播 **/
		protected var _isLive:Boolean = false;
		/** 是否连接到服务器 **/
		protected var _isConnected:Boolean = false;		
		
		public function BaseMedia(mediaType:String)
		{
			super();
			
			_mediaType = mediaType;
			_display = new Sprite();
		}
		
		public function init(mediaVO:MediaVO, sessionVO:SessionVO):void
		{
			_mediaVO = mediaVO;
			_sessionVO = sessionVO;
		}
		
		/**
		 * 构造Video对象，并使视频注册点与中心点重合
		 * @param w  video宽 
		 * @param h  video高
		 * 
		 */		
		protected function getVideo(w:int=320, h:int=240):void
		{
			_video = new Video();
			_video.width = w;
			_video.height = h;
			_video.smoothing = true;
			_video.x = -_video.width >> 1;
			_video.y = -_video.height >> 1;
		}
		
		/**
		 * 开始加载流并播放 
		 * 交给子类重写
		 */		
		public function startLoadAndPlay():void
		{
			
		}
		
		/**
		 * 视频metadata处理函数
		 * @param info
		 * 
		 */
		public function onMetaData(info:Object):void
		{
			if (info['seekpoints']) 
			{
				_ismp4 = true;
				_keyframes = convertSeekpoints(info['seekpoints']);
			}
			else
			{
				_ismp4 = false;
				_keyframes = info['keyframes'];
			}
			
			//格式工厂等软件，在转换mp4->flv的时候，可能不会生成flv需要的keyframes信息，所以这里做了提示
			!_ismp4 && !_keyframes && _log.error('BaseMedia', '此flv文件没有关键帧数据，将无法正确拖动');
			
			//mp4拖动后仍然会触发onMetaData,并且duration会发生变化，这里作判断，防止重复更改_duration的值
			(_duration==0) && (_duration = info.duration);
			
			dispatchMetaData({w:info.width, h:info.height});
		}
		
		protected function dispatchMetaData(obj:Object):void
		{
			EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_METADATA, obj));
		}
		
		/**
		 * 有些视频在播放结束后出调用此函数 
		 * @param info
		 * 
		 */		
		public function onLastSecond(info:Object):void
		{
			
		}
		
		protected function convertSeekpoints(dat:Object):Object 
		{
			var kfr:Object = {};
			kfr.times = [];
			kfr.filepositions = [];
			for (var j:String in dat)
			{
				kfr.times[j] = Number(dat[j]['time']);
				kfr.filepositions[j] = Number(dat[j]['offset']);
			}
			return kfr;
		}
		
		/**
		 * 获得离指定时间最近的关键帧的位置或者时间
		 * @param sec 指定的时间
		 * @param tme true获取时间，false获取位置
		 * @return 
		 * 
		 */		
		protected function getOffset(sec:Number, tme:Boolean=false):Number 
		{
			return MetadataUtil.getOffset(_keyframes, sec, tme);
		}
		
		public function get display():Sprite
		{
			return _display;
		}
		
		public function play():void
		{
			_isComplete && (_isComplete = false);
			dispatchMediaStateEvt(PlayerState.PLAYING);
		}
		
		public function pause():void
		{
			dispatchMediaStateEvt(PlayerState.PAUSED);
		}
		
		/**
		 * mouse down timeslider 准备拖动 
		 * 
		 */		
		public function mouseDownToSeek():void
		{
			destroyPosTimer();
		}
		
		/**
		 * 拖动视频 
		 * @param sec 拖动的秒数
		 * 
		 */		
		public function seek(sec:Number):void
		{
			if(_stream)
			{
				_stream.seek(sec);
			}
		}
		
		/**
		 * 设置视频的音量 
		 * @param volume 音量大小 0~100
		 * 
		 */		
		public function setVolume(volume:int):void
		{
			if(_stream != null && _stream.soundTransform.volume != volume / 100)
			{
				_stream.soundTransform = new SoundTransform(volume / 100);				
			}
		}
		/**
		 * 设置麦克风的音量
		 */
		public function setMicVolume(volume:int):void
		{
			
		}
		
		/**
		 * 静音或者取消静音 
		 * @param bool
		 * @param volume 取消静音时，恢复的音量值
		 * 
		 */		
		public function mute(bool:Boolean, volume:int):void
		{
			bool ? setVolume(0) : setVolume(volume);
		}
		
		protected function dispatchEvt(type:String):void
		{
			dispatchEvent(new MediaEvt(MediaEvt.MEDIA_INFO, type));
		}
		
		protected function dispatchMediaStateEvt(state:String):void
		{
			dispatchEvent(new MediaEvt(MediaEvt.MEDIA_STATE, state));
		}
		
		protected function destroyPosTimer():void
		{
			if(_posInterval)
			{
				clearInterval(_posInterval);
				_posInterval = undefined;	
			}
		}
		
		/**
		 * 流状态处理函数，交给子类重写 
		 * @param evt
		 * 
		 */		
		protected function netStatusHandler(evt:NetStatusEvent):void
		{
			
		}
		
		/**
		 * 加载视频IOError, 由子类继承调用 
		 * @param evt
		 * 
		 */		
		protected function ioErrorHandler(evt:IOErrorEvent=null):void
		{
			dispatchEvt(StreamStatus.LOAD_MEDIA_IOERROR);
		}
		
		/**
		 * 检查视频是否快要播放结束 
		 * @param totalDuration 视频总时长
		 * @param currentPos 当前位置
		 * @param checkAfterSeeking 是否拖动后验证，默认false, 即在播放进行中验证
		 * 
		 */		
		protected function checkIsNearlyComplete(totalDuration:Number, currentPos:Number, checkAfterSeeking:Boolean=false):void
		{		
			if(!checkAfterSeeking)
			{
				if(!_isNearlyComplete && (totalDuration - currentPos <= NumberConst.NEARLY_COMPLETE))
				{
					_isNearlyComplete = true;
					dispatchEvt(StreamStatus.PLAY_NEARLY_COMPLETE);
					return;
				}
			}
			else
			{
				if(_isNearlyComplete && (totalDuration - currentPos > NumberConst.NEARLY_COMPLETE))
				{
					_isNearlyComplete = false;
					dispatchEvt(StreamStatus.NOT_NEARLY_COMPLETE);
				}
			}
		}
		
		/**
		 *  视频播放完
		 */		
		protected function playbackComplete():void
		{
			_isComplete = true;
			_isNearlyComplete = false;
			dispatchEvt(StreamStatus.PLAY_COMPLETE);
		}
		
		/**
		 * 视频是否播放完 
		 * @return 
		 * 
		 */		
		public function get isComplete():Boolean
		{
			return _isComplete;
		}
		
		
		public function dragTimeSliderMoving(sec:Number):void
		{
			
		}
		
		/** 音量，默认值为70 **/
		public function get vol():int
		{
			return _volume;
		}
		
		/**
		 * @private
		 */
		public function set vol(value:int):void
		{
			_volume = value;
		}
		
		/**
		 * 连接media server 
		 * 交给子类重写
		 */		
		public function connectToMediaServer(vo:BaseVO=null):void
		{
			
		}
		
		/**
		 * 发送聊天信息, 交给子类重写 
		 * @param name 发送者名字
		 * @param msg 聊天信息
		 * 
		 */		
		public function sendChatMsg(name:String, msg:String):void
		{
			
		}	
		
		/** 是否直播 **/
		public function get isLive():Boolean
		{
			return _isLive;
		}
		
		/** 是否连接到服务器 **/
		public function get isConnected():Boolean
		{
			return _isConnected;
		}
		
		/**
		 * 派发直播时的状态消息 
		 * @param status
		 * 
		 */		
		protected function dispatchLiveStatus(status:String):void
		{
			EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.LIVE_STATUS, status));
		}
	}
}