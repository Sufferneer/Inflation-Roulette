package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxGradient;
import states.MainMenuState;
import ui.objects.CreditsSketch;
import ui.objects.GameLogo;
import ui.objects.SuffIconButton;

class CreditsState extends SuffState {
	var creditsTxt:Array<Array<Dynamic>> = [
		['', '', 'GAME_LOGO', Std.int(FlxG.height / 4)],
		['Design, Code, Art, Sound, Music', '', 'HEADING'],
		['NicklySuffer', 'nicklysuffer', 'LOGO'],
		['Original Concept, Music, Additional Art', '', 'HEADING'],
		['Snowyboi', 'snowyboi', 'LOGO'],
		['Sound Source', '', 'HEADING'],
		['PixelCarnagee\n(OpenNSFW Sound Pack)', 'opennsfw', 'default'],
		['Linux Port', '', 'HEADING'],
		['changedinflation.de', '', 'default'],
		['Crash Handler', '', 'HEADING'],
		['SqirraRNG', '', 'default'],
		['?\'? ???? ?? ?????', '', 'HEADING'],
		['bugzforbreakfast', '', 'default'],
		['Developed With', '', 'HEADING'],
		['HaxeFlixel', 'haxeflixel', 'LOGO', Std.int(FlxG.height / 4)],
		[
			'This game is made in 72 hours (correction: 2,048 hours) as a joke. I would like to thank my fans for their support throughout this game, as well as Discord members who provided feedback and ideas.',
			'',
			'default',
			Std.int(FlxG.height / 2)
		],
		[
			'Thanks For Playing',
			'',
			'default',
			-Std.int(FlxG.height / 2)
		]
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

		var overlay = new FlxBackdrop(Paths.image('gui/transitions/horizontal'), Y);
		overlay.x = -overlay.width / 2 + 80;
		overlay.velocity.set(0, 32);
		overlay.color = 0xFF0000FF;
		overlay.alpha = 0.25;
		add(overlay);

		SuffState.playMusic('credits');

		for (line in creditsTxt) {
			var leText:FlxSpriteGroup = new FlxSpriteGroup();

			var leCharSpace:Int = 32;
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
			if (line[1] != '' || line[2] == 'GAME_LOGO' || line[2] == 'NICKLY_SUFFER') {
				var texturePath:String = 'gui/menus/credits/logos/${line[1]}';
				if (line[2] == 'NICKLY_SUFFER') {
					texturePath = 'gui/menus/nicklySufferLogo';
					leLogo.scale.set(8, 8);
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

			var leChar:FlxText = new FlxText(leCharSpace, 0, Std.int(FlxG.width * 0.5));
			if (line[2] != 'LOGO') {
				leChar.text = line[0];
				var leFont:String = line[2];
				var leSize:Int = size;
				var leColor:Int = FlxColor.WHITE;
				if (line[2] == 'HEADING' || line[0].length > 50)
					leSize = 32;
				if (line[2] == 'HEADING') {
					leFont = 'default';
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

		var exitButton = new SuffIconButton(20, 20, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20;
		exitButton.onClick = function() {
			exitMenu();
		};
		add(exitButton);

		imageList = Paths.readDirectories('images/gui/menus/credits/sketches', 'images/gui/menus/credits/sketchesList.txt', 'png');
	}

	function exitMenu() {
		SuffState.playMusic('mainMenu');
		SuffState.switchState(new MainMenuState());
	}

	var spawnSketchTime:Float = 0;
	var creditScrollSpeed:Float = 1;

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (spawnSketchTime <= 0) {
			insert(members.indexOf(creditsTxtGroup) - 1, new CreditsSketch(imageList[FlxG.random.int(0, imageList.length - 1)]));
			spawnSketchTime = FlxG.random.float() * 0.25;
		} else {
			spawnSketchTime -= elapsed;
		}

		if (FlxG.mouse.wheel != 0) {
			creditScrollSpeed = FlxG.mouse.wheel * -30;
		} else if (FlxG.mouse.pressed && FlxG.mouse.x < FlxG.width / 2) {
			creditScrollValue = creditScrollValue + FlxG.mouse.deltaY;
		} else if (FlxG.mouse.justReleased) {
			creditScrollSpeed = FlxG.mouse.deltaY / -2;
		} else {
			creditScrollValue -= elapsed * 50 * creditScrollSpeed;
		}
		creditScrollSpeed = FlxMath.lerp(creditScrollSpeed, 1, elapsed * 5);
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
