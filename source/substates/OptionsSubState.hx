package substates;

import ui.objects.SuffBooleanOption;
import ui.objects.SuffIconButton;
import ui.objects.SuffSliderOption;

class OptionsSubState extends SuffSubState {
	public static var notInGame:Bool = true;

	var bg:FlxSprite;
	var bg2:FlxSprite;
	var scrollBar:FlxSprite;
	var headingText:FlxText;
	var exitButton:SuffIconButton;

	var optionsGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var optionsTitleToDescMap:Map<String, String> = new Map<String, String>();

	static final optionsXPadding:Float = 32;
	static final optionsYPadding:Float = 32;
	static final scrollBarWidth:Int = 30;

	var optionsMaxWidth:Float = 0;
	var optionsY:Float = 0;
	var optionsScrollUpperLimit:Float = 0;
	var optionsScrollLowerLimit:Float = 0;
	var scrollBarTween:FlxTween;

	var optionsScroll:Float = 0;
	var optionsScrollLerped:Float = 0;

	static final scrollLerpFactor:Float = 10;

	var touchedMusicOption:Bool = false;

	public function new() {
		super();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.75;
		add(bg);

		bg2 = new FlxSprite();
		add(bg2);

		if (notInGame) {
			SuffState.playMusic('options');
		}

		scrollBar = new FlxSprite();
		add(scrollBar);

		optionsY = optionsYPadding;
		optionsScrollUpperLimit = optionsY;
		optionsScrollLowerLimit = optionsY;

		add(optionsGroup);
		optionsGroup.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		generateOptions();

		bg2.makeGraphic(Std.int(optionsXPadding + optionsMaxWidth + optionsXPadding + scrollBarWidth), FlxG.height, FlxColor.BLACK);
		bg2.alpha = 0.375;

		scrollBar.makeGraphic(scrollBarWidth, Std.int(FlxG.height * (FlxG.height / (Math.abs(optionsScrollLowerLimit) + FlxG.height))), FlxColor.WHITE);
		scrollBar.x = bg2.width - scrollBar.width;
		updateScrollBar();

		exitButton = new SuffIconButton(20, 20, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20;
		exitButton.onClick = function() {
			exitOptionsMenu();
		};
		add(exitButton);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	function generateOptions() {
		optionsGroup.clear();

		// GENERAL SETTINGS
		createSubheading('General');

		createSliderOption('Framerate', 'How many screen refreshes and game updates should the game do in one second.', function(value:Float) {
			Preferences.data.framerate = Math.round(value);
		}, 30, 180, 10, function(value:Float) {
			return '' + Math.round(value);
		}, Preferences.data.framerate);

		#if (!html5 && !switch)
		createBooleanOption('Unfocus Pausing', 'Automatically pauses the game when out of focus.', function(value:Bool) {
			Preferences.data.pauseOnUnfocus = value;
		}, Preferences.data.pauseOnUnfocus);
		#end

		createBooleanOption('Popping',
			"Players non-fatally bursts when defeated.\nIf turned off, characters will be overinflated instead." +
			(!notInGame ? ' (Only updates after restart!)' : ''),
			function(value:Bool) {
				Preferences.data.allowPopping = value;
			}, Preferences.data.allowPopping);

		createBooleanOption('Eliminee Skip', "Players who are defeated will be skipped right over instead of playing an animation when it's their turn.",
			function(value:Bool) {
				Preferences.data.ignoreEliminatedPlayers = value;
			}, Preferences.data.ignoreEliminatedPlayers);

		#if (!mobile && !switch)
		createBooleanOption('Debug Mode', "Enable debug keybinds on PC. (If you're on mobile, too bad lmao)", function(value:Bool) {
			Preferences.data.enableDebugMode = value;
		}, Preferences.data.enableDebugMode);
		#end

		// GRAPHICS SETTINGS
		createSubheading('Graphics & Visuals');

		createBooleanOption('Photosensitive Mode',
			'Dampen screen flashes and other flashing effects.\nStrongly recommended for people with photosensitive epilepsy.', function(value:Bool) {
				Preferences.data.enablePhotosensitiveMode = value;
		}, Preferences.data.enablePhotosensitiveMode);

		createBooleanOption('Force Alising',
			'Removes antialiasing from all sprites even when enabled. Improves performance, but may make some graphics look jagged.', function(value:Bool) {
				Preferences.data.enableForceAliasing = value;
		}, Preferences.data.enableForceAliasing);

		createBooleanOption('Main Menu Animations', 'Always play first startup animations in the Main Menu.', function(value:Bool) {
			Preferences.data.alwaysPlayMainMenuAnims = value;
		}, Preferences.data.alwaysPlayMainMenuAnims);

		createSliderOption('Camera Intensity', 'How strong screen shaking and other disorienting effects should be.', function(value:Float) {
			Preferences.data.cameraEffectIntensity = value;
		}, 0, 1, 0.05, function(value:Float) {
			return Math.round(value * 100) + '%';
		}, Preferences.data.cameraEffectIntensity);

		createBooleanOption('Letterboxing', 'Show black bars on top and bottom sides of the screen during player animations and cutscenes.',
			function(value:Bool) {
				Preferences.data.enableLetterbox = value;
			}, Preferences.data.enableLetterbox);

		// AUDIO SETTINGS
		createSubheading('Audio & Music');

		createBooleanOption('Classic Music', "The game uses music in the original game instead of new music.", function(value:Bool) {
			Preferences.data.useClassicMusic = value;
			if (notInGame) {
				SuffState.playMusic('options');
			}
			touchedMusicOption = !touchedMusicOption;
		}, Preferences.data.useClassicMusic);

		createBooleanOption('Music Toast',
			'A notification containing the current background music name and its author will be shown whenever a music track is played.',
			function(value:Bool) {
				Preferences.data.showMusicToast = value;
			}, Preferences.data.showMusicToast);

		createSliderOption('Music Volume', 'The volume percentage of background music.', function(value:Float) {
			Preferences.data.musicVolume = value;
			if (notInGame)
				FlxG.sound.music.volume = Preferences.data.musicVolume;
		}, 0.0, 1.0, 0.05, function(value:Float) {
			return Math.round(value * 100) + '%';
		}, Preferences.data.musicVolume);

		createSliderOption('Game Sound Volume', 'The volume percentage of game sounds.', function(value:Float) {
			Preferences.data.gameSoundVolume = value;
			SuffState.playSound(Paths.soundRandom('weapon', 1, 3));
		}, 0.0, 1.0, 0.05, function(value:Float) {
			return Math.round(value * 100) + '%';
		}, Preferences.data.gameSoundVolume);

		createSliderOption('UI Sound Volume', 'The volume percentage of UI sounds.', function(value:Float) {
			Preferences.data.uiSoundVolume = value;
			SuffState.playUISound(Paths.soundRandom('weapon', 1, 3));
		}, 0.0, 1.0, 0.05, function(value:Float) {
			return Math.round(value * 100) + '%';
		}, Preferences.data.uiSoundVolume);

		createBooleanOption('Cursor Sounds', 'Plays a click sound whenever the mouse cursor clicks something.', function(value:Bool) {
			Preferences.data.playCursorSounds = value;
		}, Preferences.data.playCursorSounds);

		createBooleanOption('Borborygmi', "Players play belly gurgle sounds on idle when inflated.", function(value:Bool) {
			Preferences.data.allowBellyGurgles = value;
		}, Preferences.data.allowBellyGurgles);

		createBooleanOption('Creaking', "Players play balloon overstretching sounds on idle when inflated.", function(value:Bool) {
			Preferences.data.allowBellyCreaks = value;
		}, Preferences.data.allowBellyCreaks);

		// TECHNICAL SETTINGS
		createSubheading('Technical');

		#if (openfl && !html5)
		createBooleanOption('VRAM Caching',
			"Allows the GPU to be used for storing textures using VRAM for lower RAM usage.\nMay not work correctly with lower-end graphics cards.",
			function(value:Bool) {
				Preferences.data.cacheOnGPU = value;
			}, Preferences.data.cacheOnGPU);
		#end

		createBooleanOption('FPS Counter', 'Displays the FPS Counter.', function(value:Bool) {
			Preferences.data.showFPS = value;
		}, Preferences.data.showFPS);

		#if (openfl && !html5)
		createBooleanOption('Memory Usage Counter', 'Displays the current amount of memory used on the FPS Counter.', function(value:Bool) {
			Preferences.data.showMemoryUsage = value;
		}, Preferences.data.showMemoryUsage);

		createBooleanOption('State Tracker', 'Displays the current menu being navigated on the FPS Counter.', function(value:Bool) {
			Preferences.data.showCurrentState = value;
		}, Preferences.data.showCurrentState);
		#end

		var lastItem = optionsGroup.members[optionsGroup.members.length - 1];
		optionsScrollLowerLimit = -(lastItem.y + lastItem.height + optionsYPadding);
		if (optionsScrollLowerLimit < -FlxG.height) {
			optionsScrollLowerLimit += FlxG.height;
		}
	}

	function createSubheading(name:String) {
		if (optionsGroup.members.length > 0)
			optionsY += 32;
		var text:FlxText = new FlxText(32, optionsY, 0, name);
		text.setFormat(Paths.font('default'), 32, FlxColor.WHITE, CENTER);
		optionsGroup.add(text);
		optionsY += 48;

		if (text.x + text.width - optionsXPadding > optionsMaxWidth) {
			optionsMaxWidth = text.x + text.width - optionsXPadding;
		}
	}

	function createBooleanOption(name:String, description:String, callback:Bool->Void, defaultValue:Bool) {
		optionsTitleToDescMap.set(name, description);

		var text:FlxText = new FlxText(optionsXPadding, optionsY, 0, name);
		text.setFormat(Paths.font('default'), 48, FlxColor.WHITE, CENTER);
		optionsGroup.add(text);

		var option:SuffBooleanOption = new SuffBooleanOption(text.x + text.width + 16, optionsY, callback, defaultValue, name);
		text.y = option.y + (option.height - text.height) / 2;
		option.camera = this.camera;
		option.tooltipText = description;
		optionsGroup.add(option);

		optionsY += option.height + 16;
		if (option.x + option.width - optionsXPadding > optionsMaxWidth) {
			optionsMaxWidth = option.x + option.width - optionsXPadding;
		}
	}

	function createSliderOption(name:String, description:String, callback:Float->Void, rangeMin:Float, rangeMax:Float, step:Float,
			displayFunction:Float->String, defaultValue:Float) {
		optionsTitleToDescMap.set(name, description);

		var text:FlxText = new FlxText(optionsXPadding, optionsY, 0, name);
		text.setFormat(Paths.font('default'), 48, FlxColor.WHITE, CENTER);
		optionsGroup.add(text);

		var option:SuffSliderOption = new SuffSliderOption(text.x + text.width + 16, optionsY, callback, rangeMin, rangeMax, step, displayFunction,
			defaultValue, name);
		text.y = option.y + (option.height - text.height) / 2;
		option.camera = this.camera;
		option.tooltipText = description;
		optionsGroup.add(option);

		optionsY += option.height + 16;
		if (option.x + option.width - optionsXPadding > optionsMaxWidth) {
			optionsMaxWidth = option.x + option.width - optionsXPadding;
		}
	}

	function updateScrollBar() {
		scrollBar.alpha = 0.375;

		if (scrollBarTween != null)
			scrollBarTween.cancel();
		scrollBarTween = FlxTween.tween(scrollBar, {alpha: 0.15}, 4, {
			startDelay: 1
		});
	}

	function exitOptionsMenu() {
		Preferences.savePrefs();
		Preferences.loadPrefs();
		if (touchedMusicOption) {
			PauseSubState.resetMusic = true;
		}
		Tooltip.text = '';
		close();
		if (notInGame) {
			SuffState.playMusic('mainMenu');
		}
	}

	function boundOptionMenuScroll() {
		if (optionsScroll > 0) {
			optionsScroll = 0;
		} else if (optionsScroll < optionsScrollLowerLimit) {
			optionsScroll = optionsScrollLowerLimit;
		}
	}

	var allowMouseScrolling:Bool = true;

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE) {
			exitOptionsMenu();
		}
		if (FlxG.mouse.wheel != 0) {
			optionsScroll += FlxG.mouse.wheel * 128;
			boundOptionMenuScroll();
			updateScrollBar();
		}
		if (FlxG.mouse.pressed && allowMouseScrolling) {
			optionsScroll = optionsScroll - (FlxG.mouse.deltaScreenY) * (FlxG.height / scrollBar.height);
			boundOptionMenuScroll();
			optionsScrollLerped = optionsScroll;
			updateScrollBar();
		}

		optionsScrollLerped = FlxMath.lerp(optionsScrollLerped, optionsScroll, elapsed * scrollLerpFactor);
		optionsGroup.y = optionsScrollLerped;
		scrollBar.y = optionsScrollLerped / optionsScrollLowerLimit * (FlxG.height - scrollBar.height);

		allowMouseScrolling = true;
		for (opt in optionsGroup) {
			if (Std.isOfType(opt, SuffBooleanOption)) {
				var option:SuffBooleanOption = cast opt;
				if (option.hovered) {
					allowMouseScrolling = false;
				}
			} else if (Std.isOfType(opt, SuffSliderOption)) {
				var option:SuffSliderOption = cast opt;
				if (option.pressed) {
					allowMouseScrolling = false;
				}
			}
		}
	}
}
