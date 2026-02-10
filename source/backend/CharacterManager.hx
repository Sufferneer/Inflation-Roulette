package backend;

class CharacterManager {
	public static var globalCharacterList:Array<String> = [];
	public static var selectedCharacterList:Array<String> = ['goober', 'goober', 'goober', 'goober'];
	public static var playerControlled:Array<Bool> = [true, false, false, false];
	public static var cpuLevel:Array<Int> = [1, 1, 1, 1];

	public function new() {
		// ass
	}

	public static function initialize() {
		globalCharacterList = Paths.readFolderDirectories('data/characters', 'data/characterList.txt', 'gameplay.json');
	}

	public static function parseRandomCharacters() {
		for (i in 0...selectedCharacterList.length) {
			if (selectedCharacterList[i] == 'random') {
				selectedCharacterList[i] = globalCharacterList[FlxG.random.int(0, globalCharacterList.length - 1)];
			}
		}
	}
}
