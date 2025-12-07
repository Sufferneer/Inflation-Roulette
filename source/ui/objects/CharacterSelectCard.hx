package ui.objects;

import backend.types.CharacterData;

class CharacterSelectCard extends SuffButton {
	public var characterData:CharacterData;
	public var designatedPlayer:Null<Int> = null;
	public var holdAnim:Bool = false;

	var bg:FlxSprite;
	var outline:FlxSprite;
	var charSprite:FlxSprite;
	var charNameText:FlxText;

	public function new(x:Float, y:Float, character:CharacterData) {
		super(x, y, null, null, null, Constants.CHARACTER_CARD_DIMENSIONS[0], Constants.CHARACTER_CARD_DIMENSIONS[1], false);

		this.characterData = character;

		bg = new FlxSprite().loadGraphic(Paths.image('gui/menus/characterSelect/cards/${characterData.id}BG'));
		add(bg);

		outline = new FlxSprite().loadGraphic(Paths.image('gui/menus/characterSelect/cardOutline'));
		add(outline);

		charSprite = new FlxSprite();
		charSprite.frames = Paths.sparrowAtlas('gui/menus/characterSelect/cards/${characterData.id}');
		charSprite.animation.addByPrefix('idle', 'idle');
		charSprite.animation.addByPrefix('selected', 'selected', 24, false);
		charSprite.animation.play('idle');
		charSprite.animation.finishCallback = function(animName:String) {
			if (animName == 'selected' && charSprite.animation.curAnim.reversed) {
				charSprite.animation.play('idle');
			}
		};
		add(charSprite);

		charNameText = new FlxText(6, 6, width - 6 * 2, characterData.name.toUpperCase());
		charNameText.setFormat(Paths.font('default'), 16, FlxColor.WHITE);
		add(charNameText);
	}

	public function playAnim(name:String, forced:Bool = false, reversed:Bool = false, firstFrame:Int = 0) {
		charSprite.animation.play(name, forced, reversed, firstFrame);
	}

	public function setScale(x:Float, y:Float) {
		btnBG.setGraphicSize(Std.int(width * x), Std.int(height * y));
		btnBG.updateHitbox();
		for (item in [bg, outline, charSprite]) {
			item.scale.set(x, y);
			item.updateHitbox();
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		outline.visible = this.hovered;
		
		btnBG.visible = false;
		btnBGOutline.visible = false;

		if (holdAnim) {
			charSprite.animation.play(charSprite.animation.curAnim.name, true, false, charSprite.animation.curAnim.frames.length - 1);
		}
	}
}
