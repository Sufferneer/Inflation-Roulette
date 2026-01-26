package substates;

import backend.enums.SuffTransitionStyle;
import flixel.addons.transition.FlxTransitionableState;
import states.MainMenuState;
import states.PlayState;

class PauseSubState extends SuffSubState {
	var menuItems:Array<String> = ['Resume', 'Restart', 'Options', 'Exit'];
	var menuButtonGroup:FlxTypedGroup<SuffButton>;
	var pauseMusic:FlxSound;

	var usedFollowLerp:Float = 0;

	public static var resetMusic:Bool = false;

	public function new() {
		super();
		FlxG.sound.music.volume = 0;
		usedFollowLerp = FlxG.camera.followLerp;
		FlxG.camera.followLerp = 0;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.5;
		add(bg);

		pauseMusic = new FlxSound();
		pauseMusic.loadEmbedded(Paths.music('pause'));
		pauseMusic.volume = 0;
		pauseMusic.looped = true;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		pauseMusic.fadeIn(5, 0, 0.5 * Preferences.data.musicVolume);
		MusicToast.play(Paths.musicMetadata('pause'));

		var headingText:FlxText = new FlxText(0, 0, FlxG.width, '* PAUSE *');
		var headingTextTargetY:Int = 4;
		headingText.alpha = 0;
		headingText.setFormat(Paths.font('default'), 64, FlxColor.WHITE, CENTER);
		headingText.y = -headingText.height;
		FlxTween.tween(headingText, {alpha: 1, y: headingTextTargetY}, 0.75, {
			ease: FlxEase.cubeOut
		});
		add(headingText);

		menuButtonGroup = new FlxTypedGroup<SuffButton>();
		add(menuButtonGroup);

		for (i in 0...menuItems.length) {
			var button:SuffButton = new SuffButton(0, 0, menuItems[i], null, null, 300, 120);
			if (i % 2 == 1) {
				button.x = FlxG.width + button.width;
			} else {
				button.x = -button.width;
			}
			button.y = headingTextTargetY
				+ headingText.height
				+ ((FlxG.height - headingTextTargetY - headingText.height) - (button.height + 20) * menuItems.length) / 2
				+ i * (button.height + 20);
			FlxTween.tween(button, {x: (FlxG.width - button.width) / 2}, 0.75, {
				ease: FlxEase.cubeOut,
				startDelay: i * 0.1
			});
			button.onClick = function() {
				buttonFunction(menuItems[i]);
			}
			menuButtonGroup.add(button);
		}
	}

	var holdTime:Float = 0;

	function buttonFunction(daSelected:String) {
		if (timePassedOnSubState < 0.25) // Prevent Insta-Unpausing
			return;
		switch (daSelected.toUpperCase()) {
			case 'RESUME':
				PlayState.instance.isPaused = false;
				PlayState.instance.resumeGame();
				FlxG.camera.followLerp = usedFollowLerp;
				FlxG.sound.music.volume = Preferences.data.musicVolume;
				close();
				if (resetMusic) {
					SuffState.playMusic('game');
				}
			case "RESTART":
				restartGame();
			case "OPTIONS":
				OptionsSubState.notInGame = false;
				openSubState(new OptionsSubState());
			case 'EXIT':
				SuffState.switchState(new MainMenuState(), BLOCKY);
				SuffState.playMusic('null');
				FlxG.camera.followLerp = 0;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE) {
			buttonFunction('RESUME');
		}
	}

	public static function restartGame(noTrans:Bool = true) {
		SuffState.resetState();
	}

	override function destroy() {
		pauseMusic.pause();
		super.destroy();
	}
}
