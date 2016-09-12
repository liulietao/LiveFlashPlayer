package com.youkucloud.util
{
	import com.youkucloud.m.vo.ResolutionVO;
	import com.youkucloud.util.LogUtil;

	public class VideoUtil
	{
		public function VideoUtil()
		{
		}
		
		/**
		 * 根据视频质量值，返回分辨率值
		 */
		public static function getResolution(quality:int):ResolutionVO
		{
			var resolution:ResolutionVO = new ResolutionVO;
			
			switch(quality)
			{
				case 0:
					resolution.width  = 320;
					resolution.height = 240;
					break;
				case 1:
					resolution.width  = 640;
					resolution.height = 480;
					break;
				case 2:
					resolution.width  = 1280;
					resolution.height = 720;
					break;
				case 3:
					resolution.width  = 1920;
					resolution.height = 1080;
					break;
				default:
					resolution.width  = 640;
					resolution.height = 480;
					break;
			}
			
			return resolution;
		}
		
		public static function getBitrateThreshold(width:int, height:int):int
		{
			var threshold:int = 700*1024/8;//700 Kbps
			
			if(width == 120 && height == 90)
			{
				threshold = 40*1024/8;//40kbps
			}
			else if (width == 160 && height == 120)
			{
				threshold = 80*1024/8;
			}
			else if (width == 160 && height == 240)
			{
				threshold = 100*1024/8;
			}
			else if (width == 240 && height == 180)
			{
				threshold = 130*1024/8;
			}
			else if (width == 320 && height == 240)
			{
				threshold = 180*1024/8;
			}
			else if (width == 320 && height == 480)
			{
				threshold = 250*1024/8;
			}
			else if (width == 640 && height == 480)
			{
				threshold = 600*1024/8;
			}
			else if (width == 1280 && height == 720)
			{
				threshold = 1200*1024/8;
			}
			else if (width == 1920 && height == 1080)
			{
				threshold = 2000*1024/8;
			}
			
			LogUtil.staticInfo("getBitrateThreshold (" + width + "," + height + "), bitrate threshold : " + threshold*8/1024 + "kbps");
			return threshold;
		}		
	}
}