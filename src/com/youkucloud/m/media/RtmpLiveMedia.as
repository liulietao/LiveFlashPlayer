package com.youkucloud.m.media
{
	import com.youkucloud.consts.ConnectionStatus;
	import com.youkucloud.consts.ModuleID;
	import com.youkucloud.consts.StreamStatus;
	import com.youkucloud.consts.UserRole;
	import com.youkucloud.consts.module.ChatModuleEvtType;
	import com.youkucloud.m.vo.BaseVO;
	import com.youkucloud.m.vo.MediaVO;
	import com.youkucloud.m.vo.MsgVO;
	import com.youkucloud.m.vo.SessionVO;
	import com.youkucloud.util.LogUtil;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;

	public class RtmpLiveMedia extends BaseLiveMedia
	{
		private var  _log:LogUtil = new LogUtil("RtmpLiveMedia");
		
		public function RtmpLiveMedia(mediaType:String)
		{
			super(mediaType);
		}
		
		override public function init(mediaVO:MediaVO, sessionVO:SessionVO):void
		{
			super.init(mediaVO, sessionVO);
		}
		
		override public function connectToMediaServer(vo:BaseVO=null):void
		{
			super.connectToMediaServer(vo);
			
			var url:String = _sessionVO.appURL;
			_nc.connect(url, _userVO);
			
			_log.debug("connectToMediaServer:" + url);
		}
		
		/** 状态处理函数 **/
		override protected function statusHandler(evt:NetStatusEvent):void
		{
			_log.info('statusHandler::rtmp live status', evt.info.code);
			
			switch(evt.info.code)
			{
				//handle netconnection status
				case ConnectionStatus.SUCCESS:	
					super.connectServerSuccess();
					
					_outgoingStream = new NetStream(_nc);
					_outgoingStream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);		
					_outgoingStream.client = this;
					
					_incomingStream  = new NetStream(_nc);
					_incomingStream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);					
					_incomingStream.client = this;
					
					if(_userVO.role == UserRole.PUBLISHER)
					{
						super.publishStream();
					}
					else
					{
						super.playStream();
					}					
					
					super.dispatchEvt(StreamStatus.RTMPSERVER_CONNECTION_SUCCESS);
					super.dispatchMetaData({w:_video.width, h:_video.height});
					break;
				case ConnectionStatus.REJECTED:
					super.dispatchLiveStatus('连接服务器被拒');
					super.dispatchEvt(ConnectionStatus.REJECTED);
					break;
				case ConnectionStatus.CLOSED:
					super.dispatchLiveStatus('连接关闭');		
					super.dispatchEvt(ConnectionStatus.CLOSED);
					break;
				case ConnectionStatus.FAILED:
					super.dispatchLiveStatus('连接失败');
					super.dispatchEvt(ConnectionStatus.FAILED);
					break;
				case StreamStatus.PLAY_START:
					super.dispatchEvt(StreamStatus.PLAY_START);
					super.dispatchEvt(StreamStatus.BUFFER_FULL);
					break;
				case StreamStatus.PLAY_STOP:
					super.dispatchEvt(StreamStatus.PLAY_COMPLETE);
					break;
				case StreamStatus.PUBLISH_START:
					super.dispatchEvt(StreamStatus.PUBLISH_START);
					break;
				case StreamStatus.BAD_NAME:
					super.dispatchLiveStatus('视频地址已经被发布');
					break;
				default:
					break;
			}
		}
		
		override public function sendChatMsg(name:String, msg:String):void
		{
			var msgVO:MsgVO = new MsgVO();
			msgVO.type = ChatModuleEvtType.TO_ALL_MESSAGE;
			msgVO.content = name + "说：" + msg;
			msgVO.moduleID = ModuleID.CHAT;
			
			_nc.call('sendMessage', null, msgVO); 	//发送给服务器广播			
		}
	}
}