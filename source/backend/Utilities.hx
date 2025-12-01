package backend;

import flixel.util.FlxSort;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import openfl.Lib;

class Utilities {
	inline public static function insideOfSprite(target:FlxSprite, boundary:FlxSprite):Bool {
		return (target.x - boundary.x >= 0
			&& target.x - boundary.x + target.width <= boundary.width
			&& target.y - boundary.y >= 0
			&& target.y - boundary.y + target.height <= boundary.height);
	}

	public static function angleBetweenPoints(SpriteA:Array<Float>, SpriteB:Array<Float>, AsDegrees:Bool = true):Float {
		var dx:Float = (SpriteB[0]) - (SpriteA[0]);
		var dy:Float = (SpriteB[1]) - (SpriteA[1]);

		if (AsDegrees)
			return Math.atan2(dy, dx) * Constants.TO_DEGREES;
		else
			return Math.atan2(dy, dx);
	}

	inline public static function textFileToArray(path:String):Array<String> {
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		var formatted:Array<String> = path.split(':');
		path = formatted[formatted.length - 1];
		if (FileSystem.exists(path))
			daList = File.getContent(path);
		#else
		if (Assets.exists(path))
			daList = Assets.getText(path);
		#end
		var leList:Array<String> = listFromString(daList);
		if (leList[leList.length - 1] == '') {
			leList.pop();
		}
		return leList;
	}

	inline public static function listFromString(string:String):Array<String> {
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	public static function distanceBetweenPoints(SpriteA:Array<Float>, SpriteB:Array<Float>):Float {
		return Math.sqrt(Math.pow(SpriteB[0] - SpriteA[0], 2) + Math.pow(SpriteB[1] - SpriteA[1], 2));
	}

	inline public static function invLerp(a:Float, b:Float, v:Float):Float {
		return (v - a) / (b - a);
	}

	inline public static function capitalize(text:String)
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function floorDecimal(value:Float, decimals:Int):Float {
		if (decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;

		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	public static function formatBytes(Bytes:Float, Precision:Int = 2):String {
		var units:Array<String> = ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB", "RiB", "QiB"];
		var curUnit = 0;
		while (Bytes >= 1024 && curUnit < units.length - 1) {
			Bytes /= 1024;
			curUnit++;
		}
		return FlxMath.roundDecimal(Bytes, Precision) + ' ' + units[curUnit];
	}

	inline public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
	
	inline public static function getSavePath():String {
		@:privateAccess
		return FlxG.stage.application.meta.get('company') + '/' + FlxG.stage.application.meta.get('file');
	}

	public static function dashToSpace(string:String):String {
		return string.replace("-", " ");
	}

	public static function spaceToDash(string:String):String {
		return string.replace(" ", "-");
	}

    public static inline function centerWindowOnPoint(?point:FlxPoint) {
		Lib.application.window.x = Std.int(point.x - (Lib.application.window.width / 2));
		Lib.application.window.y = Std.int(point.y - (Lib.application.window.height / 2));
	}

	static final whitespace = ~/(?<=\r|\s|^)([a-z])/g;
	public static function capitalizeFirstLetters(str:String):String {
		return whitespace.map(str, (r) -> r.matched(0).toUpperCase());
	}

    public static inline function getCenterWindowPoint():FlxPoint {
		return FlxPoint.get(
			Lib.application.window.x + (Lib.application.window.width / 2),
			Lib.application.window.y + (Lib.application.window.height / 2)
		);
	}
}
