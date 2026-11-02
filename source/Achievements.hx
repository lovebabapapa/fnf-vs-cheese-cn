import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class Achievements
{
	// for achievements
	public static var achievementsStuff:Array<Dynamic> = [
		//Name, 						 Description, 			 																	 Achievement save tag, 	 Hide?

		["周五夜放克狂热",	"在周五晚上玩本游戏。",																	'friday_night_play',	 true],
		["回到基础",			"完成教学关。",																		'tutorial_beat', 		false],

		// WEEKS
		["你有文化吗？", 			"以困难难度通关第一周。",																		'week1_beat', 			false],
		["前传？",					"以困难难度通关第二周。",																		'week2_beat',			false],
		["兄弟们",					"和 Unii 合唱并达成第二周的\n正史结局",										'dynamic_duo',			false],
		["总感觉少了什么...",		"拒绝 Unii 并达成第二周的\n另一结局。",									'below_zero',			false],

		// VIP DIFFICULTY
		["即兴时刻！", 			"以 VIP 难度通关 Restaurante。",														'restaurante_ex',		false],
		["换个花样！", 		"以 VIP 难度通关 Milkshake。",														'milkshake_ex',		 	false],
		["你还不够有文化！",	"以 VIP 难度通关 Cultured。", 														'cultured_ex',			false],

		// EXTRA ACHIEVEMENTS
		["余兴派对",					"玩过全部附赠曲和 VIP 混音版。",													'beat_bonus',			false],
		["狂妄自大", 				"开启机制通关 Manager Strike Back。",												'beat_chara',			 true],
		["随它吧",	 				"开启机制通关 Frosted。",															'beat_sans',			 true],
		["癫狂",	 					"开启机制通关 Alter Ego。",														'beat_unii',			 true],
		["我卡了！",				"开启机制通关 Relinquish。",														'beat_arsen',			 true],

		["Fucking Cheater...",  		UniiStringTools.potionionsMessage(), 														'beat_onion', 			 true], //made cleaner, look in UniiStringTools.hx for info!

		["Cerbera",						"在谱面编辑器里放置一个音符。",														'charter', 				false],
		["好可爱的小家伙 <3",		"在主菜单摸摸 Cheese 的头。",															'scrunkly',				false], //i added a heart here fuck u lol it looks cute <33
		["考据大师",					"你他妈是主播吧？！\n任何形式的跳过对话都不行。",			'evil_woops',			false],

		// OG RENAMED

		["L + Ratio",					"以低于 20% 的准确率完成一首歌。",													'ur_bad',				false],
		["完美无缺",					"以 100% PFC 全连完成一首歌。",											'ur_good',				false],
		["又长又硬", 				"按住一个音符至少 5 秒。\n名字？不知道你在说什么...", 		'oversinging', 			false],
		["SCP-173",						"不要眨眼。\n（不进入待机动画完成一首歌。）",										'hype',					false],
		["二人组合",					"只用两个按键完成一首歌。",													'two_keys',				false],
		["Mac 用户",					"你试过用烤面包机跑这游戏吗？",												'toastie',				false],

		// SECRET
		["幽灵发声", 		"嘿兄弟们是我幽灵 ORU！真的！我是真的！",											'beat_ghost',			 true],
		["黑客",						"01100011 01100001 01101101 01100101 01101111", 											'beat_diples', 			 true],
		["肺衰竭", 				"这梗真他妈不好笑了。",													'beat_ralsei',			 true]
	];

	// for unlocks/notifications
	public static var notifStuff:Array<Dynamic> = [
		//Header, 						 Subtitle,	 			 							 Save tag, 	 			Hide?
		["嘿...", 					"你在故事模式里解锁了第一周！",				'unlock_week1',			true],
		["嘿...", 					"你在自由模式里解锁了 VIP 难度！",			'unlock_ex',			true],
		["嘿...", 					"你在故事模式里解锁了第二周！",				'unlock_week2',			true],
		["嘿...", 					"你在故事模式里解锁了附赠内容！",		'unlock_bonus',			true],
		["嘿...", 					"你在自由模式里解锁了附赠歌曲！",		'unlock_endgame',		true],
	];

	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();

	public static function unlockAchievement(name:String):Void {
		FlxG.log.add('Completed achievement "' + name +'"');
		achievementsMap.set(name, true);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}

	public static function isAchievementUnlocked(name:String) {
		if(achievementsMap.exists(name) && achievementsMap.get(name)) {
			return true;
		}
		return false;
	}

	public static function getAchievementIndex(name:String, ?type:String = 'achievement') {
		var typeList:Array<Dynamic> = [];

		switch (type)
		{
			case 'achievement':
				typeList = achievementsStuff;
			case 'notification':
				typeList = notifStuff;
		}

		for (i in 0...typeList.length) {
			if(typeList[i][2] == name) {
				return i;
			}
		}
		return -1;
	}

	public static function loadAchievements():Void {
		if(FlxG.save.data.achievementsMap != null) {
			achievementsMap = FlxG.save.data.achievementsMap;
		}
		if(FlxG.save.data.achievementsUnlocked != null) {
			FlxG.log.add("Trying to load stuff");
			var savedStuff:Array<String> = FlxG.save.data.achievementsUnlocked;
			for (i in 0...savedStuff.length) {
				achievementsMap.set(savedStuff[i], true);
			}
		}

		// DOESNT SAVE UNNECECARY STUFF >:(
	}
}
