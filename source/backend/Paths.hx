package backend;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
import openfl.geom.Rectangle;
import lime.utils.Assets;
import flash.media.Sound;
import tjson.TJSON as Json;

import backend.types.MusicMetadata;

class Paths {
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	public static var dumpExclusions:Array<String> = [];

	public static function clearUnusedMemory() {
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key)) {
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null) {
					// remove the key from all cache maps
					FlxG.bitmap._cache.remove(key);
					openfl.Assets.cache.removeBitmapData(key);
					currentTrackedAssets.remove(key);

					// and get rid of the object
					obj.persist = false; // make sure the garbage collector actually clears it up
					obj.destroyOnNoUse = true;
					obj.destroy();
				}
			}
		}

		// run the garbage collector for good measure lmfao
		System.gc();
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];

	public static function clearStoredMemory() {
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys()) {
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key)) {
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached
		for (key => asset in currentTrackedSounds) {
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null) {
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
	}


	public static function getPath(file:String, ?library:Null<String> = null):String {
		if (library != null)
			return 'assets/$library/$file';

		return 'assets/$file';
	}

	public static function getImagePath(file:String, ?library:Null<String> = null):String {
		return getPath('images/' + file + '.png', library);
	}

	public static function appendSoundExt(file:String):String {
		return file + '.$SOUND_EXT';
	}

	public static function getSparrowXmlPath(file:String, ?library:Null<String> = null):String {
		return getPath('images/' + file + '.xml', library);
	}

	static public function sound(key:String, ?library:String):Sound {
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String) {
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Sound {
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	inline static public function musicMetadata(tag:String):MusicMetadata {
		var usedTag:String = tag;
		if (Preferences.data.useClassicMusic && Paths.fileExists(Paths.appendSoundExt('music/classic/' + tag), SOUND)) {
			usedTag = 'classic/' + tag;
		}

		var json:MusicMetadata = null;
		var rawJson = getTextFromFile('music/' + usedTag + '.json');
		if (rawJson != null) {
			json = cast Json.parse(rawJson);
		}
		return json;
	}

	public static function json(file:String, ?library:Null<String> = null):String {
		return getPath('data/' + file + '.json', library);
	}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];

	static public function image(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxGraphic {
		var bitmap:BitmapData = null;
		var file:String = null;

		file = getPath('images/$key.png', library);
		#if sys
		if (FileSystem.exists(file))
			bitmap = BitmapData.fromFile(file);
		else
		#end
		{
			if (currentTrackedAssets.exists(file)) {
				localTrackedAssets.push(file);
				return currentTrackedAssets.get(file);
			} else if (OpenFlAssets.exists(file, IMAGE))
				bitmap = OpenFlAssets.getBitmapData(file);
		}

		if (bitmap != null) {
			var retVal = cacheBitmap(file, bitmap, allowGPU);
			if (retVal != null)
				return retVal;
		}

		trace('Image does not exist: [$file]');
		return null;
	}

	static public function cacheBitmap(file:String, ?bitmap:BitmapData = null, ?allowGPU:Bool = true) {
		if (bitmap == null) {
			#if sys
			if (FileSystem.exists(file))
				bitmap = BitmapData.fromFile(file);
			else
			#end
			{
				if (OpenFlAssets.exists(file, IMAGE))
					bitmap = OpenFlAssets.getBitmapData(file);
			}
		}

		localTrackedAssets.push(file);
		#if !html5
		if (allowGPU && Preferences.data.cacheOnGPU) {
			var texture:RectangleTexture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
			texture.uploadFromBitmapData(bitmap);
			bitmap.image.data = null;
			bitmap.dispose();
			bitmap.disposeImage();
			bitmap = BitmapData.fromTexture(texture);
		}
		#end
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
		currentTrackedAssets.set(file, newGraphic);
		return newGraphic;
	}

	static public function getTextFromFile(key:String):String {
		var path = getPath(key);
		#if sys
		if (FileSystem.exists(path))
			return File.getContent(path);
		#end
		if (OpenFlAssets.exists(path, TEXT))
			return Assets.getText(path);
		return null;
	}

	inline static public function font(key:String) {
		return getPath('fonts/$key.ttf');
	}

	public static function fileExists(key:String, type:AssetType, ?library:String = null) {
		var path = getPath(key, library);
		#if sys
		if (FileSystem.exists(path)) {
			return true;
		}
		#end
		if (OpenFlAssets.exists(path, type)) {
			return true;
		}
		return false;
	}

	inline static public function sparrowAtlas(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(image(key, library, allowGPU), getSparrowXmlPath(key, library));
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static function returnSound(path:String, key:String, ?library:String) {
		var gottenPath:String = appendSoundExt(getPath('$path/$key', library));
		#if sys
		if (FileSystem.exists(gottenPath)) {
			if (!currentTrackedSounds.exists(gottenPath)) {
				currentTrackedSounds.set(gottenPath, Sound.fromFile(gottenPath));
			}
			localTrackedAssets.push(key);
			return currentTrackedSounds.get(gottenPath);
		}
		#end
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		if (!currentTrackedSounds.exists(gottenPath))
			#if sys
			currentTrackedSounds.set(gottenPath, Sound.fromFile(gottenPath));
			#else
			{
				currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(Paths.getPath(appendSoundExt('$path/$key'))));
			}
			#end
			localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}
}
