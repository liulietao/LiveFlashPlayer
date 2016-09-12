package com.youkucloud.v
{
	import com.youkucloud.consts.DebugConst;
	import com.youkucloud.evt.EventBus;
	import com.youkucloud.evt.view.ViewEvt;
	import com.youkucloud.m.Model;
	
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	/**
	 * 右键菜单类 
	 * 
	 */	
	public class RightClickMenu
	{
		private var _context:ContextMenu;
		private var _m:Model;
		
		public function RightClickMenu(m:Model, parent:Sprite)
		{
			super();
			
			this._m = m;		
			_context = new ContextMenu();
			_context.hideBuiltInItems();
			parent.contextMenu = _context; //Stage不实现此属性
		}
		
		public function initializeMenu():void
		{
			addItem(new ContextMenuItem('版本:' + _m.version));
			
			for each(var obj:Object in _m.playerconfig.rightclickinfo)
			{
				addItem(new ContextMenuItem(obj.title), menuItemSelectHandler);
			}
			
			addItem(new ContextMenuItem(DebugConst.SHOW_DEBUG_INFO), menuItemSelectHandler);
		}
		
		/** Add an item to the contextmenu.**/
		protected function addItem(itm:ContextMenuItem, fcn:Function=null):void 
		{
			itm.separatorBefore = true;
			_context.customItems.push(itm);
			fcn && itm.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, fcn);								
		}
		
		/** 如果被选择的menuItem有链接，则跳转到指定的链接地址 **/
		private function menuItemSelectHandler(evt:ContextMenuEvent):void
		{
			var caption:String = (evt.target as ContextMenuItem).caption;
			if(caption == DebugConst.SHOW_DEBUG_INFO)
			{
				EventBus.getInstance().dispatchEvent(new ViewEvt(ViewEvt.SHOW_LOGGER_COMPONENT));
				return;	
			}
			
			for each(var obj:Object in _m.playerconfig.rightclickinfo)
			{
				if(obj.title == caption && obj.url != null)
				{
					navigateToURL(new URLRequest(obj.url));
				}
			}
		}
	}
}