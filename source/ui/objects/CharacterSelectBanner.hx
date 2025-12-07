package ui.objects;

import backend.CharacterManager;
import backend.types.CharacterData;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxGradient;
import flixel.util.FlxSignal;
import states.CharacterSelectState;

class CharacterSelectBanner extends SuffButton {
	public var designatedPlayer:String = '';
	var character:FlxSprite;

	var allowBlinking:Bool = false;
	var blinkTick:Float = 0;

	public function new(playerIndex:Int) {
		var sectionWidth:Int = Std.int(FlxG.width / CharacterManager.selectedCharacterList.length);
		var sectionHeight:Int = Std.int(FlxG.height * (1 - CharacterSelectState.cardOccupicationHeight));

		var color1:FlxColor = Constants.PLAYER_COLORS[playerIndex];
		var color2:FlxColor = color1.getDarkened(0.5);
		var image = FlxGraphic.fromBitmapData(FlxGradient.createGradientBitmapData(sectionWidth, sectionHeight, [color1, color2]));

		super(sectionWidth * playerIndex, y, null, image, image, sectionWidth, sectionHeight, false);

		character = new FlxSprite();
		character.visible = false;
		add(character);
	}

	public static function precacheBanners() {
		for (item in CharacterManager.globalCharacterList) {
			Paths.sparrowAtlas('gui/menus/characterSelect/banners/$item');
		}
		Paths.sparrowAtlas('gui/menus/characterSelect/banners/random');
	}

	public function setCharacter(char:String) {
		designatedPlayer = char;
		character.frames = Paths.sparrowAtlas('gui/menus/characterSelect/banners/$designatedPlayer');
		character.animation.addByPrefix('idle', 'idle', 24, false);
		character.animation.addByPrefix('start', 'start', 24, false);
		character.visible = true;
		character.animation.play('start');
		allowBlinking = true;
		character.animation.finishCallback = function(name:String) {
			blinkTick = FlxG.random.float() * 3;
		};
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (blinkTick < 0) {
			character.animation.play('idle');
			blinkTick = FlxG.random.float() * 3;
		} else {
			blinkTick -= elapsed;
		}
	}
}
