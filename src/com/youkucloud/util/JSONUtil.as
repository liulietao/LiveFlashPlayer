package com.youkucloud.util
{
	import com.adobe.serialization.json.JSONDecoder;

	/**
	 * 封装了JSON解包的工具类 
	 * 
	 */	
	public class JSONUtil
	{
		public function JSONUtil()
		{
		}
		
		/**
		 * 解密JSON encode的返回结果 
		 * @param source
		 * @return 
		 * 
		 */		
		public static function decode(source:*):*
		{
			var result:*;
			try
			{
				result = (new JSONDecoder(source, true)).getValue();
			}
			catch(err:Error)
			{
				trace("json string error");
				result = {};
			}
			
			return result;
		}
	}
}