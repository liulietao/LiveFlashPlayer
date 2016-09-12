package com.youkucloud.m.vo
{
	import com.youkucloud.consts.UserRole;

	public class UserVO extends BaseVO
	{
		public function UserVO()
		{
			super();
		}
		
		public var name:String;
		
		public var groupName:String;
		
		public var role:String = UserRole.PLAYER;
	}
}