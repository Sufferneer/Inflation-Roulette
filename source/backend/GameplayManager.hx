package backend;

import backend.Gamemode;

class GameplayManager {
	public static var currentBackground:String = 'classic';

	public static var defaultGamemode:Gamemode;
	public static var currentGamemode:Gamemode;

	public function new() {
		// ass
	}

	public static function initialize() {
		defaultGamemode = new Gamemode('reloaded');
		currentGamemode = new Gamemode('reloaded');
	}
}
