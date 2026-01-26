package ui.objects;

class SuffBooleanOption extends FlxSpriteGroup {
	public var currentValue(default, set):Bool;
	public var onChangeCallback:Bool->Void;
	public var name:String = '';
	public var hovered:Bool = false;

	var outline:FlxSprite;
	var parent:FlxSprite;
	public var tooltipText:String = '';

	public function new(x:Float, y:Float, callback:Bool->Void, defaultValue:Bool = false, name:String = '') {
		super(x, y);
		onChangeCallback = callback;

		outline = new FlxSprite();
		outline.frames = Paths.sparrowAtlas('gui/menus/options/boolean/outline');
		outline.animation.addByPrefix('true', 'on', 24, false);
		outline.animation.addByPrefix('false', 'off', 24, false);
		add(outline);

		parent = new FlxSprite();
		parent.frames = Paths.sparrowAtlas('gui/menus/options/boolean/base');
		parent.animation.addByPrefix('true', 'on', 24, false);
		parent.animation.addByPrefix('false', 'off', 24, false);
		add(parent);

		this.currentValue = defaultValue;
		this.name = name;

		parent.animation.play('' + defaultValue, true, false, parent.animation.getByName('' + defaultValue).frames.length - 1);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (FlxG.mouse.overlaps(parent, this.camera) && visible) {
			if (!hovered) {
				SuffState.playUISound(Paths.sound('ui/hover'));
				Tooltip.text = tooltipText;
				outline.visible = true;
				hovered = true;
			}
			if (FlxG.mouse.justPressed) {
				currentValue = !currentValue;
				SuffState.playUISound(Paths.sound('ui/toggle' + Utils.capitalize(currentValue + '')));
				onChangeCallback(currentValue);
			}
		} else {
			if (hovered)
				Tooltip.text = '';
			outline.visible = false;
			hovered = false;
		}
	}

	private function set_currentValue(value:Bool):Bool {
		currentValue = value;
		parent.animation.play('' + value, true);
		outline.animation.play('' + value, true);
		return value;
	}
}
