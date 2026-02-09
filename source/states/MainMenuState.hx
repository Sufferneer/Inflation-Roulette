package states;

import backend.SplashManager;
#if _ALLOW_VERSION_HANDLING
import backend.VersionMetadata;
#end
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import states.CreditsState;
#if _ALLOW_ADDONS
import states.AddonsMenuState;
#end
import substates.OptionsSubState;
import substates.GamemodeSelectSubState;
import ui.objects.GameLogo;

class MainMenuState extends SuffState {
	public static var initialized:Bool = false;

	var finishedAnimation:Bool = true;

	var bg:FlxSprite;
	var overlay:FlxBackdrop;
	var logo:GameLogo;
	var splashText:FlxText;

	static final buttonSpacing:Int = 10;

	var buttonGroup:FlxTypedContainer<SuffButton> = new FlxTypedContainer<SuffButton>();
	var infoTextGroup:FlxTypedSpriteGroup<FlxText> = new FlxTypedSpriteGroup<FlxText>();
	var playButton:SuffButton;
	var optionsButton:SuffButton;
	var galleryButton:SuffButton;
	var creditsButton:SuffButton;

	static final menuItems:Array<String> = [
		'Play',
		'Options',
		#if _ALLOW_ADDONS
		'Addons',
		#end
		'Donate'
	];

	override public function create():Void {
		// Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.mouse.visible = true;
		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		if (FlxG.sound.music == null || SuffState.currentMusicName == 'null') { // idk lmao
			SuffState.playMusic('mainMenu');
		}

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF347277);
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(64, 64, 128, 128, true, 0x50FFFFFF, 0x0));
		grid.velocity.set(-32, -32);
		add(grid);

		overlay = new FlxBackdrop(Paths.image('gui/transitions/horizontal'), Y);
		overlay.x = -overlay.width / 2 - 60;
		overlay.velocity.set(0, 32);
		overlay.color = 0xFF105060;
		overlay.alpha = 0.75;
		add(overlay);

		logo = new GameLogo(0, 0);
		logo.x = FlxG.width / 2 + (FlxG.width / 2 - logo.width) / 2;
		logo.y = (FlxG.height - logo.height) / 2;
		add(logo);

		splashText = new FlxText(0, 0, FlxG.width * 0.4, 'Empty');
		splashText.setFormat(Paths.font('default'), 32, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.SHADOW, 0x80000000);
		splashText.text = getRandomSplashText();
		splashText.y = logo.y + logo.height + 10;
		add(splashText);
		tweenSplashTextColor();

		final infoTextList:Array<String> = [
			Utils.getGameTitle(),
			#if _ALLOW_VERSION_HANDLING
			'Version ' + FlxG.stage.application.meta.get('version'), VersionMetadata.getVersionName(FlxG.stage.application.meta.get('version'))
			#else
			'Modded Version ' + FlxG.stage.application.meta.get('version')
			#end
		];

		add(infoTextGroup);
		for (i in 0...infoTextList.length) {
			var infoText = new FlxText(0, 0, 0, infoTextList[i]);
			infoText.setFormat(Paths.font('default'), 16, FlxColor.WHITE);
			infoText.x = FlxG.width - infoText.width;
			infoText.y = FlxG.height - infoText.height * (infoTextList.length - i);
			infoTextGroup.add(infoText);
		}

		var creditImage = Paths.image('gui/menus/malletIndustriesLogo');
		var creditImageHovered = Paths.image('gui/menus/malletIndustriesLogoHighlighted');
		creditsButton = new SuffButton(10, 0, '', creditImage, creditImageHovered, creditImage.width * 2, creditImage.height * 2, false);
		creditsButton.btnTextColorHovered = 0xFFFFFF00;
		creditsButton.y = FlxG.height - creditsButton.height - 10;
		creditsButton.onClick = function() {
			menuButtonFunctions('CREDITS');
		}
		creditsButton.tooltipText = 'Copyright (C) NicklySuffer';
		add(creditsButton);

		add(buttonGroup);

		for (i in 0...menuItems.length) {
			var button = new SuffButton(0, 0, menuItems[i], null, null, 300, 100);
			if (menuItems[i] == 'Donate')
				button.tooltipText = 'Your generous donation directly supports the creator of the game!';
			button.x = (FlxG.width / 2 - button.width) / 2;
			button.y = (FlxG.height - (100 + buttonSpacing) * menuItems.length) / 2 + (100 + buttonSpacing) * i;
			button.onClick = function() {
				menuButtonFunctions(menuItems[i]);
			};
			buttonGroup.add(button);
		}

		if (!initialized || Preferences.data.alwaysPlayMainMenuAnims)
			runFirstStartupTweens();
		if (!initialized) {
			if (FlxG.save.data != null && FlxG.save.data.fullscreen) {
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				// trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentDraw = true;
			initialized = true;
		}

		super.create();
	}

	function runFirstStartupTweens() {
		finishedAnimation = false;
		logo.x = (FlxG.width - logo.width) / 2;
		logo.y = -logo.height;
		FlxTween.tween(logo, {y: (FlxG.height - logo.height) / 2}, 1, {
			ease: FlxEase.quintOut,
			startDelay: 0.5
		});
		FlxTween.tween(logo, {x: FlxG.width / 2 + (FlxG.width / 2 - logo.width) / 2}, 1, {
			ease: FlxEase.quintInOut,
			startDelay: 1.5
		});

		overlay.x = -overlay.width;
		FlxTween.tween(overlay, {x: -overlay.width / 2 - 60}, 1, {
			ease: FlxEase.cubeOut,
			startDelay: 1.75
		});

		for (num => button in buttonGroup.members) {
			button.x = button.width * -1;

			FlxTween.tween(button, {x: (FlxG.width / 2 - button.width) / 2}, 0.75, {
				ease: FlxEase.cubeOut,
				startDelay: 2 + num * 0.1
			});
		}

		for (num => text in infoTextGroup.members) {
			text.x = FlxG.width;
			FlxTween.tween(text, {x: FlxG.width - text.width}, 1, {
				ease: FlxEase.cubeOut,
				startDelay: 2 + num * 0.2
			});
		}

		creditsButton.x = -creditsButton.width;
		FlxTween.tween(creditsButton, {x: 10}, 1, {
			ease: FlxEase.cubeOut,
			startDelay: 2.5
		});

		splashText.y = FlxG.height * 1.25;
		new FlxTimer().start(2.0, function(_) { // logo position will be fetched after timer ends
			FlxTween.tween(splashText, {y: logo.y + logo.height + 10}, 0.75, {
				ease: FlxEase.cubeOut,
				onComplete: function(_) {
					finishedAnimation = true;
				}
			});
		});
	}

	function getRandomSplashText() {
		return SplashManager.activeSplashes[FlxG.random.int(0, SplashManager.activeSplashes.length - 1)];
	}

	function changeSplashText() {
		var leText = getRandomSplashText();
		while (leText == splashText.text) {
			leText = getRandomSplashText();
		}
		splashText.text = leText;
	}

	function fadeSplashText() {
		FlxTween.tween(splashText, {y: FlxG.height}, 1, {
			ease: FlxEase.cubeIn,
			onComplete: function(twn:FlxTween) {
				changeSplashText();
				FlxTween.tween(splashText, {y: logo.y + logo.height + 10}, 1, {ease: FlxEase.cubeOut});
			}
		});
	}

	var curColor:Int = 0;

	function tweenSplashTextColor() {
		if (SplashManager.activeColors.length <= 1)
			return;
		curColor = FlxMath.wrap(curColor + 1, 0, SplashManager.activeColors.length - 1);
		FlxTween.cancelTweensOf(splashText, ['color']);
		FlxTween.color(splashText, 1, splashText.color, SplashManager.activeColors[curColor], {
			onComplete: function(_) {
				tweenSplashTextColor();
			}
		});
	}

	function menuButtonFunctions(menu:String) {
		switch (menu.toUpperCase()) {
			case 'PLAY':
				openSubState(new GamemodeSelectSubState());
			case 'OPTIONS':
				OptionsSubState.notInGame = true;
				openSubState(new OptionsSubState());
			#if _ALLOW_ADDONS
			case 'ADDONS':
				SuffState.switchState(new AddonsMenuState());
			#end
			case 'CREDITS':
				SuffState.switchState(new CreditsState());
			case 'DONATE':
				Utils.browserLoad('https://ko-fi.com/nicklysuffer');
		}
	}

	var splashTextChangeTimer:Float = 0;
	var displayedLogoScale:Float = GameLogo.logoScale;

	override function update(elapsed:Float) {
		super.update(elapsed);

		logo.angle = splashText.angle = Math.sin(SuffState.timePassedOnState) * 5;
		displayedLogoScale = FlxMath.lerp(displayedLogoScale, GameLogo.logoScale, elapsed * 10);
		var leScale = displayedLogoScale - Math.pow(Math.sin(SuffState.timePassedOnState / 2), 2) * 0.05;
		logo.scale.set(leScale, leScale);

		splashText.x = logo.x + (logo.width - splashText.width) / 2;
		var splashTextScale = 1 + Math.abs(Math.sin(SuffState.timePassedOnState * Math.PI * 2)) * 0.05;
		splashText.scale.set(splashTextScale, splashTextScale);
		if (finishedAnimation) {
			if (FlxG.mouse.overlaps(logo) && FlxG.mouse.justPressed) {
				splashTextChangeTimer = 0;
				displayedLogoScale -= 0.025;
				changeSplashText();
				FlxTween.cancelTweensOf(splashText, ['y']);
				FlxTween.tween(splashText, {y: logo.y + logo.height + 10}, 0.08, {ease: FlxEase.cubeOut});
				SuffState.playUISound(Paths.sound('musicToastClick'));
			}

			splashTextChangeTimer += elapsed;
			if (splashTextChangeTimer >= 10) {
				splashTextChangeTimer = 0;
				fadeSplashText();
			}
		}
	}
}
