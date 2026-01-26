package backend;

import backend.lunarDate.LunarDate;
import backend.types.SplashCollectionData;
import backend.types.SplashGroupData;
import tjson.TJSON as Json;

class SplashManager {
	public static var activeSplashes:Array<String> = [];
	public static var activeColors:Array<FlxColor> = [];

    public function new() {
        // Constructor
    }

	public static function parseSplashes() {
		activeSplashes = [];

		var rawJson = Paths.getTextFromFile('data/splashes.json');
		var collection:SplashCollectionData = cast Json.parse(rawJson);

		var gregorianCurrentTime = Date.now();
		var lunarCurrentTime = LunarDate.now();
		trace(gregorianCurrentTime);
		trace(lunarCurrentTime);

		for (splash in collection.shared) {
			activeSplashes.push(splash);
		}

		var hasUnique:Bool = false;
		for (grp in collection.unique) {
			var group:SplashGroupData = cast grp;
			if (group.start != null && group.end != null) {
				var currentMonth:Int = 1;
				var currentDay:Int = 1;
				if (!group.useLunarCalender) {
					currentMonth = gregorianCurrentTime.getMonth() + 1;
					currentDay = gregorianCurrentTime.getDate();
				} else {
					currentMonth = lunarCurrentTime.month;
					currentDay = lunarCurrentTime.month;
				}

				var leStartDate:Array<Dynamic> = group.start.split('-');
				var leEndDate:Array<Dynamic> = group.end.split('-');
				for (s in 0...leStartDate.length) {
					leStartDate[s] = Std.parseInt(leStartDate[s]);
				}
				for (s in 0...leEndDate.length) {
					leEndDate[s] = Std.parseInt(leEndDate[s]);
				}
				if (currentMonth >= leStartDate[0] && currentMonth <= leEndDate[0]) {
					if (currentDay >= leStartDate[1] && currentDay <= leEndDate[1]) {
						hasUnique = true;
						for (splash in group.splashes) {
							activeSplashes.push(splash);
						}
						for (color in group.colors) {
							activeColors.push(FlxColor.fromString(color));
						}
					}
				}
			}
		}

		if (!hasUnique) {
			for (splash in collection.fallback) {
				activeSplashes.push(splash);
			}
			activeColors = Constants.DEFAULT_SPLASH_TEXT_COLORS;
		}

		trace(activeSplashes);
		trace(activeColors);
	}
}