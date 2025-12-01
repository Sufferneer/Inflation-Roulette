package states;

import flixel.system.FlxBasePreloader;
import openfl.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.Lib;
import flixel.FlxG;

@:bitmap("assets/images/gui/menus/loading/cri_de_sad_gold.png") class LogoImage extends BitmapData {
}

@:font("assets/fonts/default.ttf") class CustomFont extends Font {
}

class PreloadState extends FlxBasePreloader {
	public function new(MinDisplayTime:Float = 3, ?AllowedURLs:Array<String>) {
		#if (!windows && !mac && !linux)
		super(MinDisplayTime, AllowedURLs);
		#else
		super(0, AllowedURLs);
		#end
	}

	var logo:Sprite;
	var text:TextField;

	override function create():Void {
		super.create();

		this._width = Std.int(Lib.current.stage.stageWidth);
		this._height = Std.int(Lib.current.stage.stageHeight);

		logo = new Sprite();
		logo.addChild(new Bitmap(new LogoImage(0, 0))); // Sets the graphic of the sprite to a Bitmap object, which uses our embedded BitmapData class.
		addChild(logo);

		Font.registerFont(CustomFont);
		text = new TextField();
		text.defaultTextFormat = new TextFormat("Suffirat Regular", 96, 0xffffff, false, false, false, "", "", TextFormatAlign.CENTER);
		text.embedFonts = true;
		text.selectable = false;
		text.multiline = true;
		text.x = 0;
		text.y = 5 * _height / 6;
		text.width = _width;
		text.text = '0%';
		addChild(text);
	}

	override function update(Percent:Float):Void {
		logo.scaleX = 1 + Percent;
		logo.x = (this._width - logo.width) * 0.5;
		logo.y = (this._height - logo.height) * 0.5;

		text.text = '${Std.int(Percent * 100)}%';

		super.update(Percent);
	}
}
