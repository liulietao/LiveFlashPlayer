package com.youkucloud.consts
{

	public class StreamStatus
	{
		public static const START_LOAD_MEDIA:String = "start_load_media";
		
		public static const LOAD_MEDIA_IOERROR:String = "load_media_ioerror";
		
		public static const PUBLISH_START:String = "NetStream.Publish.Start";
		
		public static const PUBLISH_STOP:String = "NetStream.Publish.stop";
		
		public static const BAD_NAME:String = "NetStream.Publish.BadName";
		
		public static const PLAY_START:String = "NetStream.Play.Start";
		
		public static const PLAY_STOP:String = "NetStream.Play.Stop";
		
		public static const PAUSE_NOTIFY:String = "NetStream.Pause.Notify";
		
		public static const UNPAUSE_NOTIFY:String = "NetStream.Unpause.Notify";
		
		public static const BUFFER_FULL:String = "NetStream.Buffer.Full";
		
		public static const BUFFER_EMPTY:String = "NetStream.Buffer.Empty";
		
		public static const STREAM_NOT_FOUND:String = "NetStream.Play.StreamNotFound";
		
		public static const SEEKSTART_NOTIFY:String = "NetStream.SeekStart.Notify";		
		/**
		 * 搜寻操作完成 ,等待buffer full后流就可以播放
		 */				
		public static const SEEK_NOTIFY:String = "NetStream.Seek.Notify";
		
		public static const SEEK_COMPLETE:String = "NetStream.Seek.Complete";
		
		public static const PLAY_COMPLETE:String = "media_play_complete";
		
		/**
		 * 流快要结束 
		 */		
		public static const PLAY_NEARLY_COMPLETE:String = "play_nearly_complete";
		
		/**
		 * 流播放位置未到快要结束界限，比如距离播放结束40s以内认为是play_nearly_complete
		 * 距离播放结束超过40s就是not_nearly_complete 
		 */		
		public static const NOT_NEARLY_COMPLETE:String = "not_nearly_complete";
		
		/**
		 * 搜索失败，如果流处于不可搜索状态，则会发生搜索失败 
		 */		
		public static const SEEK_FAILED:String = "NetStream.Seek.Failed";
		
		/**
		 * 直播流，包括rtmfp和rtmp直播流 
		 */		
		public static const RTMPSERVER_CONNECTION_SUCCESS:String = "rtmpserver.connection.success";
		
		/**
		 * FlashPlayer版本低于12.0, 无法使用多线程 
		 */		
		public static const FPVERSION_TOO_LOW:String = "fpversion_too_low";
		
		/**
		 * 处理加密视频时发生错误 
		 */		
		public static const HANDLE_ENCRYPTED_MEDIA_ERROR:String ="handle_encrypted_media_error";	
		
		public function StreamStatus()
		{
		}
	}
}