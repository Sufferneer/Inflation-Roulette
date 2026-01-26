package backend.lunarDate;

class LunarDateConstants {
	public static final HOUR_TO_MICROSECONDS:Float = 1.0 * 60 * 60 * 1000;

	public static final ONE_PREFIX:String = '初';
	public static final TEN_PREFIX:String = '十';
	public static final TWENTY_PREFIX:String = '廿';
	public static final LEAP_MONTH_PREFIX:String = '閏';
	public static final YEAR:String = '年';

	public static final MONTHS:Array<String> = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "臘月"];
	public static final NUMBERS:Array<String> = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"];
	public static final ZODIAC:Array<String> = ["鼠", "牛", "虎", "兔", "龍", "蛇", "馬", "羊", "猴", "雞", "狗", "豬"];
	public static final BRANCHES:Array<String> = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"];
}
