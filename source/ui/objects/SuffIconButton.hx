package ui.objects;

import flixel.graphics.FlxGraphic;

class SuffIconButton extends SuffButton {
	public function new(x:Float, y:Float, icon:String, hoveredIcon:String = null, scale:Float = 1, visibleBG:Bool = true) {
		var image:FlxGraphic = Paths.image('gui/icons/$icon');
		var hoveredImage:FlxGraphic = image;
		if (hoveredIcon != null)
			hoveredImage = Paths.image('gui/icons/$hoveredIcon');

		super(x, y, null, image, hoveredImage, Std.int(image.width * scale), Std.int(image.height * scale), visibleBG);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
