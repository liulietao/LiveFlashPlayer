package com.youkucloud.util
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	
	public class Config extends EventDispatcher
	{
		private var  _log:LogUtil = new LogUtil("Config");
		
		private var _config:Object = {};		
		private var _videoVO:Object;
		
		[Embed(source="../../../../.version",mimeType='application/octet-stream')]
		private var versionXml:Class;
		
		private static const COOKIE_DOMAIN:String = "com.youkucloud.live";
		
		public function Config(target:IEventDispatcher=null)
		{
			super(target);
		}
		public function loadConfig():void
		{
			//加载版本配置文件
			var ba:ByteArray = new versionXml as ByteArray;
			var vxml:XML=new XML(ba.readUTFBytes(ba.length));			
			config['version']  = vxml.value + "-" + vxml.date;
			
			//加载播放器配置文件
			var loader:MultifunctionalLoader = new MultifunctionalLoader(false);
			loader.registerFunctions(loadXMLCompleteHandler, loadXMLErrorHandler);
			loader.load("assets/Config.xml");
		}
		
		private function loadXMLCompleteHandler(data:*):void
		{
			var xml:XML = new XML(data);		
			var array:Array = [];		
			var length:int = xml.rightclickinfo.item.length();
			for(var i:int = 0; i < length; i++)
			{
				array.push({'title':xml.rightclickinfo.item[i].title, 'url':xml.rightclickinfo.item[i].url});
			}			
			_config['rightclickinfo'] = array;
			
			//logo
			var logo:Object = {};
			logo.url = xml.logo.url;
			logo.buttonMode = int(xml.logo.buttonMode);
			logo.margin = int(xml.logo.margin);
			logo.link = xml.logo.link;
			_config['logo'] = logo;
			
//			var errorHint:Object = {};
//			errorHint.url = xml.errorHint.url;
//			_config['errorHint'] = errorHint;	
			
//			_config['learnmore'] = xml.learnmore.url;	
			
			_config['volume'] = int(xml.volume);
			
//			//decrypt
//			_config['omittedLength'] = int(xml.decrypt.omittedLength);
//			_config['seed'] = int(xml.decrypt.seed);
			
			loadFlashvars();			
			loadCookies();
		}
		
		private function loadXMLErrorHandler(error:String):void
		{
			_log.error("loadXMLErrorHandler, " + error);
		}
		
		/**
		 * 存入数据到本地sharedobject
		 * @param param
		 * @param value
		 * 
		 */		
		public static function saveCookie(param:String, value:*):void 
		{
			try 
			{
				var cookie:SharedObject = SharedObject.getLocal(COOKIE_DOMAIN,'/');
				cookie.data[param] = value;
				cookie.flush();
			} 
			catch (err:Error) 
			{
				LogUtil.staticError('Configger','写入数据到本地sharedobject出错', err.toString());
			}
		}
		
		/** 加载flashvars **/
		private function loadFlashvars():void 
		{
			var params:Object = StageReference.stage.loaderInfo.parameters;
			for (var param:String in params)
			{
				setConfigParam(param, params[param]);
			}
		}
		
		/** 加载本地sharedobject数据 **/
		private function loadCookies():void
		{
			try 
			{
				var cookie:SharedObject = SharedObject.getLocal(COOKIE_DOMAIN,'/');
				getCookieData(cookie.data);
			} 
			catch (err:Error) 
			{
				_log.error('Configger','从本地sharedobject读取数据出错',err.toString());
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/** Overwrite cookie data. **/ 
		private function getCookieData(obj:Object):void
		{
			for (var cfv:String in obj) 
			{
				setConfigParam(cfv.toLowerCase(), obj[cfv]); 
			}
		}
		
		private function setConfigParam(name:String, value:String):void 
		{
			if (name != "fullscreen") 
			{
				_config[name.toLowerCase()] = Strings.serialize(Strings.trim(value));
			}
		}
		
		public function get config():Object
		{
			return _config;
		}		
	}
}