package objects;

import backend.types.SkillMetadata;
import tjson.TJSON as Json;

class Skill {
	public var id:String = 'null';
	public var cost:Int = 0;

	public var name:String = 'Unnamed';
	public var description:String = 'No description.';
	public var defaultCost:Int = 0;

	public function new(id:String, cost:Null<Int> = null, costMultiplier:Float = 1) {
		this.id = id;

		var rawJson = Paths.getTextFromFile('data/skills/' + id + '.json');
		var json:SkillMetadata = cast Json.parse(rawJson);

		this.defaultCost = json.defaultCost;
		this.cost = Math.ceil(((cost != null) ? cost : this.defaultCost) * costMultiplier);

		this.name = json.name;
		this.description = json.description;
	}

	public function toString():String {
		return 'Skill(id: ${id} | cost: ${cost})';
	}
}