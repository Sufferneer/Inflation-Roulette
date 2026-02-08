package ui.objects;

import openfl.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.addons.ui.FlxUI9SliceSprite;

class SuffBox extends FlxSpriteGroup {
	public var bgColor(default, set):FlxColor = 0xFF0F4894;
	public var outlineColor(default, set):FlxColor = 0xFF008FB5;

	public var bg:FlxUI9SliceSprite;
	public var outline:FlxUI9SliceSprite;

	public static final bgScale:Int = 2;

	/**
	 * @param x The X position of the button.
	 * @param y The Y position of the button.
	 * @param width The hitbox width of the button.
	 * @param height The hitbox height of the button.
	 */
	public function new(x:Float, y:Float, ?width:Float = 640, ?height:Float = 480) {
		super(x, y);

		var bgRect = new Rectangle(0, 0, Std.int(width / bgScale), Std.int(height / bgScale));
		var nineSlice = [40, 20, 88, 44];

		bg = new FlxUI9SliceSprite(0, 0, Paths.getImagePath('gui/boxes/box2xBase'), bgRect, nineSlice, 0x11);
		bg.setGraphicSize(Std.int(width), Std.int(height));
		bg.updateHitbox();
		bg.color = bgColor;
		add(bg);

		outline = new FlxUI9SliceSprite(0, 0, Paths.getImagePath('gui/boxes/box2xOutline'), bgRect, nineSlice, 0x11);
		outline.setGraphicSize(Std.int(width), Std.int(height));
		outline.updateHitbox();
		outline.color = outlineColor;
		add(outline);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	private function set_bgColor(value:FlxColor):FlxColor {
		bgColor = value;
		bg.color = bgColor;
		return bgColor;
	}

	private function set_outlineColor(value:FlxColor):FlxColor {
		outlineColor = value;
		outline.color = outlineColor;
		return outlineColor;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
