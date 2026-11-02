package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.events.Event;
import vlc.VlcBitmap;

class VideoMP4
{
	#if WINDOWS_BUILD
	public var bitmap:VlcBitmap;

	public var finishCallback:Void->Void;
	public var stateCallback:FlxState;

	public var sprite:FlxSprite;
	public var isPaused:Bool = false;
	public var isVideo:Bool = false;

	// vlc 回调线程 → 主线程 转发标志（switchState/GDI/FlxTimer 一律回主线程）
	var readyFlag:Bool = false;
	var deferredEnd:Bool = false;
	var deferredError:Bool = false;
	var cleanedUp:Bool = false;

	public function new() {

	}

	public function playMP4(path:String, ?opacity:Float = 1, ?repeat:Bool = false, ?outputTo:FlxSprite = null, ?isWindow:Bool = false, ?isFullscreen:Bool = false, ?midSong:Bool = false):Void
	{
		if (!midSong)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.stop();
			}
		}

		bitmap = new VlcBitmap();

		if (FlxG.stage.stageHeight / 9 < FlxG.stage.stageWidth / 16)
		{
			bitmap.set_width(FlxG.stage.stageHeight * (16 / 9));
			bitmap.set_height(FlxG.stage.stageHeight);
		}
		else
		{
			bitmap.set_width(FlxG.stage.stageWidth);
			bitmap.set_height(FlxG.stage.stageWidth / (16 / 9));
		}

		bitmap.onVideoReady = onVLCVideoReady;
		bitmap.onComplete = onVLCComplete;
		bitmap.onError = onVLCError;

		FlxG.stage.addEventListener(Event.ENTER_FRAME, update);

		if (repeat)
			bitmap.repeat = -1;
		else
			bitmap.repeat = 0;

		bitmap.inWindow = isWindow;
		bitmap.fullscreen = isFullscreen;

		FlxG.addChildBelowMouse(bitmap);
		bitmap.play(checkFile(path));

		if (outputTo != null)
		{
			bitmap.alpha = 0;
			sprite = outputTo;
		}

		bitmap.alpha = opacity;
	}

	function checkFile(fileName:String):String
	{
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd() + "/";

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
	}

	// vlc 回调线程：只置标志，一切主线程 API（switchState/GDI/FlxTimer）回主线程执行
	function onVLCVideoReady():Void
	{
		readyFlag = true;
	}

	public function onVLCComplete():Void
	{
		deferredEnd = true;
	}

	function onVLCError():Void
	{
		deferredError = true;
	}

	function update(e:Event)
	{
		bitmap.volume = 0;
		if(!FlxG.sound.muted && FlxG.sound.volume > 0.01) {
			bitmap.volume = FlxG.sound.volume * 0.5 + 0.5;
		}

		if (readyFlag)
		{
			readyFlag = false;
			trace("Video sprite loaded.");
			if (sprite != null)
				sprite.loadGraphic(bitmap.bitmapData);
			isVideo = true;
		}

		if (deferredError && !cleanedUp)
		{
			cleanedUp = true;
			bitmap.stop();
			isVideo = false;
			trace("Video ERROR, falling back.");
			finishVideo();
		}

		if (deferredEnd && !cleanedUp)
		{
			cleanedUp = true;
			bitmap.stop();
			isVideo = false;
			FlxG.camera.fade(FlxColor.BLACK, 0, false);
			trace("Video Ended, HOPEFULLY NO ERRORS FROM HERE!");
			finishVideo();
		}
	}

	function finishVideo():Void
	{
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if (finishCallback != null)
			{
				finishCallback();
			}
			else if (stateCallback != null)
			{
				LoadingState.loadAndSwitchState(stateCallback);
			}

			bitmap.dispose();

			if (FlxG.game.contains(bitmap))
			{
				FlxG.game.removeChild(bitmap);
			}
		});
	}

	public function kill()
	{
		bitmap.stop();
		isVideo = false;

		if (finishCallback != null)
		{
			finishCallback();
		}

		bitmap.visible = false;
	}
	#end
}
