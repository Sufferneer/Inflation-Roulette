package ui;

import flixel.FlxSubState;
import flixel.FlxState;

class SuffSubState extends FlxSubState {
	public var timePassedOnSubState:Float = 0;

	override function new() {
		super();

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	override function update(elapsed:Float) {
		if (!persistentUpdate)
			SuffState.timePassedOnState += elapsed;

		timePassedOnSubState += elapsed;

		super.update(elapsed);
	}
}
