package ui.objects;

import substates.HyperlinkPrompt;

class GitHubButton extends SuffIconButton {
	public function new(x:Float, y:Float, directory:String = '') {
		super(x, y, 'buttons/github', 2);

		this.btnBGColor = 0xFF000000;
		this.btnBGColorHovered = 0xFF000000;
		this.btnBGColorClicked = 0xFF808080;
		this.btnBGColorDisabled = 0xFFFFFFFF;
		this.btnOutlineColor = this.btnOutlineColorDisabled = 0xFF808080;
		this.btnOutlineColorHovered = this.btnOutlineColorClicked = 0xFFFFFFFF;
		this.btnTextColor = this.btnTextColorHovered = this.btnTextColorClicked = 0xFFFFFFFF;
		this.btnTextColorDisabled = 0xFF96A199;

		this.onClick = function() {
			FlxG.state.openSubState(new HyperlinkPrompt('https://github.com/Sufferneer/Inflation-Roulette-Reloaded/' + directory));
		};
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
