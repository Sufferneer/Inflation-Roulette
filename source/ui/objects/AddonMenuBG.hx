package ui.objects;

import backend.CharacterManager;
import backend.types.CharacterData;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxGradient;
import states.CharacterSelectState;

class AddonMenuBG extends FlxTypedSpriteGroup<AddonMenuBGTile> {
	var tweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	var originalOffset:FlxPoint = new FlxPoint();
	public function new(x:Float, y:Float) {
		super(x, y);

		for (i in 0...4) {
			var leX:Float = parseX(i);
			var leY:Float = parseY(i);
			var tile:AddonMenuBGTile = new AddonMenuBGTile(0, 0, i);
			originalOffset.x = tile.offset.x;
			originalOffset.y = tile.offset.y;
			tile.offset.set(leX, leY);
			add(tile);
		}
	}

	function parseX(i:Int) {
		var leX:Float = 0;
		switch (i) {
			case 0:
				leX = 0;
			case 1:
				leX = -AddonMenuBGTile.bgSize;
			case 2:
				leX = -AddonMenuBGTile.bgSize;
			case 3:
				leX = 0;
		}
		return leX;
	}

	function parseY(i:Int) {
		var leY:Float = 0;
		switch (i) {
			case 0:
				leY = 0;
			case 1:
				leY = 0;
			case 2:
				leY = -AddonMenuBGTile.bgSize;
			case 3:
				leY = -AddonMenuBGTile.bgSize;
		}
		return leY;
	}

	public function rotate(change:Int = 0, duration:Float = 0.4) {
		for (tag => twn in tweens) {
			if (twn != null) {
				twn.cancel();
				tweens.remove(tag);
			}
		}
		for (i in 0...4) {
			var i2 = (members[i].index + change) % 4;
			members[i].index = i2;
			var leX:Float = parseX(members[i].index);
			var leY:Float = parseY(members[i].index);
			tweens.set('' + i, FlxTween.tween(members[i].offset, {
				x: originalOffset.x + leX,
				y: originalOffset.y + leY
			}, duration, {
				ease: FlxEase.quintOut
			}));
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}

class AddonMenuBGTile extends FlxSprite {
	public static final bgSize:Int = 160;
	
	static final images:Array<String> = [
		'gui/icons/stats/skill',
		'gui/icons/stats/pressure',
		'gui/icons/stats/gun',
		'gui/icons/stats/confidence'
	];
	public var index:Int = 0;

	public function new(x:Float, y:Float, index:Int) {
		super(x, y);
		this.index = index;
		loadGraphic(Paths.image(images[index]));
		setGraphicSize(bgSize, bgSize);
		updateHitbox();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
