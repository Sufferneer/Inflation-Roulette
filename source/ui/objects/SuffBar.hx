package ui.objects;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class SuffBar extends FlxSpriteGroup {
	public var bg:FlxSprite;
	public var fill:FlxSprite;
	public var dividends:FlxSpriteGroup;
	public var valueFunction:Void->Float = function() return 0;
	public var percent(default, set):Float = 0;
	public var bounds:Dynamic = {min: 0, max: 1};
	public var segments(default, set):Int = 0;
	public var bgColor(default, set):FlxColor;
	public var fillColor(default, set):FlxColor;
	public var thickness:Int = 0;

	public var barWidth:Int = 0;
	public var barHeight:Int = 0;
	public var barOffset:FlxPoint;
	public var barCenter:Float = 0;

	public function new(x:Float, y:Float, valueFunction:Void->Float, boundMin:Float = 0, boundMax:Float = 1, width:Int = 400, height:Int = 20,
			thickness:Int = 4, segments:Int = 1, bgColor:FlxColor = 0xFF000000, fillColor:FlxColor = 0xFFFFFFFF) {
		super(x, y);

		if (valueFunction != null)
			this.valueFunction = valueFunction;
		setBounds(boundMin, boundMax);

		bg = new FlxSprite().makeGraphic(width, height, FlxColor.WHITE);

		this.thickness = thickness;
		barWidth = width - thickness - thickness;
		barHeight = height - thickness - thickness;
		barOffset = new FlxPoint(thickness, thickness);

		fill = new FlxSprite(barOffset.x, barOffset.y).makeGraphic(barWidth, barHeight, FlxColor.WHITE);
		fill.clipRect = new FlxRect(0, 0, Std.int(bg.width), Std.int(bg.height));

		add(bg);
		add(fill);

		dividends = new FlxSpriteGroup();
		add(dividends);
		this.bgColor = bgColor;
		this.fillColor = fillColor;

		this.segments = segments;
	}

	override function update(elapsed:Float) {
		var value:Null<Float> = FlxMath.remapToRange(FlxMath.bound(valueFunction(), bounds.min, bounds.max), bounds.min, bounds.max, 0, 100);
		percent = (value != null ? value : 0);
		super.update(elapsed);
	}

	public function setBounds(min:Float, max:Float) {
		bounds.min = min;
		bounds.max = max;
	}

	public function updateBar() {
		if (fill == null) {
			return;
		}
		var leftSize:Float = 0;
		leftSize = FlxMath.lerp(0, barWidth, percent / 100);

		fill.clipRect.width = leftSize;
		fill.clipRect.height = barHeight;

		barCenter = fill.x + leftSize + barOffset.x;

		fill.clipRect = fill.clipRect;
	}

	private function set_percent(value:Float) {
		var doUpdate:Bool = false;
		if (value != percent)
			doUpdate = true;
		percent = value;

		if (doUpdate)
			updateBar();
		return value;
	}

	private function set_segments(value:Int) {
		segments = value;
		for (dividend in dividends) {
			dividend.kill();
			dividend.destroy();
		}
		dividends.clear();
		for (i in 1...segments) {
			var dividend:FlxSprite = new FlxSprite().makeGraphic(thickness, Std.int(bg.height), FlxColor.WHITE);
			dividend.x = i * width / segments - thickness / 2; // Translate percentage to coordinates, then offset the segment so that the center of the segment is located in that coordinates
			dividend.color = bgColor;
			dividends.add(dividend);
		}
		return value;
	}

	private function set_bgColor(value:FlxColor) {
		bgColor = value;
		bg.color = bgColor;
		segments = segments;
		return value;
	}

	private function set_fillColor(value:FlxColor) {
		fillColor = value;
		fill.color = fillColor;
		return value;
	}
}
