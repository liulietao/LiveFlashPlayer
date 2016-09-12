package com.youkucloud.v.component
{
	import com.youkucloud.consts.Font;
	import com.youkucloud.evt.EventBus;
	import com.youkucloud.evt.MediaEvt;
	import com.youkucloud.m.Model;
	import com.youkucloud.util.MultifunctionalLoader;
	import com.youkucloud.v.base.BaseComponent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.TextEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * 错误提示组件 
	 * 
	 */	
	public class ErrorComponent extends BaseComponent
	{
		private var _errorIcon:MovieClip;
		private var _errorInfo:TextField;
		
		public function ErrorComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			var tf:TextFormat = new TextFormat(Font.YAHEI, Font.SIZE, Font.COLOR);
			tf.align = "center";			
			_errorInfo = new TextField();
			_errorInfo.wordWrap = _errorInfo.multiline = true;
			_errorInfo.defaultTextFormat = tf;
			_errorInfo.addEventListener(TextEvent.LINK, linkHandler);
			_errorInfo.htmlText = "抱歉，目前无法播放视频，您可以尝试<font color='#19a97b'><u><a href='event:refresh'>刷新</a></u></font>操作<br/>如果问题仍未解决，请<font color='#19a97b'><u><a href='event:feedback'>反馈给客服</a></u></font>";			
			_errorInfo.width = _errorInfo.textWidth + 230;
			_errorInfo.height = _errorInfo.textHeight + 20;		
			addChild(_errorInfo);
			
			var loader:MultifunctionalLoader = new MultifunctionalLoader();
			loader.registerFunctions(completeHandler);
			loader.load(_m.errorHintVO.url);
			
			super.buildUI();
		}
		
		private function completeHandler(dp:DisplayObject):void
		{			
			_errorIcon = dp as MovieClip;
			_errorIcon.cacheAsBitmap = true;
			addChild(_errorIcon);
			
			this.visible && resize(); //错误提示swf加载进来后，如果当前视频无法播放，则显示此swf
		}
		
		override protected function addListeners():void
		{
			super.addListeners();		
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_ERROR, mediaErrorHandler);
			EventBus.getInstance().addEventListener(MediaEvt.LOAD_LIVE_MEDIA, mediaErrorHandler);
		}
		
		private function mediaErrorHandler(evt:MediaEvt):void
		{
			switch(evt.type)
			{
				case MediaEvt.MEDIA_ERROR:
					this.visible = true;			
					resize();
					break;
				case MediaEvt.LOAD_LIVE_MEDIA:
					this.visible = false;
					break;
			}
		}
		
		override protected function resize():void
		{
			if(this.visible && _errorIcon != null)
			{
				_errorIcon.x = (stageWidth - _errorIcon.width) >> 1;
				_errorIcon.y = 100;
				
				_errorInfo.x = (stageWidth - _errorInfo.width) >> 1;
				_errorInfo.y = _errorIcon.y + _errorIcon.height + 10;
			}
		}
		
		/** 点击下划线链接的处理函数 **/
		private function linkHandler(evt:TextEvent):void
		{
			if(evt.text == "refresh")
			{
				_m.js.refresh();
			}
			else if(evt.text == "feedback")
			{
				navigateToURL(new URLRequest(_m.feedbackVO.url));
			}
		}
	}
}