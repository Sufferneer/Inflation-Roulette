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

@:bitmap("assets/images/gui/menus/loading/criDeSadGold.png") class LogoImage extends BitmapData {
}

@:bitmap("assets/images/gui/menus/loading/loadingText.png") class LoadingTextImage extends BitmapData {
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
	var text:Sprite;

	override function create():Void {
		super.create();

		this._width = Std.int(Lib.current.stage.stageWidth);
		this._height = Std.int(Lib.current.stage.stageHeight);

		logo = new Sprite();
		logo.addChild(new Bitmap(new LogoImage(0, 0))); // Sets the graphic of the sprite to a Bitmap object, which uses our embedded BitmapData class.
		addChild(logo);

		text = new Sprite();
		text.addChild(new Bitmap(new LoadingTextImage(0, 0)));
		addChild(text);
	}

	override function update(Percent:Float):Void {
		logo.scaleX = 1 + Percent;
		logo.x = (this._width - logo.width) / 2;
		logo.y = (this._height - logo.height) * 0.3;

		text.scaleX = 1 + Percent * 6;
		text.x = (this._width - text.width) / 2;
		text.y = (this._height - text.height) * 0.75;

		super.update(Percent);
	}
}
