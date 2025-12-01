package ui.objects;

class GameLogo extends FlxSprite {
	static final logoScale:Float = 0.35;
    public function new(x, y) {
        super(x, y);
		loadGraphic(Paths.image('gui/menus/game_logo'));
		scale.set(logoScale, logoScale);
		updateHitbox();
    }

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}