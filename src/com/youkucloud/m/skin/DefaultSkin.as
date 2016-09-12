package com.youkucloud.m.skin
{
	import com.youkucloud.util.LogUtil;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	
	public class DefaultSkin extends BaseSkin
	{
		[Embed(source="../../../../../assets/skin/skin.swf")]
		private var EmbeddedSkin:Class;
		
		private var  _log:LogUtil = new LogUtil("DefaultSkin");
		
		public function DefaultSkin(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		override public function load():void 
		{
			var embedSWF:MovieClip = new EmbeddedSkin() as MovieClip;
			var embeddedLoader:Loader = embedSWF.getChildAt(0) as Loader;
			
			embeddedLoader.contentLoaderInfo.addEventListener(Event.INIT, loadComplete);
			embeddedLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
		}		
		
		protected function loadComplete(evt:Event):void 
		{
			try
			{
				var loader:LoaderInfo = LoaderInfo(evt.target);
				var skinClip:MovieClip = MovieClip(loader.content);
				
				overwriteSkin(skinClip.getChildByName('player'));
				loader.removeEventListener(Event.INIT, loadComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
			}
			catch(err:Error)
			{
				_log.error('DefaultSkin', '获取皮肤内容出错', evt.toString());
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function loadError(evt:IOErrorEvent):void 
		{
			_log.error('DefaultSkin','加载默认皮肤出错', evt.toString());
		}		
	}
}