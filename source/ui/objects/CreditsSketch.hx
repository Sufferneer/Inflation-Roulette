package ui.objects;

class CreditsSketch extends FlxSprite {
    public function new(tag:String) {
		super(FlxG.width, 0);

		loadGraphic(Paths.image('gui/menus/credits/sketches/' + tag));
		var scal:Float = FlxG.random.float(0.5, 2);
		scale.set(scal, scal);
		updateHitbox();
		this.alpha = FlxG.random.float(0.1, 0.5);

		this.y = FlxG.random.float(-width / 2, FlxG.height - width / 2);

		this.velocity.x = FlxG.random.int(-1280, -320);
    }

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (this.x <= -width) {
			this.destroy();
		}
	}
}