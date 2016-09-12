package com.youkucloud.m.vo
{
	public class SessionVO extends BaseVO
	{
		//预约token
		public var schedtk:String;
		//播放令牌
		public var playtk:String;
		//上传会话token
		public var sstk:String;
		//请求发布视频地址
		public var requestPublishURL:String;
		//请求播放视频地址
		public var requestPlayURL:String;
		//保持 会话地址 
		public var keepaliveURL:String;
		
		//直播流ID
		public var lvid:String;
		//RTMP app url, netconnection
		public var appURL:String;
		//直播推流地址
		public var publishURL:String;
		//直播播流地址 
		public var playRTMPURL:String;
		
		public function SessionVO()
		{
			super();
		}
	}
}