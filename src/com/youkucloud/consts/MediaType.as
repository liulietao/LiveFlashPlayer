package com.youkucloud.consts
{
	public class MediaType
	{
		//普通的http视频，包括flv, mp4, f4v
		public static const HTTP:String = "http";
		
		//加密的视频 
		public static const HTTPE:String = "httpe";
		
		//hls视频 
		public static const HLS:String = "hls";
		
		//多段拼接起来的视频 
		public static const HTTPM:String = "httpm";
		
		//基于RTMP协议的点播 
		public static const RTMP_VOD:String = "rtmp_vod";
		
		//基于rtmp协议的直播 
		public static const RTMP_LIVE:String = "rtmp_live";
		
		//p2p直播 
		public static const P2PLIVE:String = "p2plive";
		
		public function MediaType()
		{
		}
	}
}