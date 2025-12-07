package ui.objects;

class SuffTransitionBlock extends FlxSpriteGroup {
	public function new(x:Float, y:Float, suffix:String, size:Int = 160, color:FlxColor = 0xFF000000) {
		super(x, y);

		var bg:FlxSprite = new FlxSprite().makeGraphic(size, size, color);
		add(bg);

		var gold:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gui/transitions/blocky/$suffix'));
		gold.setGraphicSize(size, size);
		gold.updateHitbox();
		gold.alpha = 0.1;
		add(gold);
    }

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}