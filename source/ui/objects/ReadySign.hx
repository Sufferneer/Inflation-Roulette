package ui.objects;

import backend.CharacterManager;
import backend.types.CharacterData;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxGradient;
import states.CharacterSelectState;

class ReadySign extends SuffButton {
	var sign:FlxSprite;
	var outline:FlxSprite;

	static final signScale:Float = 0.75;

	public function new(startDisabled:Bool = true) {
		super((FlxG.width - 350 * signScale) / 2, 0, null, null, null, Std.int(350 * signScale), Std.int(240 * signScale), false);

		sign = new FlxSprite();
		sign.frames = Paths.sparrowAtlas('gui/menus/characterSelect/readySign');
		sign.animation.addByPrefix('idle', 'idle', 24, false);
		sign.scale.set(signScale, signScale);
		sign.updateHitbox();
		add(sign);

		outline = new FlxSprite();
		outline.frames = Paths.sparrowAtlas('gui/menus/characterSelect/readySignOutline');
		outline.animation.addByPrefix('idle', 'idle', 24, false);
		outline.scale.set(signScale, signScale);
		outline.updateHitbox();
		add(outline);

		disabled = startDisabled;
		sign.visible = false;
		outline.visible = false;
	}

	public function moveSign(retract:Bool = true) {
		sign.visible = true;
		outline.visible = true;
		sign.animation.play('idle', true, retract);
		outline.animation.play('idle', true, retract);

		this.disabled = retract;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		outline.visible = sign.visible && !this.disabled && hovered;
	}
}
