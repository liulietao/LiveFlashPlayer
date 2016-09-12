package com.youkucloud.consts.session
{
	public class RequestPublishReturnCode
	{
		//schedtk不存在
		public static const SCHEDULE_TOKEN_NOT_EXIST:int = 201420; 
		//schedtk已过期
		public static const SCHEDULE_TOKEN_EXPIRED:int   = 201421;
		//proto不存在
		public static const PROTO_NOT_EXIST:int 		 = 201422;
		//proto在对应地域不支持
		public static const PROTO_NOT_SUPPORT:int  		 = 201423;
		//sstk不存在
		public static const SESSION_TOKEN_NOT_EXIST:int  = 201425;
		//sstk已过期
		public static const SESSION_TOKEN_EXPIRED:int    = 201426;
		//直播流状态冲突，不能推送
		public static const LIVE_STATUS_CONFLICT:int	 = 201429;
		//直播流已经被屏蔽
		public static const LIVE_CUTDOWN:int			 = 201430;
		//schedtk校验失败
		public static const SCHEDULE_TOKEN_INCORRECT:int = 201431;
		//sstk校验失败
		public static const SESSION_TOKEN_INCORRECT:int  = 201433;
		
		
		public function RequestPublishReturnCode()
		{
		}
	}
}