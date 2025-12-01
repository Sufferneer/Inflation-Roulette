package backend;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import states.MainMenuState;
import openfl.text.TextFormat;
import lime.ui.Window;
import lime.system.DisplayMode;

// Add a variable here and it will get automatically saved
class SaveVariables {
	public var framerate:Int = 60;
	public var pauseOnUnfocus:Bool = false;
	public var allowPopping:Bool = true;
	public var ignoreEliminatedPlayers:Bool = false;
	public var enableDebugMode:Bool = false;
	public var photosensitivity:Bool = false;
	public var cameraEffectIntensity:Float = 1;
	public var enableLetterbox:Bool = true;
	public var showMusicToast:Bool = true;
	public var useClassicMusic:Bool = false;
	public var musicVolume:Float = 0.25;
	public var gameSoundVolume:Float = 1;
	public var uiSoundVolume:Float = 0.5;
	public var allowBellyGurgles:Bool = false;
	public var allowBellyCreaks:Bool = true;
	public var cacheOnGPU:Bool = true;
	public var showFPS:Bool = false;
	public var showMemoryUsage:Bool = false;
	public var showCurrentState:Bool = false;

	public function new() {
	}
}

class Preferences {
	public static var data:SaveVariables = null;
	public static var defaultData:SaveVariables = null;

	public static function savePrefs() {
		FlxG.save.bind('options', Util.getSavePath());

		for (key in Reflect.fields(data)) {
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));
		}
		FlxG.save.flush();

		trace("Options saved!");
	}

	public static function loadPrefs() {
		if (data == null)
			data = new SaveVariables();
		if (defaultData == null)
			defaultData = new SaveVariables();

		FlxG.save.bind('options', Util.getSavePath());

		for (key in Reflect.fields(data)) {
			if (Reflect.hasField(FlxG.save.data, key)) {
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));
				// trace('loaded - $key: ${Reflect.field(FlxG.save.data, key)}');
			}
		}

		if (Main.fpsVar != null) {
			Main.fpsVar.visible = data.showFPS;
		}

		#if (!html5 && !switch)
		FlxG.autoPause = data.pauseOnUnfocus;
		#end

		if (data.framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = data.framerate;
			FlxG.drawFramerate = data.framerate;
		} else {
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
		}

		// flixel automatically saves your volume!
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
	}
}
