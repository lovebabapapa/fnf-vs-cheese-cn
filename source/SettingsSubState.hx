package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flash.system.System;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

/**
	MENU FOR MOST CONTROLS INCLUDING THEIR CATEGORIES
**/

class SettingsSubState extends MusicBeatSubstate
{
	public static var category:String = '';

	static var unselectableOptions:Array<String> = ['oops'];

	static var noCheckbox:Array<String> = [
		'输入系统：',
		'清除存档',
		'背景变暗',
		'安全帧',
		'帧率上限',
		'音符偏移'
	];

	private static var curSelected:Int = 0;

	private var options:Array<String> = [];
	private var grpOptions:FlxTypedGroup<AlphabetWhite>;
	private var checkboxArray:Array<CheckboxThingie> = [];
	private var checkboxNumber:Array<Int> = [];
	private var grpTexts:FlxTypedGroup<AttachedText>;
	private var textNumber:Array<Int> = [];

	private var characterLayer:FlxTypedGroup<Character>;
	private var CharacterBoyfriend:Character;
	private var descText:FlxText;
	private var pauseText:FlxText;

	private var arrows:FlxSprite;
	private var boyfriendNormal:String;
	private var boyfriendRemaster:String;
	private var boyfriendX:Int;
	private var boyfriendY:Int;

	public function new()
	{
		// FINISH TOMORROW
		switch (category)
		{
			case '玩法':
				options = [
					'下落式',
					'中置轨道',
					'幽灵按键',
					#if PLAYTEST_BUILD
					'自动演奏',
					#end
					'RESET 直接死亡',
					'漏击音效',
					'音符偏移',
					'安全帧'
				];
			case '外观':
				options = [
					'BF 新皮肤',
					'音符特效',
					'隐藏连击评级',
					'隐藏界面',
					'背景变暗'
				];
			case '性能':
				options = [
					'闪光特效',
					'特殊效果',
					'镜头抖动',
					'镜头缩放',
					'高画质'
				];
			case '窗口':
				options = [
					'窗口暂停',
					'自动暂停',
					#if !mobile
					'FPS 显示',
					#end

					#if !html5
					'帧率上限' //Apparently 120FPS isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
					#end
				];
			case '辅助':
				options = [
					'怂逼模式',
					'优化模式',
					'输入系统：',
					'清除存档'
				];
			default:
				options = ['Error'];
		}

		super();

		characterLayer = new FlxTypedGroup<Character>();
		add(characterLayer);

		grpOptions = new FlxTypedGroup<AlphabetWhite>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		//BOYFRIEND INFORMATION BECAUSE I AM LAZY
		boyfriendNormal = 'bf-menu';
		boyfriendRemaster = 'bf-menu-remaster';
		boyfriendX = 800;
		boyfriendY = 350;

		for (i in 0...options.length)
		{
			var isCentered:Bool = unselectableCheck(i);
			var optionText:AlphabetWhite = new AlphabetWhite(0, 70 * i, options[i], false, false);
			optionText.tweenType = "standard";

			if(isCentered) {
				optionText.screenCenter(X);
				optionText.xAdd = optionText.x;
			} else {
				optionText.x += 60;
				optionText.xAdd = 60;
			}

			optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(!isCentered) {
				var useCheckbox:Bool = true;
				for (j in 0...noCheckbox.length) {
					if(options[i] == noCheckbox[j]) {
						useCheckbox = false;
						break;
					}
				}

				if(useCheckbox) {
					var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, false);
					checkbox.sprTracker = optionText;
					checkboxArray.push(checkbox);
					checkboxNumber.push(i);
					add(checkbox);
				} else {
					var valueText:AttachedText = new AttachedText('0', optionText.width + 80);
					valueText.sprTracker = optionText;
					grpTexts.add(valueText);
					textNumber.push(i);
				}
			}
		}

		if (ClientPrefs.downScroll) {
			newArrows('downscroll_notes');
		} else {
			newArrows('upscroll_notes');
		}

		if (ClientPrefs.fuckyouavi) {
			//do nothing
		} else {
			if (ClientPrefs.bfreskin)
				newBoyfriend(boyfriendRemaster);
			else
				newBoyfriend(boyfriendNormal);
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		pauseText = new FlxText(50, 120, 1180, "", 32);
		pauseText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		pauseText.scrollFactor.set();
		pauseText.borderSize = 2.4;
		pauseText.alpha = 0;
		add(pauseText);

		for (i in 0...options.length) {
			if(!unselectableCheck(i)) {
				curSelected = i;
				break;
			}
		}
		changeSelection();
		reloadValues();
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			OptionsState.canDoShit = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));

			new FlxTimer().start(0.05, function(tmr:FlxTimer) close()); // add delay
		}


		var usesCheckbox = true;
		for (i in 0...noCheckbox.length) {
			if(options[curSelected] == noCheckbox[i]) {
				usesCheckbox = false;
				break;
			}
		}

		if(usesCheckbox)
		{
			if(controls.ACCEPT && nextAccept <= 0)
			{
				switch(options[curSelected]) {
					case 'FPS 显示':
						ClientPrefs.showFPS = !ClientPrefs.showFPS;
						if (Main.fpsVar != null)
							Main.fpsVar.visible = ClientPrefs.showFPS;

					case 'Watermark Icon':
						ClientPrefs.showWatermark = !ClientPrefs.showWatermark;
						if (Main.watermarkCheese != null)
							Main.watermarkCheese.visible = ClientPrefs.showWatermark;

					case '高画质':
						ClientPrefs.globalAntialiasing = !ClientPrefs.globalAntialiasing;
						OptionsState.menuBG.antialiasing = ClientPrefs.globalAntialiasing;
						arrows.antialiasing = ClientPrefs.globalAntialiasing;

						if (CharacterBoyfriend != null) {
							CharacterBoyfriend.antialiasing = ClientPrefs.globalAntialiasing;
						}

						for (item in grpOptions) {
							item.antialiasing = ClientPrefs.globalAntialiasing;
						}

						for (i in 0...checkboxArray.length) {
							var spr:CheckboxThingie = checkboxArray[i];
							if(spr != null) {
								spr.antialiasing = ClientPrefs.globalAntialiasing;
							}
						}

					case '音符特效':
						ClientPrefs.noteSplashes = !ClientPrefs.noteSplashes;

					case '闪光特效':
						ClientPrefs.flashing = !ClientPrefs.flashing;

					case 'Violence':
						ClientPrefs.violence = !ClientPrefs.violence;

					case 'Swearing':
						ClientPrefs.cursing = !ClientPrefs.cursing;

					case '下落式':
						ClientPrefs.downScroll = !ClientPrefs.downScroll;
						if (ClientPrefs.downScroll) {
							newArrows('downscroll_notes');
						} else {
							newArrows('upscroll_notes');
						}

					case '中置轨道':
						ClientPrefs.middleScroll = !ClientPrefs.middleScroll;

					case '幽灵按键':
						ClientPrefs.ghostTapping = !ClientPrefs.ghostTapping;

					case '隐藏界面':
						ClientPrefs.hideHud = !ClientPrefs.hideHud;

					case 'BF 新皮肤':
						if (!OptionsState.inPause)
						{
							ClientPrefs.bfreskin = !ClientPrefs.bfreskin;
							if (!ClientPrefs.fuckyouavi) {
								if (!ClientPrefs.bfreskin) newBoyfriend(boyfriendNormal);
								else if (ClientPrefs.bfreskin) newBoyfriend(boyfriendRemaster);
							}
						}
						else
						{
							FlxG.sound.play(Paths.sound('cancelMenu'));
						}

					case '漏击音效':
						ClientPrefs.missSounds = !ClientPrefs.missSounds;

					case '优化模式':
					    ClientPrefs.fuckyouavi = !ClientPrefs.fuckyouavi;
						if (ClientPrefs.fuckyouavi)
						{
							if (CharacterBoyfriend != null)
							{
								killBoyfriend();
							}
							//OptionsState.menuBG.alpha = 0.2;
							OptionsState.menuBG.loadGraphic(Paths.image('BLACK_AND_NOTHING_ELSE'));
							OptionsState.menuBlackShit.visible = false;
						}
						else
						{
							if (!ClientPrefs.bfreskin) newBoyfriend(boyfriendNormal);
							else if (ClientPrefs.bfreskin) newBoyfriend(boyfriendRemaster);
							//OptionsState.menuBG.alpha = 1;
							OptionsState.menuBG.loadGraphic(Paths.image('settingsmenu/menuOptions'));
							OptionsState.menuBlackShit.visible = true;
						}

					case 'RESET 直接死亡':
						ClientPrefs.resetDeath = !ClientPrefs.resetDeath;

					case '隐藏连击评级':
						ClientPrefs.comboShown = !ClientPrefs.comboShown;

					case '特殊效果':
						ClientPrefs.specialEffects = !ClientPrefs.specialEffects;

					case '镜头抖动':
						ClientPrefs.cameraShake = !ClientPrefs.cameraShake;

					case '镜头缩放':
						ClientPrefs.camZoomOut = !ClientPrefs.camZoomOut;

					case '窗口暂停':
						ClientPrefs.windowPause = !ClientPrefs.windowPause;

					case '自动暂停':
						ClientPrefs.gamePause = !ClientPrefs.gamePause;

					case '自动演奏':
						ClientPrefs.botplay = !ClientPrefs.botplay;

					case '怂逼模式':
						ClientPrefs.pussyMode = !ClientPrefs.pussyMode;
				}
				reloadValues();
				ClientPrefs.saveSettings(); //saves whenever you change an option (because like why didnt it do that before ???)

				FlxG.sound.play(Paths.sound('clickMenu'));
			}
		}
		else if (controls.ACCEPT)
		{
			if (options[curSelected] == '清除存档') {
				openSubState(new ResetPromptSubState());
				FlxG.sound.play(Paths.sound('clickMenu'));
			}
		}
		else
		{
			if(controls.UI_LEFT || controls.UI_RIGHT)
			{
				var add:Int = controls.UI_LEFT ? -1 : 1;
				var changeString:String = "changeString";

				switch (ClientPrefs.inputSystem)
				{
					case "Kade Engine":
						changeString = "Kade Engine";
					case "Psych Engine":
						changeString = "Psych Engine";
					case "Vanilla":
						changeString = "Vanilla";
				}

				if (holdTime > 0.5 || controls.UI_LEFT_P || controls.UI_RIGHT_P)
				{
					switch(options[curSelected])
					{
						case '帧率上限':
							{
								ClientPrefs.framerate += add;
								if(ClientPrefs.framerate < 60) ClientPrefs.framerate = 60;
								else if(ClientPrefs.framerate > 360) ClientPrefs.framerate = 360;

								//changed the cap back because i hate optimizing it for higher framerate lol, better than 60 fps tho ??? so whatever ratio
								// shut the fuck up past unii fuck you fuck YOU!! ! !!!

								FlxG.log.add('changed fps');

								if(ClientPrefs.framerate > FlxG.drawFramerate) {
									FlxG.updateFramerate = ClientPrefs.framerate;
									FlxG.drawFramerate = ClientPrefs.framerate;
								} else {
									FlxG.drawFramerate = ClientPrefs.framerate;
									FlxG.updateFramerate = ClientPrefs.framerate;
								}
							}
						case '音符偏移':
							{
								var mult:Int = 1;
								if(holdTime > 1.5) { //Double speed after 1.5 seconds holding
									mult = 2;
								}
								ClientPrefs.noteOffset += add * mult;
								if(ClientPrefs.noteOffset < 0) ClientPrefs.noteOffset = 0;
								else if(ClientPrefs.noteOffset > 500) ClientPrefs.noteOffset = 500;
							}
						case '背景变暗':
							{
								ClientPrefs.bgDim += add * 0.1;
								OptionsState.menuBlackShit.alpha = ClientPrefs.bgDim;
								FlxG.log.add('changed bg dim opacity');

								//Opacity set
								if(OptionsState.menuBlackShit.alpha > 0.9)
									OptionsState.menuBlackShit.alpha = 0.9;

								if (ClientPrefs.bgDim < 0.01)
									ClientPrefs.bgDim = 0;
								else if(ClientPrefs.bgDim > 0.9)
									ClientPrefs.bgDim = 0.9;
							}
						case '安全帧':
							{
								ClientPrefs.safeFrames += add;
								if(ClientPrefs.safeFrames < 1) ClientPrefs.safeFrames = 1;
								else if(ClientPrefs.safeFrames > 20) ClientPrefs.safeFrames = 20;
							}
						case '输入系统：':
							{
								// I SHOULDVE DONE THIS IN AN ARRAY FUUUCK
								switch (changeString)
								{
									case "Kade Engine":
										if (controls.UI_LEFT)
											changeString = "Vanilla";
										else if (controls.UI_RIGHT)
											changeString = "Psych Engine";
									case "Psych Engine":
										if (controls.UI_LEFT)
											changeString = "Kade Engine";
										else if (controls.UI_RIGHT)
											changeString = "Vanilla";
									case "Vanilla":
										if (controls.UI_LEFT)
											changeString = "Psych Engine";
										else if (controls.UI_RIGHT)
											changeString = "Kade Engine";
								}
								ClientPrefs.inputSystem = changeString;

								// short timer just in case it displays the wrong string (it does)
								new FlxTimer().start(0.02, function(tmr:FlxTimer) {
									ClientPrefs.inputSystem = changeString;
									FlxG.log.add('timer completed, changed string to: ' + ClientPrefs.inputSystem);
									//trace('working: ' + ClientPrefs.inputSystem);
								});
							}
					}
					reloadValues();
					ClientPrefs.saveSettings();
				}

				// BETTER THAN THE IF STATEMENT (slightly)
				var soundShouldPlay:Bool = true;

				if (options[curSelected] == '清除存档') soundShouldPlay = false;

				if (holdTime <= 0 && soundShouldPlay) FlxG.sound.play(Paths.sound('clickMenu'));
				holdTime += elapsed;
			}
			else
			{
				holdTime = 0;
			}
		}

		if(!ClientPrefs.fuckyouavi && CharacterBoyfriend != null && CharacterBoyfriend.animation.curAnim.finished) {
			CharacterBoyfriend.dance();
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = options.length - 1;
			if (curSelected >= options.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var daText:String = '';

		//DESCRIPTIONS

		switch(options[curSelected]) {
			case '帧率上限':
				daText = "游戏的每秒帧数。\n用 LEFT 和 RIGHT 键调整。";
			case '音符偏移':
				daText = "调整你的偏移量。\n可以避免无线耳机导致的音频延迟。";
			case 'FPS 显示':
				daText = "不勾选的话，隐藏 FPS 显示。";
			case 'Watermark Icon':
				daText = "不勾选的话，隐藏 VS Cheese 水印。";
			case '高画质':
				daText = "不勾选的话，关闭抗锯齿、提升性能，\n代价是画面不那么平滑。";
			case '下落式':
				daText = "勾选后音符从上往下落而不是从下往上\n适合真正的音游玩家。 B)"; // i added it back idk why it was removed B)
			case '中置轨道':
				daText = "勾选后音符轨道会居中，\n和大多数 4K 音游一样。";
			case '幽灵按键':
				daText = "勾选后，在没有音符可打的时候乱按\n不会算漏击。";
			case 'Swearing':
				daText = "不勾选的话，你妈就不会生你的气了。";
			case 'Violence':
				daText = "不勾选的话，你就不会那么频繁地感到恶心。";
			case '音符特效':
				daText = "不勾选的话，打出“完美！”就不会\n显示粒子特效。";
			case '闪光特效':
				daText = "如果你对闪光敏感，请取消勾选。";
			case '隐藏界面':
				daText = "勾选后隐藏游戏界面。";
			case 'BF 新皮肤':
				daText = "不勾选的话，BF 会用普通皮肤\n而不是默认的“重制版”皮肤。";
			case '漏击音效':
				daText = "不勾选的话，漏击时不会播放音效，\n人声也不会静音。";
			case '背景变暗':
			    daText = "用黑色遮罩调暗背景。\n用 LEFT 和 RIGHT 键调整不透明度。";
			case '优化模式':
				daText = "勾选后隐藏所有背景和角色，\n同时关闭干扰演出。";
			case '清除存档':
				daText = "警告：这会直接关闭游戏！\n按确认键清除 VS Cheese 的存档数据。";
			case 'RESET 直接死亡':
				daText = "开启后：按 RESET 键直接进入死亡画面。";
			case '隐藏连击评级':
				daText = "勾选后隐藏显示连击的评级弹窗。";
			case '特殊效果':
				daText = "不勾选的话，机制提示和视觉特效\n都会被关闭。";
			case '镜头抖动':
				daText = "不勾选的话，有镜头演出的歌里\n镜头不会抖动或移向按下的音符。";
			case '镜头缩放':
				daText = "不勾选的话，有镜头演出的歌里\n镜头不会缩放。";
			case '输入系统：':
				daText = "选择其他周五夜放克引擎的输入系统。\n用 LEFT 和 RIGHT 键调整。";
			case '窗口暂停':
				daText = "勾选后，点击窗口外会冻结游戏。";
			case '自动暂停':
				daText = "不勾选的话，歌曲进行中点击窗口外\n不会暂停游戏。";
			case '自动演奏':
				daText = "当个书呆子哈哈哈，这选项只在游戏的测试版里出现\nhi diples hi diples hi di";
			case '安全帧':
				daText = "自定义打早了或打晚了\n还有多少帧的判定宽限。";
			case '怂逼模式':
				daText = "关闭 不公平难度歌曲里的机制。";
		}
		descText.text = daText;

		// switch in case i wanna add more options that are untogglable when using the pause menu options (it is the same state/substates)
		switch (options[curSelected])
		{
			case 'BF 新皮肤':
				if (OptionsState.inPause)
					pauseText.alpha = 1;
				else
					pauseText.alpha = 0;
			default:
				pauseText.alpha = 0;
		}
		pauseText.text = "这个选项不能在暂停菜单里改动。\n请到主菜单的选项里调整。";

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.2;
				if (item.targetY == 0) {
					item.alpha = 1;
				}

				for (j in 0...checkboxArray.length) {
					var tracker:FlxSprite = checkboxArray[j].sprTracker;
					if(tracker == item) {
						checkboxArray[j].alpha = item.alpha;
						break;
					}
				}
			}
		}
		for (i in 0...grpTexts.members.length) {
			var text:AttachedText = grpTexts.members[i];
			if(text != null) {
				text.alpha = 0.2;
				if(textNumber[i] == curSelected) {
					text.alpha = 1;
				}
			}
		}
		buttonSound(change != 0);
	}

	function reloadValues() {
		for (i in 0...checkboxArray.length) {
			var checkbox:CheckboxThingie = checkboxArray[i];
			if(checkbox != null) {
				var daValue:Bool = false;
				switch(options[checkboxNumber[i]]) {
					case 'FPS 显示':
						daValue = ClientPrefs.showFPS;
					case 'Watermark Icon':
						daValue = ClientPrefs.showWatermark;
					case '高画质':
						daValue = ClientPrefs.globalAntialiasing;
					case '音符特效':
						daValue = ClientPrefs.noteSplashes;
					case '闪光特效':
						daValue = ClientPrefs.flashing;
					case '下落式':
						daValue = ClientPrefs.downScroll;
					case '中置轨道':
						daValue = ClientPrefs.middleScroll;
					case '幽灵按键':
						daValue = ClientPrefs.ghostTapping;
					case 'Swearing':
						daValue = ClientPrefs.cursing;
					case 'Violence':
						daValue = ClientPrefs.violence;
					case '隐藏界面':
						daValue = ClientPrefs.hideHud;
					case 'BF 新皮肤':
						daValue = ClientPrefs.bfreskin;
					case '漏击音效':
						daValue = ClientPrefs.missSounds;
					case '优化模式':
						daValue = ClientPrefs.fuckyouavi;
					case 'RESET 直接死亡':
						daValue = ClientPrefs.resetDeath;
					case '隐藏连击评级':
						daValue = ClientPrefs.comboShown;
					case '特殊效果':
						daValue = ClientPrefs.specialEffects;
					case '镜头抖动':
						daValue = ClientPrefs.cameraShake;
					case '镜头缩放':
						daValue = ClientPrefs.camZoomOut;
					case '窗口暂停':
						daValue = ClientPrefs.windowPause;
					case '自动暂停':
						daValue = ClientPrefs.gamePause;
					case '自动演奏':
						daValue = ClientPrefs.botplay;
					case '怂逼模式':
						daValue = ClientPrefs.pussyMode;
				}
				checkbox.daValue = daValue;
			}
		}
		for (i in 0...grpTexts.members.length) {
			var text:AttachedText = grpTexts.members[i];
			if(text != null) {
				var daText:String = '';
				switch(options[textNumber[i]]) {
					case '帧率上限':
						daText = '' + ClientPrefs.framerate;
					case '音符偏移':
						daText = ClientPrefs.noteOffset + 'ms';
					case '背景变暗':
						daText = Math.round(ClientPrefs.bgDim * 100) + '%';
					case '安全帧':
						daText = '' + ClientPrefs.safeFrames;
					case '输入系统：':
						daText = ClientPrefs.inputSystem;
				}
				var lastTracker:FlxSprite = text.sprTracker;
				text.sprTracker = null;
				text.changeText(daText);
				text.sprTracker = lastTracker;
			}
		}
	}

	private function unselectableCheck(num:Int):Bool {
		for (i in 0...unselectableOptions.length) {
			if(options[num] == unselectableOptions[i]) {
				return true;
			}
		}
		return options[num] == '';
	}

	private function newBoyfriend(character:String) {
		if (CharacterBoyfriend != null) {
			characterLayer.remove(CharacterBoyfriend);
		}
		CharacterBoyfriend = new Character(boyfriendX, boyfriendY, character, true);
		CharacterBoyfriend.setGraphicSize(Std.int(CharacterBoyfriend.width * 0.65));
		CharacterBoyfriend.dance();
		characterLayer.add(CharacterBoyfriend);
	}

	private function killBoyfriend():Void {
		if (CharacterBoyfriend != null)
			characterLayer.remove(CharacterBoyfriend);
	}

	private function newArrows(scrollPref:String) {
		if (arrows != null) {
			remove(arrows);
		}
		arrows = new FlxSprite().loadGraphic(Paths.image('settingsmenu/' + scrollPref));
		arrows.setGraphicSize(Std.int(arrows.width * 1.1));
		arrows.screenCenter();
		arrows.antialiasing = ClientPrefs.globalAntialiasing;
		add(arrows);
	}

	private function buttonSound(?playSound:Bool = true) {
		if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	private function traceLog(log:String) {
		FlxG.log.add(log);
	}
}