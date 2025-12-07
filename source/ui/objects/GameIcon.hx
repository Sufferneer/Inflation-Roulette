package ui.objects;

class GameIcon extends FlxSprite {
	public function new(x:Float, y:Float, tag:String, size:Int = 100) {
        super(x, y);
		loadGraphic(Paths.image('gui/icons/$tag'));
		setGraphicSize(size, size);
		updateHitbox();
    }

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}