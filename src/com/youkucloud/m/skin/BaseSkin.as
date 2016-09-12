package com.youkucloud.m.skin
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class BaseSkin extends EventDispatcher
	{
		protected var _skin:MovieClip;
		
		public function BaseSkin(target:IEventDispatcher=null)
		{
			super(target);
			
			_skin = new MovieClip();
		}
		
		public function load():void
		{
			
		}
		
		protected function overwriteSkin(newSkin:DisplayObject):void
		{
			_skin = newSkin as MovieClip;
		}
		
		public function get skin():MovieClip
		{
			return _skin;
		}		
	}
}