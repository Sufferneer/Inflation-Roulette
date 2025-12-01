package backend.types;

import backend.types.ModifierData;
import backend.types.SkillData;

typedef CharacterData = {
	name:String,
	description:String,
	maxPressure:Int,
	maxConfidence:Int,
	modifiers:Array<ModifierData>,
	skills:Array<SkillData>
}