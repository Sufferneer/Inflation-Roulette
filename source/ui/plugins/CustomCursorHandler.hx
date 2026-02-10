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
		if (Preferences.data.playCursorSounds && FlxG.mouse.visible) {
			if (FlxG.mouse.justPressed) {
				SuffState.playUISound(Paths.sound('ui/cursorClick'), 0.75, FlxG.random.float(1.5, 3));
			} else if (FlxG.mouse.justReleased) {
				SuffState.playUISound(Paths.sound('ui/cursorClick'), 0.25, FlxG.random.float(0.75, 1));
			}
		}
		super.update(elapsed);
	}
}
