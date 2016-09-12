package com.youkucloud.util
{
	public class LogConfiguration
	{		
		private var _level:String = "error";
		private var _filter:String = "*";
		private var _trace:Boolean = false;
		private var _includeTime:Boolean = true;
		
		public function LogConfiguration()
		{
		}
		
		public function get level():String {
			return _level;
		}
		
		public function set level(level:String):void {
			_level = level;
		}
		
		public function get filter():String {
			return _filter;
		}
		
		public function set filter(filter:String):void {
			_filter = filter;
		}
		
		public function get trace():Boolean {
			return _trace;
		}
		
		public function set trace(val:Boolean):void {
			_trace = val;
		}
		
		public function set includeTime(val:Boolean):void{
			_includeTime = val;
		}
		
		public function get includeTime():Boolean{
			return _includeTime;
		}
	}
}