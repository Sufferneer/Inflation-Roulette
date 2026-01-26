package backend.types;

/**
 * Group of splashes associated with a specific time period.
 */
typedef SplashGroupData = {
	/**
	 * The ID of the splash group. (e.g. christmas, newyearseve)
	 */
	id:String,
	/**
	 * The period name of the splash group. (e.g. Christmas, New Year's Eve)
	 */
	name:String,
	/**
	 * The list of colors in hexadecimal format displayed on the splash text.
	 */
	colors:Array<String>,
	/**
	 * The starting date (inclusive).
	 */
	useLunarCalender:Bool,
	/**
	 * Whether the Lunar calendar is used.
	 */
	start:String,
	/**
	 * The ending date (inclusive).
	 */
	end:String,
	/**
	 * The splashes to use during this period.
	 */
	splashes:Array<String>
}
