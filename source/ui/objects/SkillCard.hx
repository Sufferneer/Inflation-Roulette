package ui.objects;

import openfl.filters.ColorMatrixFilter;

class SkillCard extends SuffButton {
	public var skill:Skill;
	public var skillTitle:FlxText;
	public var skillDescription:FlxText;
	public var skillCost:FlxText;

	public var notEnoughConfidence(default, set):Bool = true;

	public function new(x:Float, y:Float, skill:Skill) {
		this.skill = skill;
		var usedImage = Paths.image('gui/skill_card');
		var usedImageHovered = Paths.image('gui/skill_card_highlighted');
		super(x, y, null, usedImage, usedImageHovered, usedImage.width, usedImage.height, false);

		skillTitle = new FlxText(usedImage.height, 8, usedImage.width - usedImage.height - 6, skill.name);
		skillTitle.setFormat(Paths.font('default'), 32, FlxColor.WHITE);
		add(skillTitle);

		skillDescription = new FlxText(usedImage.height, 8 + skillTitle.height, usedImage.width - usedImage.height - 6, skill.description);
		skillDescription.setFormat(Paths.font('default'), 16, FlxColor.WHITE);
		skillDescription.alpha = 0.5;
		add(skillDescription);

		skillCost = new FlxText(usedImage.height, usedImage.height - 24 - 6 - 6, 0, 'Cost: ' + skill.cost);
		skillCost.setFormat(Paths.font('default'), 24, FlxColor.WHITE);
		add(skillCost);
	}

	private function set_notEnoughConfidence(value:Bool):Bool{
		notEnoughConfidence = value;
		this.disabled = notEnoughConfidence;
		if (notEnoughConfidence) {
			this.btnIcon.color = 0xFF808080;
			this.alpha = 0.6;
			skillCost.text = 'Cost: ${skill.cost}';
			skillCost.color = 0xFFC00000;
		} else {
			this.btnIcon.color = 0xFFFFFFFF;
			this.alpha = 1;
			skillCost.text = 'Cost: ${skill.cost}';
			skillCost.color = FlxColor.PURPLE;
		}
		return value;
	}
}