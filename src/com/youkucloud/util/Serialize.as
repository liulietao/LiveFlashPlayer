package com.youkucloud.util
{
	public class Serialize
	{
		public function Serialize()
		{
		}
		
		public static function serialize(sourceObj:Object, resultObj:*):*
		{
			try
			{
				for (var item:* in sourceObj)
				{
					resultObj[item] = sourceObj[item];
				}
			}
			catch(err:Error)
			{
				LogUtil.staticError('Serialize', err.toString());
				resultObj = null;
			}		
			
			return resultObj;
		}
	}
}