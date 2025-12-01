package objects;

import tjson.TJSON as Json;

typedef SkillMetadata = {
	name:String,
	description:String
}

class Skill {
	public var id:String = 'null';
	public var cost:Int = 0;

	public var name:String = 'Unnamed';
	public var description:String = 'No description.';

	public function new(id, cost) {
		this.id = id;
		this.cost = cost;

		var rawJson = Paths.getTextFromFile('data/skills/' + id + '.json');
		var json:SkillMetadata = cast Json.parse(rawJson);

		this.name = json.name;
		this.description = json.description;
	}

	public function toString():String {
		return 'Modifier(id: ${id} || cost: ${cost})';
	}
}