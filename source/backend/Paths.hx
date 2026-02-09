package backend;

import backend.types.MusicMetadata;
import backend.Addons;
import flash.media.Sound;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
import openfl.geom.Rectangle;
import tjson.TJSON as Json;

/**
 * List of functions for getting assets.
 */
class Paths {
	/**
	 * The current used extension for sounds.
	 */
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	/**
	 * List of directories to be ignored during memory clearing.
	 */
	public static var dumpExclusions:Array<String> = [];

	/**
	 * Preload belly sounds to memory to prevent crashes and lag spikes.
	 */
	public static function precacheBellySounds() {
		for (i in 1...Constants.CREAKS_SAMPLE_COUNT + 1) {
			var key:String = 'belly/creaks/creak_' + i;
			precacheSound(key);
		}
		for (i in 1...Constants.GURGLES_SAMPLE_COUNT + 1) {
			var key:String = 'belly/gurgles/gurgle_' + i;
			precacheSound(key);
		}
		for (i in 1...Constants.BELCHES_SAMPLE_COUNT + 1) {
			var key:String = 'belly/belches/belch_' + i;
			precacheSound(key);
		}
		for (i in 1...Constants.FWOOMPS_SAMPLE_COUNT + 1) {
			var key:String = 'belly/fwoomps/fwoompLarge_' + i;
			precacheSound(key);
			key = 'belly/fwoomps/fwoompSmall_' + i;
			precacheSound(key);
		}
		precacheSound('belly/burst');
		trace('All belly sounds precached!');
	}

	public static function precacheSound(key:String) {
		if (!localTrackedAssets.contains(key)) {
			Paths.sound(key);
		}
	}

	/**
	 * Clear stored assets in memory that is currently not used.
	 */
	public static function clearUnusedMemory() {
		// clear non local assets in the tracked assets list
		for (key in currentTrackedTextures.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key)) {
				var obj = currentTrackedTextures.get(key);
				@:privateAccess
				if (obj != null) {
					// remove the key from all cache maps
					FlxG.bitmap._cache.remove(key);
					openfl.Assets.cache.removeBitmapData(key);
					currentTrackedTextures.remove(key);

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

	/**
	 * List of locally tracked assets.
	 */
	public static var localTrackedAssets:Array<String> = [];

	/**
	 * Clear all assets not in the tracked assets list.
	 */
	public static function clearStoredMemory() {
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys()) {
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedTextures.exists(key)) {
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

	/**
	 * Convert a relative directory to a directory in the `assets` folder.
	 * 
	 * @param file
	 * @param library
	 */
	public static function getPath(file:String, ?library:Null<String> = null):String {
		if (library != null)
			return 'assets/$library/$file';

		return 'assets/$file';
	}

	/**
	 * Convert a relative image directory to a directory in the `assets/images` folder.
	 * 
	 * @param file
	 * @param library
	 */
	public static function getImagePath(file:String, ?library:Null<String> = null):String {
		#if _ALLOW_ADDONS
		var key = addonFolders('images/' + file + '.png');
		if (key != null)
			return key;
		#end
		return getPath('images/' + file + '.png', library);
	}

	/**
	 * Add the sound extention string to the end of a directory.
	 * 
	 * @param file
	 */
	public static function appendSoundExt(file:String):String {
		return file + '.$SOUND_EXT';
	}

	inline public static function readDirectories(path:String, listPath:String = '', fileFormat:String = '', addons:Bool = true) {
		var pathsInFolder:Array<String> = Utils.textFileToArray(listPath);
		#if sys
		// Main folder
		if (FileSystem.exists(Paths.getPath(path))) {
			for (i in FileSystem.readDirectory(Paths.getPath(path))) {
				var item = i.replace('.$fileFormat', '');
				if (!pathsInFolder.contains(item) && !FileSystem.isDirectory(Paths.getPath(path + '/' + i)))
					pathsInFolder.push(item);
			}
		}

		#if _ALLOW_ADDONS
		if (addons) {
			for (addon in Addons.getGlobalAddons()) {
				if (FileSystem.exists(Paths.addons(addon + '/' + path))) {
					for (i in FileSystem.readDirectory(Paths.addons(addon + '/' + path))) {
						var item = i.replace('.$fileFormat', '');
						if (!pathsInFolder.contains(item) && !FileSystem.isDirectory(Paths.addons(addon + '/' + path + '/' + i)))
							pathsInFolder.push(item);
					}
				}
			}
		}
		#end
		#else
		for (num => item in pathsInFolder) {
			pathsInFolder[num] = item.replace('.$fileFormat', '');
		}
		#end
		return pathsInFolder;
	}

	/**
	 * Find the XML file for a Sparrow v2 spritesheet.
	 * 
	 * @param file
	 * @param library
	 */
	public static function getSparrowXmlPath(file:String, ?library:Null<String> = null):String {
		#if _ALLOW_ADDONS
		var key = addonFolders('images/' + file + '.xml');
		if (key != null)
			return key;
		#end
		return getPath('images/' + file + '.xml', library);
	}

	/**
	 * Return a Sound in the `sounds/` folder.
	 * 
	 * @param key The filename of the sound.
	 * @param library
	 */
	static public function sound(key:String, ?library:String):Sound {
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	/**
	 * Return a Sound with variations in the `sounds/` folder.
	 * 
	 * @param key The base filename of the sound.
	 * @param min The minimum suffix value.
	 * @param max The maximum suffix value.
	 * @param library
	 */
	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String) {
		return sound(key + '_' + FlxG.random.int(min, max), library);
	}

	/**
	 * Return a Sound in the `music/` folder.
	 * 
	 * @param key The filename of the music.
	 * @param library
	 */
	inline static public function music(key:String, ?library:String):Sound {
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	/**
	 * Return a MusicMetadata of a song in the `music/` folder by accessing its JSON metadata file.
	 * 
	 * @param tag The filename of the music.
	 */
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

	/**
	 * The list of textures stored in memory for quick access.
	 */
	public static var currentTrackedTextures:Map<String, FlxGraphic> = [];

	/**
	 * Returns a FlxGraphic in the `images/` folder.
	 * 
	 * @param key The directory of the image in the `images/` folder.
	 * @param library
	 * @param allowGPU Whether to allow VRAM to store this image or not.
	 */
	static public function image(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxGraphic {
		var bitmap:BitmapData = null;
		var file:String = null;

		#if _ALLOW_ADDONS
		file = addonsImages(key);
		if (currentTrackedTextures.exists(file)) {
			localTrackedAssets.push(file);
			return currentTrackedTextures.get(file);
		} else if (FileSystem.exists(file))
			bitmap = BitmapData.fromFile(file);
		else
		#end

		file = getPath('images/$key.png', library);
		#if sys
		if (FileSystem.exists(file))
			bitmap = BitmapData.fromFile(file);
		else
		#end
		{
			if (currentTrackedTextures.exists(file)) {
				localTrackedAssets.push(file);
				return currentTrackedTextures.get(file);
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

	/**
	 * Stores a texture into memory.
	 * 
	 * @param file The directory of the image in the `images/` folder.
	 * @param bitmap The bitmap data to be stored.
	 * @param allowGPU Whether to allow VRAM to be used or not.
	 */
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
		#if desktop
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
		currentTrackedTextures.set(file, newGraphic);
		return newGraphic;
	}

	/**
	 * Reads a text file's contents, then converts it to a String.
	 * 
	 * @param key The directory of the text file.
	 */
	static public function getTextFromFile(key:String):String {
		var path = getPath(key);
		#if sys
		#if _ALLOW_ADDONS
		if (FileSystem.exists(addonFolders(key)))
			return File.getContent(addonFolders(key));
		#end
		if (FileSystem.exists(path))
			return File.getContent(path);
		#end

		trace(path);
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

	/**
	 * Returns a Sparrow v2 Altas to be used for animations for sprites.
	 * 
	 * @param key The directory of both the image and XML file.
	 * @param library
	 * @param allowGPU Whether to allow VRAM to store the texture altas or not.
	 */
	inline static public function sparrowAtlas(key:String, ?library:String = null, ?allowGPU:Bool = true):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(image(key, library, allowGPU), getSparrowXmlPath(key, library));
	}

	/**
	 * Map of Sounds that is stored in memory.
	 */
	public static var currentTrackedSounds:Map<String, Sound> = [];

	/**
	 * Returns a Sound by its directory.
	 * 
	 * @param path The directory.
	 * @param key The name to be assigned for the sound for quick access.
	 * @param library
	 */
	public static function returnSound(path:String, key:String, ?library:String) {
		var gottenPath:String = appendSoundExt(getPath('$path/$key', library));

		#if _ALLOW_ADDONS
		var addonLibPath:String = '';
		if (library != null)
			addonLibPath = '$library/';
		if (path != null)
			addonLibPath += '$path';

		var file:String = addonsSounds(addonLibPath, key);
		if (FileSystem.exists(file)) {
			if (!currentTrackedSounds.exists(file)) {
				currentTrackedSounds.set(file, Sound.fromFile(file));
			}
			localTrackedAssets.push(file);
			return currentTrackedSounds.get(file);
		}
		#end

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

	#if _ALLOW_ADDONS
	inline static public function addons(key:String = '') {
		return 'addons/' + key;
	}

	inline static public function addonsSounds(path:String, key:String) {
		return addonFolders(path + '/' + key + '.' + SOUND_EXT);
	}

	inline static public function addonsImages(key:String) {
		return addonFolders('images/' + key + '.png');
	}

	static public function addonFolders(key:String) {
		for (addon in Addons.getGlobalAddons()) {
			var fileToCheck:String = addons(addon + '/' + key);
			if (FileSystem.exists(fileToCheck))
				return fileToCheck;
		}
		return null;
	}
	#end
}
