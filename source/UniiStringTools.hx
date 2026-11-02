package;

import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.display.BlendMode;
import flixel.util.FlxSort;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

/**
 * this isnt only used for string tools i lied :3 
 * hehe
 * @author uniimations
 */

class UniiStringTools
{
    // FC TYPES - ALSO I CHANGED IT TO SFC NOW BECAYUSE PSYCH ENGINE OMGG
    public static function makePlayRanks(misses:Int, shits:Int, bads:Int, goods:Int, sicks:Int, perfectMarvelous:Int) // generate a letter ranking
    {
        var rankString:String = "N/A";

        if (misses == 0 && shits == 0 && bads == 0 && goods == 0 && sicks == 0 && perfectMarvelous >= 1)
            rankString = 'PFC'; //no shits, bads, or sicks, only perfect
        else if (misses == 0 && shits == 0 && bads == 0 && goods == 0 && sicks >= 1)
            rankString = 'SFC'; //no shits or bads, only sick and above
        else if (misses == 0 && shits == 0 && bads == 0 && goods >= 1)
            rankString = 'GFC'; //no shits or bads, only goods and above
        else if (misses == 0)
            rankString = 'FC'; //standard fc
        else if (misses <= 10)
            rankString = 'SDCB'; //under 10 misses
        else if (misses >= 11)
            rankString = 'clear'; //anything else

        return rankString;
    }

    // NOTE SKIN SUFFIX
    public static function noteSkinSuffix(characterString:String)
    {
        var note_skin_suffix:String = '';

        switch (characterString)
        {
            case 'bluecheese' | 'vip-bluecheese':
                note_skin_suffix = '_CHEESE';
            case 'avinera-frosted-tape' | 'avinera-frosted':
                note_skin_suffix = '_AVINERA';
            case 'bluecheese-and-suzuki':
                note_skin_suffix = '_SUZUCHEESE';
            case 'unii':
                note_skin_suffix = '_UNII';
            case 'diples-cubed':
                note_skin_suffix = '_DIPLES';
            case 'relinquish-arsen':
                note_skin_suffix = '_ARSEN';
            case 'b3-cheese':
                note_skin_suffix = '_B3';
            case 'arrow-funk-cheese':
                note_skin_suffix = '_AF';
            case 'bs-cheese':
                note_skin_suffix = '_UT';
            default:
                note_skin_suffix = '';
        }

        // the string it will return for the note skin path
        return note_skin_suffix;
    }

    public static function checkAnimFinish(object:FlxSprite, introAnim:String, idleAnim:String)
    {
        if (object.animation.curAnim != null)
        {
            if (object.animation.curAnim.name == introAnim && object.animation.curAnim.finished)
            {
                new FlxTimer().start(0.1, function(tmr: FlxTimer)
                {
                    object.animation.play(idleAnim);
                });
            }
        }
    }

    public static function getLuaStage(stage:String):LuaStage
    {
		var rawJson:String = null;
		var path:String = Paths.mods('stages/' + stage + '.json');

		if(FileSystem.exists(path))
        {
			rawJson = File.getContent(path);
		}
		else
		{
			return null;
		}
		return cast Json.parse(rawJson);
	}

    public static function potionionsMessage() {
		var returnTxt = "你作弊坑到的不只是游戏，还有你自己。你没有成长，没有进步。你走了捷径，却一无所获。你经历的是一场空洞的胜利。没有风险，也没有收获。可悲的是你连这都分不清。";

		return returnTxt;
	}

    // i added blend modes!! ^_^
    public static function getBlend(blend:String):BlendMode {
		switch(blend.toLowerCase().trim()) {
			case 'add': return ADD;
			case 'alpha': return ALPHA;
			case 'darken': return DARKEN;
			case 'difference': return DIFFERENCE;
			case 'erase': return ERASE;
			case 'hardlight': return HARDLIGHT;
			case 'invert': return INVERT;
			case 'layer': return LAYER;
			case 'lighten': return LIGHTEN;
			case 'multiply': return MULTIPLY;
			case 'overlay': return OVERLAY;
			case 'screen': return SCREEN;
			case 'shader': return SHADER;
			case 'subtract': return SUBTRACT;
		}
		return NORMAL;
	}

    // FOR CHEESEBONE CREMA CHEESE !!
    public static function loadMappedAnims(anims_to_map:Array<Dynamic>, chart:String, song_folder:String)
	{
		var chartData:SwagSong = Song.loadFromJson(chart, song_folder);

		var noteDaata = chartData.notes;

		for (section in noteDaata)
		{
			for (songNotes in section.sectionNotes)
			{
				anims_to_map.push(songNotes);
			}
		}

		anims_to_map.sort(sortAnims);
	}

    // new song name function
    public static function generateSongName(song_name:String)
    {
        var swagShit:String = '';

        switch (song_name) {
            // 汉化注意：这里绝对不能把多首歌合并成一条「兜底 case」放在前面。
            // Haxe 的 switch 从上往下匹配，先命中的那条会把后面同名的 case 全变成死代码
            // （之前 12 首歌的中文名就是这么整批丢掉的，显示成 "Casual Duel" 这种）。
            case 'Restaurante':
                swagShit = 'Restaurante(餐厅)';
            case 'Milkshake':
                swagShit = 'Milkshake(奶昔)';
            case 'Cultured':
                swagShit = 'Cultured(有文化)';
            case 'Frosted':
                swagShit = 'Frosted(霜冻)';
            case 'Alter-Ego':
                swagShit = 'Alter-Ego(另一面)';
            case 'Articulation':
                swagShit = 'Articulation(吐字)';
            case 'Below-Zero':
                swagShit = 'Below-Zero(零下)';
            case 'Above-Zero':
                swagShit = 'Above-Zero(零上)';
            case 'Casual-Duel':
                swagShit = 'Casual-Duel(休闲对决)';
            case 'CREAM-CHEESE' | 'CREAM CHEESE': // 谱面 json 里实际写的是带空格的 "CREAM CHEESE"
                swagShit = 'CREAM CHEESE(奶油芝士)';
            case 'Cultured-Classic':
                swagShit = 'Cultured-Classic(有文化·经典)';
            case 'Cultured-Parents-Mix':
                swagShit = 'Cultured-Parents-Mix(有文化·家长版)';
            case 'DIRTY-CHEATER':
                swagShit = 'DIRTY-CHEATER(肮脏作弊者)';
            case 'Disc-Scratch':
                swagShit = 'Disc-Scratch(搓碟)';
            case 'Dynamic-Duo':
                swagShit = 'Dynamic-Duo(活力二人组)';
            case 'Manager-Strike-Back':
                swagShit = 'Manager-Strike-Back(店长反击战)';
            case 'Milkshake-Arrow-Funk':
                swagShit = 'Milkshake-Arrow-Funk(奶昔·按键狂热)';
            case 'Milkshake-Classic':
                swagShit = 'Milkshake-Classic(奶昔·经典)';
            case 'Milkshake-Pico-Mix':
                swagShit = 'Milkshake-Pico-Mix(奶昔·Pico版)';
            case 'Mozzarella':
                swagShit = 'Mozzarella(马苏里拉)';
            case 'Relinquish':
                swagShit = 'Relinquish(放手)';
            case 'Restaurante-Classic':
                swagShit = 'Restaurante-Classic(餐厅·经典)';
            case 'Restaurante-D-Side':
                swagShit = 'Restaurante-D-Side(餐厅·D侧)';
            case 'Restaurante-Senpai-Mix':
                swagShit = 'Restaurante-Senpai-Mix(餐厅·Senpai版)';
            case 'Tutorial':
                swagShit = 'Tutorial(教学)';
            case 'Wi-Fi':
                swagShit = 'Wi-Fi(无线网)';
            case 'Fat-Blunt':
                swagShit = 'Fat-Blunt(胖烟卷)';
            case 'Cultured-B':
                swagShit = 'Cultured-B(有文化·B3)';
            case 'dot-lua':
                swagShit = '.lua';
            default:
                swagShit = song_name;
        }

        return swagShit;
    }

    // taken from CharacterEditorState.hx, but modified.
    public static function randomMusic():String
	{
		var trackPlaying = '';
		var menuMusicChance = FlxG.random.int(0, 6);

		switch (menuMusicChance) //lil menu music jingle to keep you   n o t   b o r e d .
		{
			case 0:
				trackPlaying = 'Restaurante';
			case 1:
				trackPlaying = 'Milkshake';
			case 2:
				trackPlaying = 'Cultured';
			case 3:
				trackPlaying = 'Wi-Fi';
			case 4:
				trackPlaying = 'Casual-Duel';
			case 5:
				trackPlaying = 'Below-Zero';
			case 6:
				trackPlaying = 'Cream-Cheese';
            case 7:
                trackPlaying = 'Mozzarella';
		}

		return trackPlaying;
	}

	public static function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);
	}
}

typedef LuaStage = {
    var stage:String;
	var defaultZoom:Float;
    var staticZoom:Float;
    var combo:Array<Int>;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
}