package com.youkucloud.v.component
{
	import com.youkucloud.consts.Font;
	import com.youkucloud.evt.EventBus;
	import com.youkucloud.evt.MediaEvt;
	import com.youkucloud.evt.settings.SettingsEvt;
	import com.youkucloud.m.Model;
	import com.youkucloud.util.LogUtil;
	import com.youkucloud.util.UIUtil;
	import com.youkucloud.v.base.BaseComponent;
	
	import flash.display.StageDisplayState;
	import flash.text.TextField;
	
	/**
	 * 字幕组件，目前只支持对srt字幕的解析
	 * 
	 */	
	public class SubtitleComponent extends BaseComponent
	{
		private var  _log:LogUtil = new LogUtil("SubtitleComponent");
		
		/** 默认字幕 **/
		private var _defaultSubtitle:TextField;
		/** 双语字幕时的第二字幕 **/
		private var _secondSubtitle:TextField;
		/** 字幕时间当前位置 **/
		private var _index:int = 0;
		private var _pos:Number;
		
		public function SubtitleComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			_defaultSubtitle = new TextField();
			_defaultSubtitle.selectable = false;
			addChild(_defaultSubtitle);
			
			if(_m.subtitleVO.isBilingual) //双语字幕
			{
				_secondSubtitle = new TextField();
				_secondSubtitle.selectable = false;
				addChild(_secondSubtitle);
			}
			
			//默认显示字幕
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_TIME, timeHandler);
			EventBus.getInstance().addEventListener(SettingsEvt.SHOW_SUBTITLE, showSubtitleHandler);
			EventBus.getInstance().addEventListener(SettingsEvt.CLOSE_SUBTITLE, closeSubtitleHandler);
		}
		
		private function timeHandler(evt:MediaEvt):void
		{
			if(_m.srtTimeArray == null || _m.srtTimeArrayLength == 0)
			{
				_log.error('SubtitleComponent', '字幕数据不正确');
				EventBus.getInstance().removeEventListener(MediaEvt.MEDIA_TIME, timeHandler);
				return;
			}
			
			_pos = evt.data.position;
			if(_pos < _m.srtTimeArray[0] || _pos > _m.srtTimeArray[_m.srtTimeArrayLength - 1])
				return;
			
			if((_index % 2 == 0) && _pos >= _m.srtTimeArray[_index] && _pos < _m.srtTimeArray[_index + 1])
			{
				if(_defaultSubtitle.text != _m.defaultLangTextArray[_index / 2])
				{
					_defaultSubtitle.text = _m.defaultLangTextArray[_index / 2];
					!secondSubtitleIsNull && (_secondSubtitle.text = _m.secondLangTextArray[_index / 2]); 
					resize();
				}				
			}
			else
			{
				_defaultSubtitle.text = "";
				!secondSubtitleIsNull && (_secondSubtitle.text = "");
				updateIndex();
			}			
		}
		
		private function updateIndex():void
		{
			if(_m.srtTimeArrayLength == 0)
				return;
			
			for(var i:int = 0; i < _m.srtTimeArrayLength; i+=2) //for循环的步长为2
			{
				if(_pos >= _m.srtTimeArray[i] && _pos < _m.srtTimeArray[i+1])
				{
					_index = i;
					break;
				}
			}
		}
		
		private function showSubtitleHandler(evt:SettingsEvt):void
		{
			if(!visible)
			{
				visible = true;
				resize();
			}
		}
		
		private function closeSubtitleHandler(evt:SettingsEvt):void
		{
			visible = false;
		}
		
		override protected function resize():void
		{
			if(visible)
			{
				//全屏状态和普通状态下字幕字体的大小不一样
				if(displayState == StageDisplayState.NORMAL)
				{
					_defaultSubtitle.setTextFormat(UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.DEFAULT_SUBTITLE_SIZE));
					UIUtil.adjustTFWidthAndHeight(_defaultSubtitle);
					
					if(!secondSubtitleIsNull)
					{
						_secondSubtitle.setTextFormat((UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.SECOND_SUBTITLE_SIZE)));
						UIUtil.adjustTFWidthAndHeight(_secondSubtitle);	
					}
				}
				else if(displayState == StageDisplayState.FULL_SCREEN)
				{
					_defaultSubtitle.setTextFormat(UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.DEFAULT_SUBTITLE_SIZE_FULLSCREEN));
					UIUtil.adjustTFWidthAndHeight(_defaultSubtitle, 10);
					if(!secondSubtitleIsNull)
					{
						_secondSubtitle.setTextFormat(UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.SECOND_SUBTITLE_SIZE_FULLSCREEN));
						UIUtil.adjustTFWidthAndHeight(_secondSubtitle, 10);
					}
				}
				
				_defaultSubtitle.x = (stageWidth - _defaultSubtitle.textWidth) >> 1;
				_defaultSubtitle.y = stageHeight - controlbarHeight - 50;
				
				if(!secondSubtitleIsNull)
				{
					_secondSubtitle.x = (stageWidth - _secondSubtitle.textWidth) >> 1;
					_secondSubtitle.y = _defaultSubtitle.y - _secondSubtitle.height;
				}
			}
		}
		
		override protected function mediaCompleteHandler(evt:MediaEvt):void
		{
			_defaultSubtitle.text = "";
			!secondSubtitleIsNull && (_secondSubtitle.text = "");
			_index = 0;
		}
		
		/** 第二字幕是否为null **/
		protected function get secondSubtitleIsNull():Boolean
		{
			return _secondSubtitle == null;
		}
	}
}