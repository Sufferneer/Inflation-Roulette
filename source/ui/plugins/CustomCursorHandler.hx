package ui.plugins;

import openfl.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.addons.ui.FlxUI9SliceSprite;

class CustomCursorHandler extends FlxBasic {
	public static var instance:Null<CustomCursorHandler> = null;

	public static var enabled:Bool = true;

	public function new() {
		super();
	}

	public static function initialize() {
		FlxG.plugins.drawOnTop = true;
		instance = new CustomCursorHandler();
		FlxG.plugins.add(instance);
	}

	override function update(elapsed:Float) {
		if (instance == null && enabled)
			return;
		Utils.cursorChange('default', FlxG.mouse.pressed);
		super.update(elapsed);
	}
}
