package ui.plugins;

import flixel.graphics.FlxGraphic;
import flixel.addons.ui.FlxUI9SliceSprite;
import openfl.geom.Rectangle;

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
		if (Preferences.data.playCursorSounds && FlxG.mouse.visible && FlxG.mouse.justPressed) {
			SuffState.playUISound(Paths.sound('ui/cursorClick'), 0.5, FlxG.random.float(1.5, 3));
		}
		super.update(elapsed);
	}
}
