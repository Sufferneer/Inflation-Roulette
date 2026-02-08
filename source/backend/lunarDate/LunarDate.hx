package backend.lunarDate;

/**
 * This script is copied from https://github.com/R32/lunar
 */
class LunarDate {
	public var time(default, null):Date; // Gregorian calendar time
	public var info(default, null):Info;
	public var year(default, null):Int; // Lunar year
	public var month(default, null):Int; // Lunar month [1 ~ 12]
	public var day(default, null):Int; // Lunar day
	public var leap(default, null):Bool; // Whether the current date is in a "leap month"

	private function new(ly:Int, lm:Int, ld:Int, le:Bool, ds:Int, t:Date, i:Info) {
		this.year = ly;
		this.month = lm;
		this.day = ld;
		this.leap = le;
		this.time = t;
		this.info = i;
	}

	public static inline function getYearIndex(y:Int):Int {
		return (y - 4) % 12;
	}

	public function toString():String {
		var year = this.year;
		var leYear = LunarDateConstants.NUMBERS[Std.int(year / 1000) % 10] + LunarDateConstants.NUMBERS[Std.int(year / 100) % 10]
			+ LunarDateConstants.NUMBERS[Std.int(year / 10) % 10] + LunarDateConstants.NUMBERS[Std.int(year % 10)];

		var leMonth = LunarDateConstants.MONTHS[this.month - 1];

		var offsetYear = this.year - 4;
		var leZodiac = LunarDateConstants.ZODIAC[offsetYear % 12];
		var leStem = LunarDateConstants.STEMS[offsetYear % 10];
		var leBranch = LunarDateConstants.BRANCHES[offsetYear % 12];

		var day = this.day;
		var leDate = '';
		if (day < 11) {
			leDate = LunarDateConstants.ONE_PREFIX + LunarDateConstants.NUMBERS[day];
		} else if (day < 20) {
			leDate = LunarDateConstants.TEN_PREFIX + LunarDateConstants.NUMBERS[day - 10];
		} else {
			if (day == 20)
				day = 30;
			leDate = LunarDateConstants.TWENTY_PREFIX + LunarDateConstants.NUMBERS[day - 20];
		}
		var leMonthPrefix = this.leap ? LunarDateConstants.LEAP_MONTH_PREFIX : "";
		var leYearSuffix = LunarDateConstants.YEAR;

		return '$leYear$leYearSuffix（$leStem$leBranch$leYearSuffix）・$leMonthPrefix$leMonth$leDate・$leZodiac$leYearSuffix';
	}

	public static inline function now():LunarDate {
		return LunarDate.make(Date.now());
	}

	public static function make(time:Date) {
		var h = Std.int(time.getTime() / LunarDateConstants.HOUR_TO_MICROSECONDS);
		var tyear = time.getFullYear();
		var start = getCacheByYear(tyear);
		var diff = Std.int((h - start) / 24); // HOURS to DAYS
		if (diff < 0) {
			--tyear;
			start = getCacheByYear(tyear);
			diff = Std.int((h - start) / 24);
		}
		var ds = diff;
		var tinfo = new Info(tyear);
		// Month
		var tmonth = 1;
		var tdate = 1;
		var tleap = false;
		for (i in 0...12) {
			var t = tinfo.isLongMonth(tmonth) ? 30 : 29;
			if (diff > t) {
				++tmonth;
				diff -= t;
			} else {
				break;
			}
			if (tinfo.leap == tmonth - 1) {
				var t = tinfo.leapLong ? 30 : 29;
				if (diff > t) {
					diff -= t;
					tleap = false;
				} else {
					--tmonth;
					tleap = true;
					break;
				}
			}
		}
		tdate += diff;
		return new LunarDate(tyear, tmonth, tdate, tleap, ds, time, tinfo);
	}

	/*
	 *
	 * @param ly Year; Ranges from 1900 to 2010.
	 * @param lm Month; Ranges from 1 to 12.
	 * @param ld Date; Ranges from 1 to 30.
	 * @param isLeap Whether the current year is a leap year.
	 * @return
	 */
	public static function spec(ly:Int, lm:Int, ld:Int, isLeap:Bool):LunarDate {
		var start = getCacheByYear(ly);
		var info = new Info(ly);
		var ds = 0;
		// 月
		var leap = info.leap;
		for (m in 1...lm) {
			ds += info.isLongMonth(m) ? 30 : 29;
			if (leap == m)
				ds += info.leapLong ? 30 : 29;
		}
		if (info.leap == lm && isLeap == true) {
			ds += info.isLongMonth(lm) ? 30 : 29;
		}
		// 日
		ds += ld - 1;
		var time = Date.fromTime((start + ds * 24) * LunarDateConstants.HOUR_TO_MICROSECONDS);
		return new LunarDate(ly, lm, ld, isLeap && info.leap == lm, ds, time, info);
	}

	static inline function getCacheByYear(y:Int)
		return getCache(y - Info.DAT_START);

	static function getCache(i:Int):Int {
		if (CACHES == null) {
			CACHES = new haxe.ds.Vector<Int>(Info.DAT_LENGTH);
			CACHES[0] = Std.int(new Date(1970, 1, 6, 0, 0, 0).getTime() / LunarDateConstants.HOUR_TO_MICROSECONDS);
			CI = 1;
		}
		while (i >= CI) {
			var c = CACHES[CI - 1];
			var info = new Info(CI + (Info.DAT_START - 1)); // (CI - 1 + DAT_START)
			CACHES[CI++] = c + info.getDayCountInYear() * 24;
		}
		return CACHES.get(i);
	}
	
	static var CI:Int;
	static var CACHES:haxe.ds.Vector<Int>;
}

abstract Info(Int) {
	public var leap(get, never):Int;
	public var longMonths(get, never):Int;
	public var leapLong(get, never):Bool;

	inline function get_leap()
		return this & 0xF;

	inline function get_longMonths()
		return (this >> 4) & 0xFFF;

	inline function get_leapLong()
		return (this & 0x10000) != 0;

	/*
	 * lyear : Lunar year
	 */
	inline public function new(lyear:Int)
		reset(lyear);

	inline public function reset(lyear:Int)
		this = DAT[index(lyear)];

	inline function leapDays()
		return leap > 0 ? (leapLong ? 30 : 29) : 0;

	/*
	 * Returns the number of days in the current year.
	 */
	public function getDayCountInYear() {
		var sum = 348;
		for (i in 4...12 + 4) {
			sum += (this >> i) & 1;
		}
		return sum + leapDays();
	}

	/*
	 * m in [1-12]
	 */
	inline public function isLongMonth(m:Int):Bool {
		return this & (1 << (16 - m)) != 0;
	}

	public inline function toString() {
		return '[DATA: 0x${StringTools.hex(this, 5)}, leap: ${leap}, leapLong: ${leapLong}, longMonths: ${binString(longMonths, 12)}]';
	}

	// binString(0xF, 8) => "00001111"
	static function binString(x:Int, w:Int) {
		var ret = [];
		ret[w - 1] = 0;
		for (i in 0...w)
			ret[i] = (x >> (w - i - 1)) & 1;
		return ret.join("");
	}

	public static inline function index(lyear:Int)
		return lyear - DAT_START;

	public static inline var DAT_START = 1970;
	public static inline var DAT_LENGTH = 2100 - 1970 + 1;

	/*
	 * 0000 0000 0000 0000 0000  - BIT
	 *                    |3210| - Not a leap year: 0, Leap year: Leap year month no. [1 - 12]
	 *     |1234 5678 9ABC|      - 1: Long month (30 Days), 0: Short month (29 Days). Note: Indices for January to December is F(15) - 4
	 *   |1|                     - 16th index, 1: Long leap month, 0: Short leap month, Used only if Leap > 0.
	 * 
	 * Copied from https://github.com/QingYolan/Calendar/blob/gh-pages/js/data.js
	 */
	static var DAT = [
		0x096d0,
		0x04dd5,
		0x04ad0,
		0x0a4d0,
		0x0d4d4,
		0x0d250,
		0x0d558,
		0x0b540,
		0x0b5a0,
		0x195a6,
		0x095b0,
		0x049b0,
		0x0a974,
		0x0a4b0,
		0x0b27a,
		0x06a50,
		0x06d40,
		0x0af46,
		0x0ab60,
		0x09570,
		0x04af5,
		0x04970,
		0x064b0,
		0x074a3,
		0x0ea50,
		0x06b58,
		0x055c0,
		0x0ab60,
		0x096d5,
		0x092e0, /* 1999 */
		0x0c960,
		0x0d954,
		0x0d4a0,
		0x0da50,
		0x07552,
		0x056a0,
		0x0abb7,
		0x025d0,
		0x092d0,
		0x0cab5,
		0x0a950,
		0x0b4a0,
		0x0baa4,
		0x0ad50,
		0x055d9,
		0x04ba0,
		0x0a5b0,
		0x15176,
		0x052b0,
		0x0a930,
		0x07954,
		0x06aa0,
		0x0ad50,
		0x05b52,
		0x04b60,
		0x0a6e6,
		0x0a4e0,
		0x0d260,
		0x0ea65,
		0x0d530,
		0x05aa0,
		0x076a3,
		0x096d0,
		0x04bd7,
		0x04ad0,
		0x0a4d0,
		0x1d0b6,
		0x0d250,
		0x0d520,
		0x0dd45,
		0x0b5a0,
		0x056d0,
		0x055b2,
		0x049b0,
		0x0a577,
		0x0a4b0,
		0x0aa50,
		0x1b255,
		0x06d20,
		0x0ada0, /* 2049 */
		0x14b63, /* 2050 */
		0x09370,
		0x049f8,
		0x04970,
		0x064b0,
		0x168a6,
		0x0ea50,
		0x06b20,
		0x1a6c4,
		0x0aae0,
		0x0a2e0,
		0x0d2e3,
		0x0c960,
		0x0d557,
		0x0d4a0,
		0x0da50,
		0x05d55,
		0x056a0,
		0x0a6d0,
		0x055d4,
		0x052d0,
		0x0a9b8,
		0x0a950,
		0x0b4a0,
		0x0b6a6,
		0x0ad50,
		0x055a0,
		0x0aba4,
		0x0a5b0,
		0x052b0,
		0x0b273,
		0x06930,
		0x07337,
		0x06aa0,
		0x0ad50,
		0x14b55,
		0x04b60,
		0x0a570,
		0x054e4,
		0x0d160,
		0x0e968,
		0x0d520,
		0x0daa0,
		0x16aa6,
		0x056d0,
		0x04ae0,
		0x0a9d4,
		0x0a2d0,
		0x0d150,
		0x0f252,
		0x0d520 /* 2100 */];
}
