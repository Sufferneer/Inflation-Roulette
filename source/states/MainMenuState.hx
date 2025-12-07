package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import states.CharacterSelectState;
import states.CreditsState;
import substates.OptionsSubState;
import ui.objects.GameLogo;

class MainMenuState extends SuffState {
	public static var initialized:Bool = false;

	var bg:FlxBackdrop;
	var logo:GameLogo;

	static final buttonSpacing:Int = 10;

	var buttonGroup:FlxTypedContainer<SuffButton> = new FlxTypedContainer<SuffButton>();
	var playButton:SuffButton;
	var optionsButton:SuffButton;
	var galleryButton:SuffButton;
	var creditsButton:SuffButton;

	static final menuItems:Array<String> = ['PLAY', 'OPTIONS'];

	override public function create():Void {
		// Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.mouse.visible = true;
		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF347277);
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(64, 64, 128, 128, true, 0x50FFFFFF, 0x0));
		grid.velocity.set(-32, -32);
		add(grid);

		if (!initialized) {
			if (FlxG.save.data != null && FlxG.save.data.fullscreen) {
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				// trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentDraw = true;
			initialized = true;
		}

		if (FlxG.sound.music == null || SuffState.currentMusicName == 'null') { // idk lmao
			SuffState.playMusic('mainMenu');
		}

		logo = new GameLogo(0, 20);
		logo.screenCenter(X);
		add(logo);

		/*
			galleryButton = new SuffButton(0, 0, 'GALLERY', null, null, 300, 80);
			buttonGroup.add(galleryButton);
		 */

		var creditImage = Paths.image('gui/menus/malletIndustriesLogo');
		var creditImageHovered = Paths.image('gui/menus/malletIndustriesLogoHighlighted');

		creditsButton = new SuffButton(10, 0, '', creditImage, creditImageHovered, creditImage.width * 2, creditImage.height * 2, false);
		creditsButton.btnTextColorHovered = 0xFFFFFF00;
		creditsButton.y = FlxG.height - creditsButton.height - 10;
		creditsButton.onClick = function() {
			menuButtonFunctions('CREDITS');
		}
		add(creditsButton);

		add(buttonGroup);

		for (i in 0...menuItems.length) {
			var button = new SuffButton(0, 0, menuItems[i], null, null, 300, 100);
			if (i % 2 == 1) {
				button.x = FlxG.width + button.width;
			} else {
				button.x = button.width * -1;
			}
			button.y = logo.y
				+ logo.height
				+ (FlxG.height - (logo.y + logo.height) - (100 + buttonSpacing) * menuItems.length) / 2
				+ (100 + buttonSpacing) * i;
			button.onClick = function() {
				menuButtonFunctions(menuItems[i]);
			};
			buttonGroup.add(button);

			FlxTween.tween(button, {x: (FlxG.width - button.width) / 2}, 0.75, {
				ease: FlxEase.cubeOut,
				startDelay: 0.5 + i * 0.1
			});
		}

		initialized = true;

		super.create();
	}

	function menuButtonFunctions(menu:String) {
		switch (menu) {
			case 'PLAY':
				SuffState.switchState(new CharacterSelectState());
			case 'OPTIONS':
				OptionsSubState.notInGame = true;
				openSubState(new OptionsSubState());
			case 'CREDITS':
				SuffState.switchState(new CreditsState());
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
