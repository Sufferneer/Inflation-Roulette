package ui.objects;

import backend.types.AddonData;

class AddonMenuItem extends SuffButton {
	public static final spacing:Int = 10;
	public static final iconSize:Int = 128;
	public static var defaultWidth:Int = 500;
	public static var defaultHeight:Int = 0;

	var bg:FlxSprite;
	var modName:FlxText;
	var modDesc:FlxText;
	var icon:FlxSprite;

	public var addon:AddonData;

	public function new(x:Float, y:Float, folder:String, leAddon:AddonData) {
		super(x, y, null, null, null, defaultWidth, defaultHeight, false);
		this.addon = leAddon;

		bg = new FlxSprite(spacing, spacing).makeGraphic(defaultWidth - spacing * 2, defaultHeight - spacing, 0xFFFFFFFF);
		bg.alpha = 0.5;
		add(bg);

		var path:String = Paths.addons('$folder/metadata/pack.png');
		if (!FileSystem.exists(path)) {
			path = Paths.getImagePath('gui/menus/addons/defaultIcon');
		}
		var leIconImage = Paths.cacheBitmap(path);
		var iconOffset:Float = (defaultHeight - iconSize) / 2;
		icon = new FlxSprite(iconOffset, iconOffset).loadGraphic(leIconImage);
		icon.setGraphicSize(iconSize, iconSize);
		icon.updateHitbox();
		add(icon);

		var textOffset:Float = iconOffset + icon.width + 16;
		modName = new FlxText(textOffset, iconOffset, 0, addon.name);
		modName.setFormat(Paths.font('default'), 48);
		add(modName);

		var modDescY = iconOffset + modName.height - 8;
		modDesc = new FlxText(textOffset, modDescY, defaultWidth - textOffset - iconOffset, addon.description);
		modDesc.alpha = 0.5;
		modDesc.setFormat(Paths.font('default'), 16);
		add(modDesc);

		var leScale:Float = (defaultHeight - modDescY - iconOffset / 2) / modDesc.height;
		if (leScale < 1) {
			modDesc.scale.set(1, leScale);
			modDesc.updateHitbox();
		}

		this.onHover = function() {
			bg.color = 0x808000;
		}
		this.onIdle = function() {
			bg.color = 0x000000;
		}
		this.onIdle();
	}
}