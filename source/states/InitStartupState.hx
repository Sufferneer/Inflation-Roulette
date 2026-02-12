package states;

import states.easterEggStartups.*;

class InitStartupState extends SuffState {
	override function create() {
		super.create();

		new FlxTimer().start(1.5, function(tmr:FlxTimer) {
			#if _ALLOW_EASTER_EGGS
			var startupState = '';
			if (FlxG.save.data != null && FlxG.save.data.easterEggStartup != null)
				startupState = FlxG.save.data.easterEggStartup;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			switch (startupState) {
				case 'imhighoncrack':
					SuffState.switchState(new ImHighOnCrackStartupState());
				case 'blueberryhelium':
					SuffState.switchState(new BlueberryHeliumStartupState());
				case 'roomoneoone':
					SuffState.switchState(new RoomOneOOneStartupState());
				case 'ibeesbees':
					SuffState.switchState(new IBeesBeesStartupState());
				default:
					SuffState.switchState(new StartupState());
			}
			#else
			SuffState.switchState(new StartupState());
			#end
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
