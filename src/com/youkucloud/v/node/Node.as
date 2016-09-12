package com.youkucloud.v.node
{
	import com.youkucloud.consts.NumberConst;
	import com.youkucloud.util.Strings;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	/**
	 * 视频播放时间轴，节点显示对象 
	 * 
	 */	
	public class Node extends Sprite
	{
		private var _obj:Object;
		public function Node(obj:Object)
		{
			super();
			
			_obj = obj;
			
			initUI();
		}
		
		private function initUI():void
		{
			var g:Graphics = this.graphics;
			g.beginFill(0xffffff);
			g.drawCircle(0,0,NumberConst.NODE_RADIUS);
			g.endFill();
		}
		
		/**
		 * 
		 * @return 时间节点的提示信息
		 * 
		 */		
		public function get hint():String
		{
			return Strings.digits(_obj.time) + "  " + _obj.hint;
		}
		
		public function get time():Number
		{
			return _obj.time;
		}
	}
}