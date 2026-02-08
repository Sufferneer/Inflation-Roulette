package ui.objects;

import objects.Skill;

class SkillCard extends SuffButton {
	public var skill:Skill;
	var skillTitle:FlxText;
	var skillDescription:FlxText;
	var skillCost:FlxText;
	var skillIcon:GameIcon;

	var costIcon:GameIcon;

	public var notEnoughConfidence(default, set):Bool = true;

	public function new(x:Float, y:Float, skill:Skill) {
		this.skill = skill;
		var usedImage = Paths.image('gui/skillCard');
		var usedImageHovered = Paths.image('gui/skillCardHighlighted');
		super(x, y, null, usedImage, usedImageHovered, usedImage.width, usedImage.height, false);

		skillIcon = new GameIcon(5, 5, 'skills/${skill.id}', 110);
		skillIcon.alpha = 0.75;
		add(skillIcon);

		skillTitle = new FlxText(usedImage.height, 8, usedImage.width - usedImage.height - 6, skill.name);
		skillTitle.setFormat(Paths.font('default'), 32, FlxColor.WHITE);
		add(skillTitle);

		skillDescription = new FlxText(usedImage.height, 8 + skillTitle.height, usedImage.width - usedImage.height - 6, skill.description);
		skillDescription.setFormat(Paths.font('default'), 16, FlxColor.WHITE);
		skillDescription.alpha = 0.5;
		add(skillDescription);

		costIcon = new GameIcon(usedImage.height, usedImage.height - 40, 'stats/confidence', 32);
		costIcon.color = 0xFF4A4399;
		add(costIcon);

		skillCost = new FlxText(usedImage.height + costIcon.width + 2, usedImage.height - 40, 0, '' + skill.cost);
		skillCost.setFormat(Paths.font('default'), 32, costIcon.color);
		add(skillCost);

		// skillCost.visible = costIcon.visible = (skill.cost > 0);
	}

	private function set_notEnoughConfidence(value:Bool):Bool{
		notEnoughConfidence = value;
		this.disabled = notEnoughConfidence;
		if (notEnoughConfidence) {
			this.btnIcon.color = 0xFF808080;
			this.alpha = 0.6;
			skillCost.text = '${skill.cost} · <>';
			costIcon.color = skillCost.color = 0xFFC00000;
		} else {
			this.btnIcon.color = 0xFFFFFFFF;
			this.alpha = 1;
			skillCost.text = '${skill.cost}';
			costIcon.color = skillCost.color = 0xFF4A4399;
		}
		return value;
	}
}