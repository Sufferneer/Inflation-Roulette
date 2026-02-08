package ui;

import backend.enums.SuffTransitionStyle;
import backend.types.MusicMetadata;
import flixel.addons.ui.FlxUIState;
import flixel.FlxSubState;
import flixel.FlxState;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import openfl.filters.ColorMatrixFilter;
import tjson.TJSON as Json;
import flash.media.Sound;

class SuffState extends FlxUIState {
	public static var currentMusicName:String = '';
	public static var timePassedOnState:Float = 0;
	public static var currentMusicBPM:Float = 0;

	override function create() {
		var skip:Bool = FlxTransitionableState.skipNextTransOut;

		if (!skip)
			openSubState(new SuffTransition(0.4, true));

		super.create();

		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;
	}

	public static function playMusic(tag:String, volume:Float = 1, forceRestart:Bool = false, forceModernIfNoClassic:Bool = false, looped:Bool = true) {
		var usedTag:String = tag;
		if (usedTag == '' || usedTag == 'null') {
			currentMusicName = 'null';
			return;
		}
		if (Preferences.data.useClassicMusic) {
			usedTag = 'classic/' + tag;
		}
		if (!forceRestart && currentMusicName == usedTag)
			return;
		if (!Paths.fileExists(Paths.appendSoundExt('music/' + usedTag), SOUND)) {
			if (!forceModernIfNoClassic) {
				trace('Music [$usedTag] cannot be found. Skipping');
				return;
			} else {
				usedTag = tag;
				trace('Music [$usedTag] cannot be found. Using Modern Music');
			}
		}
		currentMusicName = usedTag;
		FlxG.sound.playMusic(Paths.music(usedTag), volume * Preferences.data.musicVolume);
		FlxG.sound.music.looped = looped;
		var metadata:MusicMetadata = Paths.musicMetadata(usedTag);
		if (metadata.toast)
			MusicToast.play(metadata);
		currentMusicBPM = metadata.bpm;
	}

	public static function playSound(tag:Sound, volume:Float = 1, pitch:Float = 1) {
		var sound = new FlxSound().loadEmbedded(tag, false, true);
		sound.volume = volume * Preferences.data.gameSoundVolume;
		sound.pitch = pitch;
		sound.play();
	}

	public static function playUISound(tag:Sound, volume:Float = 1, pitch:Float = 1) {
		var sound = new FlxSound().loadEmbedded(tag, false, true);
		sound.volume = volume * Preferences.data.uiSoundVolume;
		sound.pitch = pitch;
		sound.play();
	}

	override function update(elapsed:Float) {
		timePassedOnState += elapsed;

		if (FlxG.save.data != null)
			FlxG.save.data.fullscreen = FlxG.fullscreen;

		super.update(elapsed);
	}

	public static function switchState(nextState:FlxState = null, style:SuffTransitionStyle = DEFAULT) {
		Main.mainClassState = Type.getClass(nextState);
		if (nextState == null)
			nextState = FlxG.state;
		if (nextState == FlxG.state) {
			resetState();
			return;
		}

		SuffTransition.style = style;

		if (FlxTransitionableState.skipNextTransIn)
			FlxG.switchState(nextState);
		else
			startTransition(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function resetState(style:SuffTransitionStyle = DEFAULT) {
		SuffTransition.style = style;
		if (FlxTransitionableState.skipNextTransIn)
			FlxG.resetState();
		else
			startTransition(FlxG.state);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public function toggleMonochrome(enable:Bool = false) {
		// #if js return; #end
		if (enable) {
			var t:Float = Constants.MONOCHROME_BRIGHTNESS;
			var filter = new ColorMatrixFilter([t, t, t, 0, 0, t, t, t, 0, 0, t, t, t, 0, 0, 0, 0, 0, 1, 0]);
			for (i in 0...FlxG.cameras.list.length - 1) {
				FlxG.cameras.list[i].filters = [filter];
			}
		} else {
			for (i in 0...FlxG.cameras.list.length - 1) {
				FlxG.cameras.list[i].filters = [];
			}
		}
	}

	// Custom made Trans in
	public static function startTransition(nextState:FlxState = null) {
		if (nextState == null) {
			nextState = FlxG.state;
		}

		FlxG.state.openSubState(new SuffTransition(0.4, false));
		if (nextState == FlxG.state)
			SuffTransition.finishCallback = function() FlxG.resetState();
		else
			SuffTransition.finishCallback = function() FlxG.switchState(nextState);
	}

	public static function getState():SuffState {
		return cast(FlxG.state, SuffState);
	}
}
