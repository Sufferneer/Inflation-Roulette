package ui.objects;

import flixel.graphics.FlxGraphic;

class GitHubButton extends SuffIconButton {
	public function new(x:Float, y:Float, directory:String = '') {
		super(x, y, 'buttons/github');

		this.btnBGColor = 0xFF000000;
		this.btnBGColorHovered = 0xFF202020;
		this.btnBGOutlineColor = 0xFFC0C0C0;

		this.onClick = function () {
			Utils.browserLoad('https://github.com/Sufferneer/Inflation-Roulette/' + directory);
		};
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
