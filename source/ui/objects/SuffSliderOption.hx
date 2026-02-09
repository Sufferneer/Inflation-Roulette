package ui.objects;

class SuffSliderOption extends FlxSpriteGroup {
	public var currentValue:Float;
	public var onChangeCallback:Float->Void;
	public var displayFunction:Float->String;
	public var name:String = '';
	public var hovered:Bool = false;
	public var pressed:Bool = false;
	public var range:Array<Float> = [0.0, 1.0];
	public var step:Float = 0.1;

	var outline:FlxSprite;
	var parent:FlxSprite;

	public var tooltipText:String = '';

	var displayText:FlxText;
	var minX:Float = 0;
	var maxX:Float = 0;
	var parentActualX:Float = 0;

	public function new(x:Float, y:Float, callback:Float->Void, rangeMin:Null<Float> = null, rangeMax:Null<Float> = null, step:Float = 0.05,
			displayFunction:Float->String = null, defaultValue:Float = 0, name:String = '') {
		super(x, y);
		onChangeCallback = callback;
		this.displayFunction = function(value:Float):String {
			return Math.round(value * 100) + '%';
		}
		if (displayFunction != null)
			this.displayFunction = displayFunction;
		this.currentValue = defaultValue;
		this.name = name;
		this.step = step;
		if (rangeMin != null)
			this.range[0] = rangeMin;
		if (rangeMax != null)
			this.range[1] = rangeMax;
		// trace(range);

		outline = new FlxSprite().loadGraphic(Paths.image('gui/menus/options/slider/bar'));
		add(outline);

		parent = new FlxSprite();
		parent.frames = Paths.sparrowAtlas('gui/menus/options/slider/switch');
		parent.animation.addByPrefix('idle', 'idle', 24, true);
		parent.animation.addByPrefix('hovered', 'hovered', 24, true);
		add(parent);

		displayText = new FlxText(0, outline.height, outline.width, '');
		displayText.setFormat(Paths.font('default'), 32, FlxColor.WHITE, CENTER);
		add(displayText);

		minX = outline.x;
		maxX = outline.x + outline.width - parent.width;
		parent.x = FlxMath.lerp(minX, maxX, Utils.invLerp(range[0], range[1], defaultValue));
		parentActualX = parent.x;

		recalculateValue(false);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	function setDisplayTextText(val:Float) {
		displayText.text = displayFunction(val);
	}

	function recalculateValue(callback:Bool = true) {
		currentValue = FlxMath.lerp(range[0], range[1], Utils.invLerp(minX, maxX, parent.x));
		if (callback)
			onChangeCallback(currentValue);
		setDisplayTextText(currentValue);
		// trace(currentValue);
	}

	function snapSlider() {
		var leActualPercent = Utils.invLerp(minX, maxX, parentActualX);
		var leActualValue = FlxMath.lerp(range[0], range[1], leActualPercent);
		var leStep = step;
		var leSnappedValue = Math.round(leActualValue / leStep) * leStep;
		var leSnappedPercent = Utils.invLerp(range[0], range[1], leSnappedValue);
		parent.x = FlxMath.lerp(minX, maxX, leSnappedPercent);

		setDisplayTextText(leSnappedValue);
	}

	function updateSlider() {
		parentActualX += FlxG.mouse.deltaScreenX;
		if (parentActualX < minX) {
			parentActualX = minX;
		} else if (parentActualX > maxX) {
			parentActualX = maxX;
		}
		snapSlider();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (FlxG.mouse.overlaps(parent, this.camera) && visible) {
			if (!hovered) {
				SuffState.playUISound(Paths.sound('ui/buttonHover'));
				parent.animation.play('hovered');
				Tooltip.text = tooltipText;
				hovered = true;
			}
			if (FlxG.mouse.pressed) {
				pressed = true;
			}
		} else {
			parent.animation.play('idle');
			if (hovered)
				Tooltip.text = '';
			hovered = false;
		}
		if (pressed) {
			updateSlider();
			if (FlxG.mouse.justReleased) {
				pressed = false;
				recalculateValue();
			}
		}
	}
}
