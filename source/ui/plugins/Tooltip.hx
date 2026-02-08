package ui.plugins;

import openfl.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.addons.ui.FlxUI9SliceSprite;

class Tooltip extends FlxSpriteGroup {
	public static var instance:Null<Tooltip> = null;

	var bg:FlxSprite;
	var bgOutline:FlxSprite;
	var tooltipText:FlxText;

	public static var text(default, set):String = '';

	static final maxWidth:Int = 480;
	static final padding:FlxPoint = new FlxPoint(12, 8);
	static final position:FlxPoint = new FlxPoint(40, -8);

	public static var enabled:Bool = false;

	public function new() {
		super();

		FlxGraphic.defaultPersist = true;

		scrollFactor.set();

		tooltipText = new FlxText(padding.x, padding.y, 0, '');
		tooltipText.setFormat(Paths.font('default'), 32, FlxColor.WHITE, LEFT);

		bg = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		bg.alpha = 0.7;
		bgOutline = new FlxSprite().loadGraphic(Utils.makeBorder(1, 1, 4, 0xFFFFFFFF));

		add(bg);
		add(bgOutline);
		add(tooltipText);

		FlxGraphic.defaultPersist = false;
	}

	public static function initialize() {
		FlxG.plugins.drawOnTop = true;
		instance = new Tooltip();
		FlxG.plugins.add(instance);
	}

	private static function set_text(value:String):String {
		text = value;
		if (instance == null)
			return value;
		instance.visible = false;

		instance.tooltipText.text = Utils.wrapColumns(text, 32);
		var leWidth = instance.tooltipText.width + padding.x * 2;
		var leHeight = instance.tooltipText.height + padding.y * 2;

		instance.bg.scale.set(leWidth, leHeight);
		instance.bg.updateHitbox();

		instance.bgOutline.loadGraphic(Utils.makeBorder(leWidth, leHeight, 4, 0xFFFFFFFF));
		instance.visible = FlxG.mouse.visible && (text.length > 0);
		return value;
	}

	override function update(elapsed:Float) {
		if (instance == null) {
			return;
		}
		instance.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		var leMousePos = FlxG.mouse.getScreenPosition(this.camera);
		instance.x = FlxMath.bound(leMousePos.x + position.x, 0, FlxG.width - instance.bg.width);
		instance.y = FlxMath.bound(leMousePos.y + position.y, 0, FlxG.height - instance.bg.height);

		super.update(elapsed);

		instance.visible = FlxG.mouse.visible && (text.length > 0);
	}
}
