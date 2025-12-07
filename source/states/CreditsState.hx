package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxGradient;
import states.MainMenuState;
import ui.objects.CreditsSketch;
import ui.objects.GameLogo;

class CreditsState extends SuffState {
	var creditsTxt:Array<Array<Dynamic>> = [
		['', '', 'GAME_LOGO', Std.int(FlxG.height / 4)],
		['MALLET INDUSTRIES', '', 'HEADING'],
		['Sufferneer', 'sufferneer', 'LOGO'],
		['ORIGINAL CONCEPT & DESIGN', '', 'HEADING'],
		['Snowyboi', 'snowyboi', 'LOGO'],
		['PRODUCER', '', 'HEADING'],
		['Sufferneer', 'sufferneer', 'LOGO'],
		['PROGRAMMER', '', 'HEADING'],
		['Sufferneer', 'sufferneer', 'LOGO'],
		['GRAPHICS', '', 'HEADING'],
		['Sufferneer', 'sufferneer', 'LOGO'],
		['Snowyboi', 'snowyboi', 'LOGO'],
		['MUSIC', '', 'HEADING'],
		['Sufferneer', 'sufferneer', 'LOGO'],
		['Snowyboi', 'snowyboi', 'LOGO'],
		['SOUND DESIGN', '', 'HEADING'],
		['Sufferneer', 'sufferneer', 'LOGO'],
		['PixelCarnage (OpenNSFW Sound Pack)', 'opennsfw', 'default'],
		['SPECIAL THANKS', '', 'HEADING'],
		['SqirraRNG - Crash Handler', '', 'default'],
		['Psych Engine Team - Backend Reference Code', '', 'default'],
		[
			'Funkin\' Crew & FNF Modding Community - Inspiration For Game-Dev',
			'',
			'default'
		],
		['DEVELOPED USING', '', 'HEADING'],
		['HaxeFlixel', 'haxeflixel', 'LOGO'],
		['Haxe', 'haxe', 'LOGO'],
		['OpenFL', 'openfl', 'LOGO'],
		['Lime', 'lime', 'default'],
		['CREDITS SKETCHES', '', 'HEADING'],
		['crococat', '', 'default'],
		['howfuii', '', 'default'],
		['Skodd420', '', 'default'],
		['TheRoboticError', '', 'default'],
		['Protogenics_Red', '', 'default'],
		['RetroActiveX', '', 'default'],
		['theotherface58', '', 'default'],
		['SillyJuices', '', 'default'],
		['Sufferneer', 'sufferneer', 'LOGO', Std.int(FlxG.height / 4)],
		[
			'This game is made in 72 hours (336 hours) as a joke. I would like to thank my fans for their support throughout this game, as well as Discord members who provided feedback and ideas.',
			'',
			'default',
			Std.int(FlxG.height / 2)
		],
		['', '', 'MALLET_INDUSTRIES']
	];
	var creditsTxtGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var leLineSpace:Int = 0;
	var imageList:Array<String> = [];

	var creditScrollValueUpperLimit:Float = FlxG.height;
	var creditScrollValue:Float = 0;
	var creditScrollValueLowerLimit:Int = 0;

	override public function create():Void {
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0xFF794080, 0xFF404080]));
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(64, 64, 128, 128, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(64, 64);
		add(grid);

		SuffState.playMusic('credits');

		for (line in creditsTxt) {
			var leText:FlxSpriteGroup = new FlxSpriteGroup();

			var leCharSpace:Int = 0;
			var size:Int = 48;
			leText.x = 16;
			if (creditsTxt.indexOf(line) != 0) {
				if (line[2] == 'HEADING') {
					leLineSpace += 64;
					leCharSpace = 32;
				}
			}
			leText.y = leLineSpace;
			if (line[3] != null) {
				leLineSpace += line[3];
			}

			var leLogo = new FlxSprite(leCharSpace, 0);
			if (line[1] != '' || line[2] == 'GAME_LOGO' || line[2] == 'MALLET_INDUSTRIES') {
				var texturePath:String = 'gui/menus/credits/logos/${line[1]}';
				if (line[2] == 'MALLET_INDUSTRIES') {
					texturePath = 'gui/menus/malletIndustriesLogo';
					leLogo.scale.set(6, 6);
				}
				if (line[2] == 'GAME_LOGO') {
					leLogo = new GameLogo(leCharSpace, 0);
					creditScrollValueUpperLimit = Std.int((FlxG.height - leLogo.height) / 2);
				} else {
					leLogo.loadGraphic(Paths.image(texturePath));
					leLogo.updateHitbox();
				}
				leCharSpace += Std.int(leLogo.width + 10);
				leText.add(leLogo);
			}

			var leChar:FlxText = new FlxText(leCharSpace, 0, Std.int(FlxG.width * 0.75));
			if (line[2] != 'LOGO') {
				leChar.text = line[0];
				var leFont:String = line[2];
				var leSize:Int = size;
				var leColor:Int = FlxColor.WHITE;
				if (line[2] == 'HEADING') {
					leFont = 'default';
					leSize = Std.int(size * 2);
					leColor = FlxColor.YELLOW;
				}
				leChar.setFormat(Paths.font(leFont), leSize, leColor);
			}
			if (leLogo.height > leChar.height) {
				leChar.y = (leLogo.height - leChar.height) / 2;
				leLineSpace += Std.int(leLogo.height + 16);
			} else {
				leLineSpace += Std.int(leChar.height + 16);
			}
			leText.add(leChar);

			creditsTxtGroup.add(leText);
		}
		creditScrollValueLowerLimit = Std.int(-(leLineSpace - creditsTxtGroup.members[creditsTxtGroup.members.length - 1].height * 1.5));
		creditScrollValue = creditScrollValueUpperLimit;
		add(creditsTxtGroup);

		var exitButton = new SuffButton(20, 20, null, Paths.image('gui/icons/buttons/exit'), null, 100, 100);
		exitButton.x = FlxG.width - exitButton.width - 10;
		exitButton.onClick = exitMenu;
		add(exitButton);

		var fileList = [];
		#if sys
		fileList = FileSystem.readDirectory(Paths.getPath('images/gui/menus/credits/sketches'));
		#else
		fileList = Utils.textFileToArray(Paths.getPath('images/gui/menus/credits/sketches/sketchesList.txt'));
		#end

		for (folder in fileList) {
			if (!folder.toLowerCase().endsWith('.txt')) {
				imageList.push(folder.replace('.png', ''));
			}
		}
	}

	function exitMenu() {
		SuffState.playMusic('mainMenu');
		SuffState.switchState(new MainMenuState());
	}

	var spawnSketchTime:Float = 0;

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (spawnSketchTime <= 0) {
			insert(members.indexOf(creditsTxtGroup) - 1, new CreditsSketch(imageList[FlxG.random.int(0, imageList.length - 1)]));
			spawnSketchTime = FlxG.random.float() * 0.25;
		} else {
			spawnSketchTime -= elapsed;
		}

		creditScrollValue -= elapsed * (50 +
			(FlxG.mouse.pressed || FlxG.keys.pressed.SPACE ? 450 : 0)) * (FlxG.mouse.pressedRight ? -1 : 1) * (FlxG.keys.pressed.SHIFT ? 2 : 1) * (FlxG.keys.pressed.CONTROL ? 2 : 1);
		if (creditScrollValue > creditScrollValueUpperLimit) {
			creditScrollValue = creditScrollValueUpperLimit;
		} else if (creditScrollValue < creditScrollValueLowerLimit) {
			creditScrollValue = creditScrollValueLowerLimit;
		}
		creditsTxtGroup.y = creditScrollValue;

		if (FlxG.keys.justPressed.ESCAPE) {
			exitMenu();
		}
	}
}
