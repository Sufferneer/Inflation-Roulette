package states;

import lime.app.Application;

class SplashScreenState extends SuffState {
	override function create() {
		super.create();

		FlxTransitionableState.skipNextTransIn = true;

		new FlxTimer().start(1.5, function(tmr:FlxTimer) {
			startIntro();
		});
	}

	var logo:FlxSprite;
	var timeToRemoveBlock:Float = 0;
	var timeElapsed:Float = 0;
	var allowToSkip:Bool = false;
	var removingBlocks:Bool = false;
	var tileGroup:FlxTypedContainer<FlxSprite> = new FlxTypedContainer<FlxSprite>();
	var curSquare:Int = 0;
	var blockCount:Int = 0;
	static final scale:Int = 8;

	var introSound:FlxSound;

	function startIntro() {
		trace("STARTING INTRO");
		logo = new FlxSprite().loadGraphic(Paths.image('gui/menus/mallet_industries_logo'));
		blockCount = Std.int(logo.height);
		logo.scale.set(scale, scale);
		logo.updateHitbox();
		logo.screenCenter(XY);
		add(logo);

		add(tileGroup);

		for (i in 0...Std.int(blockCount)) {
			var tile:FlxSprite = new FlxSprite(logo.x, logo.y + i * scale);
			tile.makeGraphic(Std.int(scale * logo.width), scale, 0xFF000000);
			tile.updateHitbox();
			tile.visible = false;
			tileGroup.add(tile);
		}

		introSound = new FlxSound().loadEmbedded(Paths.sound('sufferneer_intro'));
		introSound.volume = 0.7;
		introSound.play();

		timeToRemoveBlock = 1.5 / blockCount;

		allowToSkip = true;

		new FlxTimer().start(1.5, function(tmr:FlxTimer) {
			skipIntro();
		});
	}

	function skipIntro() {
		if (removingBlocks || !allowToSkip)
			return;

		if (introSound != null)
			introSound.stop();
		SuffState.playUISound(Paths.sound('transition'), 0.7);
		removingBlocks = true;
		new FlxTimer().start(1.5, function(tmr:FlxTimer) {
			SuffState.switchState(new MainMenuState());
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER) {
			skipIntro();
		}

		if (removingBlocks) {
			timeElapsed += elapsed;
			if (timeElapsed >= 0) {
				for (i in 0...Math.ceil(Math.abs(timeElapsed) / timeToRemoveBlock) + 1) {
					if (tileGroup.members[i] != null)
						tileGroup.members[i].visible = true;
				}
			}
		}
	}
}
