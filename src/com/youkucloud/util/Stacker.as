package com.youkucloud.util
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	
	import com.youkucloud.consts.Layout;

	/**
	 * 控制controlbar元素的堆放 
	 * 
	 */	
	public class Stacker
	{
		private var _mc:MovieClip;
		private var _stack:Array;
		
		public function Stacker(mc:MovieClip)
		{
			this._mc = mc;			
			analyze();
		}
		
		/** Analyze the MovieClip and save its children. **/
		private function analyze():void 
		{
			_stack = [];
			
			var clp:DisplayObject;
			var num:uint = _mc.numChildren;
			for(var i:uint = 0; i < num; i++)
			{
				clp = _mc.getChildAt(i);
				_stack.push(
					{
						c: clp, //元素 
						x: clp.x,  //元素坐标
						n: clp.name, //元素name 
						width: clp.width //元素宽度
					});
			}		
			
			_stack.sortOn([ 'x', 'n' ], [ Array.NUMERIC, Array.CASEINSENSITIVE ]);			
		}
		
		public function rearrange(wid:Number):void 
		{		
			if(!wid || !_mc || _mc.back==null)
				return;
			
			_mc.back.x = 0;
			_mc.back.width = wid;
			
			//临界值， 原始皮肤中播放，暂停按钮和timeslider的x坐标是不变的，即timeSlider左侧的元素不需要调整，右侧的元素需要调整
			var num_simplebutton:int = 0;  //需要调整的按钮的数量
			var len:int = _stack.length;			
			var needAdjustArr:Array = []; //存放需要调整位置的元素
			
			for(var m:int = 0; m < len; m++)
			{
				if(_stack[m].c.x > _mc.timeSlider.x && _stack[m].c.visible)
				{
					if(_stack[m].c is SimpleButton || (_stack[m].n == "trumpet"))
					{
//						Logger.debug('_stack[m]---->', _stack[m].c.name);
						num_simplebutton++;
						needAdjustArr.push(_stack[m]);
					}					
				}					
			}			
			
			if(num_simplebutton == 0)
				return;
			
			var lastclip:*  = _stack[len - 1].c;
			var timeSlider_width:Number = 0;
			//最后一个clip应该是kuaijiLogoButton
			if(lastclip.name != "helpTip" && lastclip is MovieClip && lastclip.visible)
			{
				lastclip.x = wid - Layout.MARGIN_TO_STAGEBORDER - lastclip.width * 0.5;
				timeSlider_width = wid - _mc.timeSlider.x - Layout.MARGIN_TO_STAGEBORDER - lastclip.width - (_mc.settingButton.width + Layout.MARGIN_BETWEEN_BUTTON) * num_simplebutton;
			}
			else
			{
				timeSlider_width = wid - _mc.timeSlider.x - Layout.MARGIN_TO_STAGEBORDER - (_mc.settingButton.width + Layout.MARGIN_BETWEEN_BUTTON) * num_simplebutton;
			}					
			
			var scale:Number = timeSlider_width / _mc.timeSlider.rail.width;
			_mc.timeSlider.rail.width = _mc.timeSlider.hline.width = timeSlider_width;
			_mc.timeSlider.done.width = _mc.timeSlider.mark.width *= scale; 
			
			var length:int = needAdjustArr.length;
			for(var j:int = 0; j < length; j++)
			{
				needAdjustArr[j].c.x = _mc.timeSlider.x + timeSlider_width + Layout.MARGIN_BETWEEN_BUTTON * (j+1) + needAdjustArr[j].width * (j + 0.5);
//				Logger.debug('adjust--->', needAdjustArr[j].c.x, needAdjustArr[j].c.name);
			}	
			
			_mc.fullscreenButton.visible ? (_mc.normalscreenButton.x = _mc.fullscreenButton.x) : (_mc.fullscreenButton.x = _mc.normalscreenButton.x);
		}
	}
}