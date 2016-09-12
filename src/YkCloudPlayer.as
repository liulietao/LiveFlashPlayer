package
{
	import com.youkucloud.c.Controller;
	import com.youkucloud.m.Model;
	import com.youkucloud.util.LogConfiguration;
	import com.youkucloud.util.LogUtil;
	import com.youkucloud.util.StageReference;
	import com.youkucloud.v.View;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	public class YkCloudPlayer extends Sprite
	{
		private var _model:Model;
		private var _view:View;
		private var _control:Controller;
		
		public function YkCloudPlayer()
		{
			stage ? init() : this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		protected function addedToStageHandler(evt:Event):void			
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			init();
		}
		
		protected function init():void
		{
			var logConfig:LogConfiguration = new LogConfiguration();
			logConfig.level = "debug";
			logConfig.filter= "*";
			logConfig.trace = true;
			LogUtil.configure(logConfig);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			new StageReference(this);
			
			_model = new Model();
			_view  = new View(_model);
			
			_control = new Controller(_view, _model);
			_control.setupPlayer();
		}
	}
}