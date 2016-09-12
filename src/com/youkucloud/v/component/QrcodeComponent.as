package com.youkucloud.v.component
{
	import com.greensock.TweenLite;
	import com.youkucloud.evt.EventBus;
	import com.youkucloud.evt.js.JSEvt;
	import com.youkucloud.m.Model;
	import com.youkucloud.v.base.BaseComponent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	/**
	 * 二维码组件 
	 * 
	 */	
	public class QrcodeComponent extends BaseComponent
	{
		private var _qrcode:Sprite;
		
		public function QrcodeComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			_qrcode = new Sprite();
			addChild(_qrcode);
			
			super.buildUI();
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			EventBus.getInstance().addEventListener(JSEvt.QRCODE, qrcodeHandler);
		}
		
		private function qrcodeHandler(evt:JSEvt):void
		{
			if(this.visible)
				return;
			
			if(!_qrcode.numChildren)
			{
//				var bitmap:Bitmap = QRCodeUtil.getQRCode(_m.qrcodeVO.url);
//				bitmap.x = -bitmap.width * 0.5;
//				bitmap.y = -bitmap.height * 0.5;
//				_qrcode.addChild(bitmap);
//				
//				drawCloseBtn();
//				this.addChild(_closeBtn);						
			}
			
			_closeBtn.visible = false; //等到动画结束后再显示
			this.visible = true;			
			resize();		
		}
		
		override protected function resize():void
		{
			if(this.visible)
			{
				_qrcode.x = stageWidth >> 1;
				_qrcode.y = stageHeight >> 1;
				
				_closeBtn.x = _qrcode.x + _qrcode.width*0.5;
				_closeBtn.y = _qrcode.y - _qrcode.height*0.5;
				
				_compTween = TweenLite.from(_qrcode, 0.3, {scaleX:0.3, scaleY:0.3, alpha:0.3, onComplete:compTweenComplete});
			}			
		}
		
		private function compTweenComplete():void
		{
			_closeBtn.visible = true;
		}
	}
}