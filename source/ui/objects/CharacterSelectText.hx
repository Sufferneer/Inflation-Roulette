package ui.objects;

import backend.types.CharacterData;
import backend.types.SkillData;
import backend.enums.CharacterSelectSubstring;
import ui.objects.GameIcon;

class CharacterSelectText extends FlxSpriteGroup {
	static final substringList:Array<CharacterSelectSubstring> = [MAX_PRESSURE, MAX_CONFIDENCE, SKILLS, DESCRIPTION];
	static final separator:String = '·';
	static final size:Int = 32;

	public function new(x:Float, y:Float, character:CharacterData) {
		super(x, y);

		reloadText();
	}

	public function reloadText(character:CharacterData = null) {
		var textX:Float = 0;
		for (item in members) {
			item.kill();
			item.destroy();
		}
		this.clear();
		if (character == null) { // Default character data
			var text:FlxText = new FlxText(0, 0, 0, 'Hold Cards To See Info');
			text.setFormat(Paths.font('default'), size, FlxColor.WHITE);
			add(text);
		} else if (character.id == 'random') {
			var text:FlxText = new FlxText(0, 0, 0, 'Not sure who to choose? Let the game decide.');
			text.setFormat(Paths.font('default'), size, FlxColor.WHITE);
			add(text);
		} else {
			for (item in substringList) {
				var subString:String = '';
				var icons:Array<String> = [];
				switch (item) {
					case DESCRIPTION:
						subString = character.description;
					case MAX_PRESSURE:
						for (i in 0...character.maxPressure) {
							icons.push('stats/pressure');
						};
					case MAX_CONFIDENCE:
						for (i in 0...character.maxConfidence) {
							icons.push('stats/confidence');
						};
					case SKILLS:
						var skillData:Array<SkillData> = cast character.skills;
						for (skill in skillData) {
							icons.push('skills/${skill.id}');
						}
					default:
						// idk lol
				}
				// Text
				var text:FlxText = new FlxText(textX, 0, 0, subString);
				text.setFormat(Paths.font('default'), size, FlxColor.WHITE);
				add(text);
				if (subString.length > 0)
					textX += text.width;

				// Icons
				for (i in 0...icons.length) {
					var icon:GameIcon = new GameIcon(textX, 0, icons[i], size);
					add(icon);
					if (i < icons.length)
						textX += 32;
				}

				// Seperator
				if (substringList.indexOf(item) < substringList.length - 1) {
					textX += 8;
					var text:FlxText = new FlxText(textX, 0, 0, separator);
					text.setFormat(Paths.font('default'), size, FlxColor.WHITE);
					add(text);
					textX += text.width + 8;
				}
			}
		}
		//updateHitbox();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
