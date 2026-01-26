package ui.objects;

import openfl.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.addons.ui.FlxUI9SliceSprite;

/**
 * Custon button object used in UIs.
 */
class SuffButton extends FlxSpriteGroup {
	public var disabled(default, set):Bool = false;
	public var hovered:Bool = false;
	public var clicked:Bool = false;
	public var onIdle:Void->Void = null;
	public var onHover:Void->Void = null;
	public var onClick:Void->Void = null;

	public var btnTextTxt(default, set):String = '';
	public var btnTextColor(default, set):FlxColor = 0xFFFFFFFF;
	public var btnTextColorHovered:FlxColor = 0xFFFFFFFF;
	public var btnTextColorClicked:FlxColor = 0xFFFFFFFF;
	public var btnTextColorDisabled:FlxColor = 0xFF808080;
	public var btnTextSize(default, set):Int = 48;
	public var btnTextAlpha(default, set):Float = 1;
	public var btnTextFont(default, set):String = 'default';

	public var btnBGColor(default, set):FlxColor = 0xFF0F4894;
	public var btnBGColorHovered:FlxColor = 0xFF4F9BFF;
	public var btnBGColorClicked:FlxColor = 0xFF4F9BFF;
	public var btnBGColorDisabled:FlxColor = 0xFF3F5B7F;
	public var btnBGOutlineColor(default, set):FlxColor = 0xFF008FB5;
	public var btnBGAlpha(default, set):Float = 1;

	public var clickSound:String = 'ui/click';
	public var releaseSound:String = 'ui/release';
	public var hoverSound:String = 'ui/hover';

	public var btnBG:FlxUI9SliceSprite;
	public var btnBGOutline:FlxUI9SliceSprite;
	public var btnText:FlxText;
	public var btnIcon:FlxSprite = null;

	public var btnIconImage:FlxGraphic = null;
	public var btnIconImageHovered:FlxGraphic = null;

	public var tooltipText:String = '';

	var btnBGColorTween:FlxTween;
	var btnScaleTweens:Array<FlxTween> = [];

	static final iconPadding:Int = 0;
	static final bgScale:Int = 2;

	/**
	 * @param x The X position of the button.
	 * @param y The Y position of the button.
	 * @param text The text displayed on the button. Set to `null` to hide.
	 * @param img The image displayed on the button. Set to `null` to hide.
	 * @param imgHovered The image displayed on the button when hovered. Set to `null` to use `img`.
	 * @param width The hitbox width of the button.
	 * @param height The hitbox height of the button.
	 * @param visibleBG Whether the default button background is visible or not.
	 */
	public function new(x:Float, y:Float, ?text:String = null, ?img:FlxGraphic = null, ?imgHovered:FlxGraphic = null, ?width:Int = 300, ?height:Int = 100,
			visibleBG:Bool = true) {
		super(x, y);

		var btnBGRect = new Rectangle(0, 0, width / bgScale, height / bgScale);
		var nineSlice = [20, 10, 44, 22];

		btnBG = new FlxUI9SliceSprite(0, 0, Paths.getImagePath('gui/buttonBase'), btnBGRect, nineSlice, 0x11);
		btnBG.setGraphicSize(Std.int(width), Std.int(height));
		btnBG.updateHitbox();
		btnBG.color = btnBGColor;
		btnBG.alpha = btnBGAlpha;
		btnBG.visible = visibleBG;
		add(btnBG);

		btnBGOutline = new FlxUI9SliceSprite(0, 0, Paths.getImagePath('gui/buttonOutline'), btnBGRect, nineSlice, 0x11);
		btnBGOutline.setGraphicSize(Std.int(width), Std.int(height));
		btnBGOutline.updateHitbox();
		btnBGOutline.color = btnBGOutlineColor;
		btnBGOutline.alpha = btnBGAlpha;
		btnBGOutline.visible = visibleBG;
		add(btnBGOutline);

		if (text != null) {
			btnText = new FlxText(0, 0, 0, text);
			btnText.setFormat(Paths.font(btnTextFont), btnTextSize, 0xFFFFFFFF, CENTER);
			btnText.y = (btnBG.height - btnText.height) / 2;
			btnText.alpha = btnTextAlpha;
			add(btnText);
		}
		if (img != null) {
			btnIconImage = img;
			if (imgHovered != null) {
				btnIconImageHovered = imgHovered;
			} else {
				btnIconImageHovered = btnIconImage;
			}
			btnIcon = new FlxSprite(0, 0);
			switchIconImage(btnIconImage);
			add(btnIcon);
		}
		centerStuffOnBG();

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	function centerStuffOnBG() {
		var textWidth = ((btnText != null && btnText.text.length > 0) ? btnText.width : 0);
		var iconWidth = (btnIcon != null ? btnIcon.width : 0);
		var finalWidth = textWidth + iconWidth;
		if (btnText != null) {
			btnText.x = btnBG.x + (btnBG.width - finalWidth) / 2 + iconWidth;
			btnText.y = btnBG.y + (btnBG.height - btnText.height) / 2;
		}
		if (btnIcon != null) {
			btnIcon.x = btnBG.x + (btnBG.width - finalWidth) / 2 - textWidth;
			btnIcon.y = btnBG.y + (btnBG.height - btnIcon.height) / 2;
		}
	}

	private function set_disabled(value:Bool):Bool {
		disabled = value;
		btnBG.color = !value ? btnBGColor : btnBGColorDisabled;
		if (btnText != null)
			btnText.color = !value ? btnTextColor : btnTextColorDisabled;
		return value;
	}

	private function set_btnTextTxt(value:String):String {
		btnTextTxt = value;
		if (btnText != null)
			btnText.text = btnTextTxt;
		centerStuffOnBG();
		return btnTextTxt;
	}

	private function set_btnTextColor(value:FlxColor):FlxColor {
		btnTextColor = value;
		if (btnText != null)
			btnText.color = btnTextColor;
		return btnTextColor;
	}

	private function set_btnTextAlpha(value:Float):Float {
		btnTextAlpha = value;
		if (btnText != null)
			btnText.alpha = btnTextAlpha;
		return btnTextAlpha;
	}

	private function set_btnTextSize(value:Int):Int {
		btnTextSize = value;
		if (btnText != null)
			btnText.size = btnTextSize;
		centerStuffOnBG();
		return btnTextSize;
	}

	private function set_btnTextFont(value:String):String {
		btnTextFont = Paths.font(value);
		if (btnText != null)
			btnText.font = Paths.font(btnTextFont);
		return Paths.font(btnTextFont);
	}

	private function set_btnBGAlpha(value:Float):Float {
		btnBGAlpha = value;
		btnBG.alpha = btnBGAlpha;
		return btnBGAlpha;
	}

	private function set_btnBGColor(value:FlxColor):FlxColor {
		btnBGColor = value;
		btnBG.color = btnBGColor;
		return btnBGColor;
	}

	private function set_btnBGOutlineColor(value:FlxColor):FlxColor {
		btnBGOutlineColor = value;
		btnBGOutline.color = btnBGOutlineColor;
		return btnBGOutlineColor;
	}

	override function update(elapsed:Float) {
		if (FlxG.mouse.overlaps(btnBG, this.camera) && visible) {
			if (!disabled && !hovered) {
				hoverButton();
				if (onHover != null)
					onHover();
				hovered = true;
			}
			if (!disabled && hovered && FlxG.mouse.pressed) {
				if (!clicked)
					clickButton();
				clicked = true;
			}
			if (FlxG.mouse.justReleased && clicked) {
				if (!disabled && onClick != null)
					onClick();
				if (releaseSound != '')
					SuffState.playUISound(Paths.sound(releaseSound));
				idleButton();
				clicked = false;
			}
		} else {
			if (hovered) {
				clicked = false;
				idleButton();
				if (onIdle != null)
					onIdle();
				hovered = false;
			}
		}
		super.update(elapsed);
	}

	function hoverButton() {
		if (disabled)
			return;
		scaleIn();
		tweenColor(!disabled ? btnBGColorHovered : btnBGColorDisabled);
		if (btnText != null && !disabled)
			btnText.color = btnTextColorHovered;
		if (btnIcon != null && !disabled)
			switchIconImage(btnIconImageHovered);
		if (hoverSound != '')
			SuffState.playUISound(Paths.sound(hoverSound));
		if (tooltipText != '')
			Tooltip.text = tooltipText;
	}

	function switchIconImage(img:FlxGraphic) {
		btnIcon.loadGraphic(img);
		btnIcon.setGraphicSize(btnBG.width, btnBG.height);
		btnIcon.updateHitbox();

		centerStuffOnBG();
	}

	function clickButton() {
		if (disabled)
			return;
		tweenColor(!disabled ? btnBGColorClicked : btnBGColorDisabled);
		if (btnText != null && !disabled)
			btnText.color = btnTextColorClicked;
		if (btnIcon != null && !disabled)
			btnIcon.color = btnTextColorClicked;
		if (clickSound != '')
			SuffState.playUISound(Paths.sound(clickSound));
	}

	function idleButton() {
		scaleOut();
		tweenColor(!disabled ? btnBGColor : btnBGColorDisabled);
		if (btnText != null && !disabled)
			btnText.color = btnTextColor;
		if (btnIcon != null && !disabled)
			switchIconImage(btnIconImage);
		if (tooltipText != '')
			Tooltip.text = '';
	}

	function scaleIn() {
		for (tween in btnScaleTweens) {
			if (tween != null)
				tween.cancel();
		}
		var tween1 = FlxTween.tween(btnBG, {'scale.x': bgScale + 0.2, 'scale.y': bgScale + 0.2}, 0.1);
		var tween2 = FlxTween.tween(btnBGOutline, {'scale.x': bgScale + 0.2, 'scale.y': bgScale + 0.2}, 0.1);
		btnScaleTweens.push(tween1);
		btnScaleTweens.push(tween2);
	}

	function scaleOut() {
		for (tween in btnScaleTweens) {
			if (tween != null)
				tween.cancel();
		}
		var tween1 = FlxTween.tween(btnBG, {'scale.x': bgScale, 'scale.y': bgScale}, 0.1);
		var tween2 = FlxTween.tween(btnBGOutline, {'scale.x': bgScale, 'scale.y': bgScale}, 0.1);
		btnScaleTweens.push(tween1);
		btnScaleTweens.push(tween2);
	}

	function tweenColor(finalColor:FlxColor) {
		if (btnBGColorTween != null)
			btnBGColorTween.cancel();
		btnBGColorTween = FlxTween.color(btnBG, 0.1, btnBG.color, finalColor);
	}
}
