package com.youkucloud.m.js
{
	import com.youkucloud.util.LogUtil;
	import com.youkucloud.evt.js.JSEvt;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	public class JSAPI extends EventDispatcher
	{
		private var  _log:LogUtil = new LogUtil("JSAPI");
		
		private static var _instance:JSAPI;
		
		public static function getInstance():JSAPI
		{
			if(_instance == null)
				_instance = new JSAPI();
			return _instance;
		}
		
		public function JSAPI()
		{
			super();
			
			if(available)
			{
				try
				{
					ExternalInterface.addCallback("fl_screenshot", screenshotHandler);
					ExternalInterface.addCallback("fl_qrcode", qrcodeHandler);
					ExternalInterface.addCallback("fl_pause", pauseHandler);
					ExternalInterface.addCallback("fl_play", playeHandler);
					ExternalInterface.addCallback("fl_sendMsg", sendMsgHandler);
				}
				catch(err:Error)
				{
					_log.error("JSAPI", err.toString());
				}
			}		
		}
		
		/**
		 * 截图
		 * @param w 截图宽度
		 * @param h 截图高度
		 * 
		 */		
		private function screenshotHandler(w:Number, h:Number):void
		{		
			dispatchEvent(new JSEvt(JSEvt.SCREENSHOT, {'width':w, 'height':h}));
		}
		
		
		private function qrcodeHandler():void
		{
			dispatchEvent(new JSEvt(JSEvt.QRCODE));
		}
		
		private function pauseHandler():void
		{
			dispatchEvent(new JSEvt(JSEvt.PAUSE));
		}
		
		private function playeHandler():void
		{
			dispatchEvent(new JSEvt(JSEvt.PLAY));
		}
		
		/** 聊天信息，生成弹幕 **/
		private function sendMsgHandler(obj:Object):void
		{
			if(obj.msg == '')
				return;
			
			dispatchEvent(new JSEvt(JSEvt.BULLETCURTAIN, obj));
		}
		
		/**
		 * 播放下一集 
		 * 
		 */		
		public function playnext():void
		{
			available && ExternalInterface.call('alert', '播放下一集');	
		}
		
		/**
		 * 图片的字符串数据 
		 * @param str
		 * 
		 */		
		public function showScreenshot(str:String):void
		{
			available && ExternalInterface.call('showScreenshot', str);
		}
		
		/**
		 * 刷新当前页面 
		 * 
		 */		
		public function refresh():void
		{
			available && ExternalInterface.call("location.replace(location.href)");
		}
		
		/**
		 * 提醒用户升级 
		 * 
		 */		
		public function fpVersionTooLow():void
		{
			available && ExternalInterface.call("alert", "FlashPlayer版本太低，请升级到12.0(包括12.0)以上");
		}
		
		/** 外部接口是否可用 **/
		private function get available():Boolean
		{
			return ExternalInterface.available;
		}		
	}
}