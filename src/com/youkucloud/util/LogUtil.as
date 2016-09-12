package com.youkucloud.util
{
	import flash.utils.getQualifiedClassName;
	
	import org.osflash.thunderbolt.Logger;
	
	public class LogUtil
	{		
		private static const LEVEL_DEBUG:int = 0;
		private static const LEVEL_WARN:int = 1;
		private static const LEVEL_INFO:int = 2;
		private static const LEVEL_ERROR:int = 3;
		private static const LEVEL_SUPPRESS:int = 4;
		
		private static var _level:int = LEVEL_ERROR;
		private static var _filter:String = "*";
		public static var traceEnabled:Boolean = false;
		
		private var _owner:String;
		private var _enabled:Boolean  = true;
		
		public function LogUtil(owner:Object) 
		{
			_owner = owner is String ? owner as String : getQualifiedClassName(owner);
			enable();
		}
		
		private function enable():void 
		{
			_enabled = checkFilterEnables(_owner);
		}
		
		private function checkFilterEnables(owner:String):Boolean 
		{
			if (_filter == "*") return true;
			var className:String;
			var parts:Array = owner.split(".");
			var last:String = parts[parts.length - 1];
			var classDelimPos:int = last.indexOf("::"); 
			if (classDelimPos > 0) {
				className = last.substr(classDelimPos + 2);
				parts[parts.length -1] = last.substr(0, classDelimPos);
			}
			var packageName:String = "";
			for (var i:Number = 0; i < parts.length; i++) {
				packageName = i > 0 ? packageName + "." + parts[i] : parts[i];
				if (_filter.indexOf(parts[i] + ".*") >= 0) {
					return true;
				}
			}
			var result:Boolean = _filter.indexOf(packageName + "." + className) >= 0;
			return result;
		}
		
		public static function configure(config:LogConfiguration):void 
		{
			level = config.level;
			filter = config.filter;
			traceEnabled = config.trace;
			Logger.includeTime = config.includeTime;
			Logger.showCaller  = false;
		}
		
		public static function set level(level:String):void 
		{
			if (level == "debug") 
				_level = LEVEL_DEBUG;
			else if (level == "warn")
				_level = LEVEL_WARN;
			else if (level == "info")
				_level = LEVEL_INFO;
			else if (level == "suppress")
				_level = LEVEL_SUPPRESS;
			else
				_level = LEVEL_ERROR;
		}
		
		public static function set filter(filterValue:String):void 
		{
			_filter = filterValue;
		}		
		
		public static function staticError(msg:String = null, ...rest):void
		{
			if (traceEnabled) {
				trace(msg + " " + rest);
			}
			
			Logger.error(msg, rest);
		}
		public static function staticInfo(msg:String = null, ...rest):void
		{
			if (traceEnabled) {
				trace(msg + " " + rest);
			}
			
			Logger.info(msg, rest);
		}
		
		public function debug(msg:String = null, ...rest):void 
		{
			if (!_enabled) return;
			if (_level <= LEVEL_DEBUG)
				write(Logger.debug, msg, "DEBUG", rest);
		}
		
		public function error(msg:String = null, ...rest):void 
		{
			if (!_enabled) return;
			if (_level <= LEVEL_ERROR)
				write(Logger.error, msg, "ERROR", rest);
		}
		
		public function info(msg:String = null, ...rest):void 
		{
			if (!_enabled) return;
			if (_level <= LEVEL_INFO)
				write(Logger.info, msg, "INFO", rest);
		}
		
		public function warn(msg:String = null, ...rest):void 
		{
			if (!_enabled) return;
			if (_level <= LEVEL_WARN)
				write(Logger.warn, msg, "WARN", rest);
		}
		
		public function memorySnapshot():String
		{
			return Logger.memorySnapshot();
		}
		
		public function about():void
		{
			Logger.about();
		}
		
		private function write(writeFunc:Function, msg:String, levelStr:String, rest:Array):void
		{
			if (traceEnabled) {
				doTrace(msg, levelStr, rest);
			}
			try {
				if (rest.length > 0)
					writeFunc(_owner + " : " + msg, rest);
				else
					writeFunc(_owner + " : " + msg);
			} catch (e:Error) {
				//                trace(msg);
				//                trace(e.message);
			}
		}
		
		private function doTrace(msg:String, levelStr:String, rest:Array):void 
		{
			trace(_owner + "::" + levelStr + ":" + msg);
		}
		
		public function get enabled():Boolean 
		{
			return _enabled;
		}
		
		public function set enabled(enabled:Boolean):void 
		{
			_enabled = enabled;
		}
		
		public function debugStackTrace(msg:String = null):void
		{
			if (!_enabled) return;
			if (_level <= LEVEL_DEBUG)
				try { throw new Error("StackTrace"); } catch (e:Error) { debug(msg, e.getStackTrace()); }
		}
	}
}