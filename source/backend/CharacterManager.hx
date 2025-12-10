package backend;

class CharacterManager {
	public static var globalCharacterList:Array<String> = [];
	public static var selectedCharacterList:Array<String> = ['goober', 'goober', 'goober', 'goober'];
	public static var playerControlled:Array<Bool> = [true, false, false, false];
	public static var cpuLevel:Array<Int> = [1, 1, 1, 1];

	public function new() {
		// ass
	}

	public static function pushGlobalCharacterList() {
		globalCharacterList = [];

		// vanilla characters
		#if sys
		var fileList = FileSystem.readDirectory(Paths.getPath('data/characters'));
		#else
		var fileList = Utils.textFileToArray(Paths.getPath('data/characterList.txt'));
		#end

		var dataFolder:String = Paths.getPath('data/characters');
		for (file in fileList) {
			var path = haxe.io.Path.join([dataFolder, file]);
			if (!FileSystem.isDirectory(path) && file.endsWith('.json')) {
				globalCharacterList.push(file.replace('.json', ''));
			}
		}

		#if ALLOW_ADDONS
		var addonPath = Paths.addons();
		for (addonFolder in Addons.getGlobalAddons()) {
			var addonCharacterFolder = haxe.io.Path.join([addonPath, addonFolder, 'data/characters']);
			for (file in FileSystem.readDirectory(addonCharacterFolder)) {
				var path = haxe.io.Path.join([addonCharacterFolder, file]);
				if (!FileSystem.isDirectory(path) && file.endsWith('.json')) {
					globalCharacterList.push(file.replace('.json', ''));
				}
			}
		}
		#end
	}

	public static function parseRandomCharacters() {
		for (i in 0...selectedCharacterList.length) {
			if (selectedCharacterList[i] == 'random') {
				selectedCharacterList[i] = globalCharacterList[FlxG.random.int(0, globalCharacterList.length - 1)];
			}
		}
	}
}
