package com.youkucloud.m.session
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	import com.youkucloud.util.LogUtil;
	
	public class BaseSession extends EventDispatcher
	{
		private var  _log:LogUtil = new LogUtil("BaseSession");
		
		private var _token:String = "";
		
		private var _url:String = "";
		
		private var _streamID:String;
		
		public function BaseSession()
		{
		}

		public function createSession():void
		{
			//Create the HTTP request object
			var request:URLRequest = new URLRequest(_url);
			request.method = URLRequestMethod.POST;
			
			//Add the URL variables 
			request.data = createURLVariables();
			
			//Initiate the transaction 
			var requestor:URLLoader = new URLLoader(); 
			requestor.addEventListener( Event.COMPLETE, httpRequestComplete ); 
			requestor.addEventListener( IOErrorEvent.IO_ERROR, httpRequestError ); 
			requestor.addEventListener( SecurityErrorEvent.SECURITY_ERROR, httpRequestError ); 
			requestor.load( request ); 
		}
		
		protected function createURLVariables():URLVariables
		{
			var variables:URLVariables = new URLVariables(); 
			
			return variables;
		}
		
		protected function httpRequestComplete( event:Event ):void 
		{
//			Logger.debug("httpRequestComplete, ", event.target.data );     
			
			(event.target as URLLoader).removeEventListener( Event.COMPLETE, httpRequestComplete ); 
			(event.target as URLLoader).removeEventListener( IOErrorEvent.IO_ERROR, httpRequestError ); 
			(event.target as URLLoader).removeEventListener( SecurityErrorEvent.SECURITY_ERROR, httpRequestError ); 
		} 
		
		protected function httpRequestError( error:ErrorEvent ):void{ 
			_log.debug( "httpRequestError, An error occured: ", error.text );     
			
			(error.target as URLLoader).removeEventListener( Event.COMPLETE, httpRequestComplete ); 
			(error.target as URLLoader).removeEventListener( IOErrorEvent.IO_ERROR, httpRequestError ); 
			(error.target as URLLoader).removeEventListener( SecurityErrorEvent.SECURITY_ERROR, httpRequestError ); 
		}

		protected function get streamID():String
		{
			return _streamID;
		}

		protected function set streamID(value:String):void
		{
			_streamID = value;
		}
		
		protected function get url():String
		{
			return _url;
		}
		
		protected function set url(value:String):void
		{
			_url = value;
		}
		
		protected function get token():String
		{
			return _token;
		}
		
		protected function set token(value:String):void
		{
			_token = value;
		}

	}
}