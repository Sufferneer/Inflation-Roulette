package states;

import states.easterEggStartups.*;

class WarningState extends SuffState {
	var warningTitle:FlxText;
	var warningDesc:FlxText;
	var acceptButton:SuffButton;

	final warningText:String = 'This game is only for mature demographics over 18 YEARS OF AGE.\nThis is a fetish game, primarily containing FURRY INFLATION content, and may not be suitable to some. External addons made by third-parties are unmoderated and may contain material which may cause discomfort in some players. Recording and streaming of this game to social media platforms where juveniles are widely present is highly discouraged.\nThis game also features flashing images and screen shaking that may trigger photosensitive symptoms to some people. These effects can be dampened via the Options menu.\nBy pressing \'Accept\', you acknowledge these warnings and fully bear any negative consequences caused by this game.';
	var typingRate:Float = 0;
	var typingTick:Float = 0;
	
	override function create() {
		super.create();
		
		warningTitle = new FlxText(0, 0, 0, '- WARNING -');
		warningTitle.setFormat(Paths.font('default'), 80, 0xFFFF0000);
		warningTitle.screenCenter();
		warningTitle.alpha = 0;
		warningTitle.scale.set(2, 2);
		add(warningTitle);

		warningDesc = new FlxText(0, 0, warningTitle.width * 2.25, warningText);
		warningDesc.setFormat(Paths.font('default'), 32, 0xFFFFFFFF, LEFT);
		warningDesc.x = Std.int((FlxG.width - warningDesc.width) / 2);
		warningDesc.visible = false;
		add(warningDesc);

		acceptButton = new SuffButton(0, 0, 'Accept', null, null, 220, 100);
		acceptButton.btnBGOutlineColor = 0xFFFFFFFF;
		acceptButton.btnTextColorDisabled = 0xFF000000;
		acceptButton.btnBGColor = 0xFF000000;
		acceptButton.btnBGColorHovered = 0xFF000000;
		acceptButton.btnBGColorDisabled = 0xFFFFFFFF;
		acceptButton.clickSound = 'confetti';
		acceptButton.screenCenter();
		acceptButton.onClick = function() {
			acceptButton.disabled = true;
			SuffState.playUISound(Paths.music('win'), Preferences.data.musicVolume);
			FlxG.save.data.acknowledgedTermsOfService = true;
			FlxG.save.flush();
			new FlxTimer().start(1, function(_) {
				FlxG.camera.fade(0xFF000000, 2, function () {
					SuffState.switchState(new InitStartupState());
				});
			});
		}
		add(acceptButton);

		warningDesc.y = (FlxG.height - (warningTitle.height + warningDesc.height + acceptButton.height + 10)) / 2 + warningTitle.height;
		acceptButton.y = FlxG.height;

		FlxTween.tween(warningTitle, {'scale.x': 1, 'scale.y': 1, alpha: 1}, 0.75, {
			ease: FlxEase.backOut,
			onComplete: function(_) {
				FlxTween.tween(warningTitle, {y: (FlxG.height - (warningTitle.height + warningDesc.height + acceptButton.height + 10)) / 2}, 0.75, {
					ease: FlxEase.expoInOut,
					startDelay: 0.5,
					onComplete: function(_) {
						warningDesc.text = '';
						warningDesc.visible = true;
						typingRate = 55;
					}
				});
			}
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		typingTick += typingRate * elapsed;
		if (typingTick > warningText.length) {
			typingRate = 0;
			typingTick = warningText.length;
			FlxG.mouse.visible = true;
			FlxTween.tween(acceptButton, {
				y: warningDesc.y + warningDesc.height + 10
			}, 0.75, {
				ease: FlxEase.quadInOut,
				startDelay: 1
			});
		}
		warningDesc.text = warningText.substring(0, Math.round(typingTick));
	}
}
