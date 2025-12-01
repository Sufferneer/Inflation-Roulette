package backend;

class Constants {
	public static final TO_DEGREES:Float = 180 / Math.PI;
	public static final TO_RADIANS:Float = Math.PI / 180;

	public static final CYLINDER_CAPACITY:Int = 6;

	public static final MONOCHROME_BRIGHTNESS:Float = 1 / 3;
	public static var DEFAULT_CAMERA_FOLLOW_LERP:Float = 0.1;

	public static final GURGLES_SAMPLE_COUNT:Int = 10; // if it's set higher than than it crashes idk why
	public static final CREAKS_SAMPLE_COUNT:Int = 9;
	public static final FWOOMPS_SAMPLE_COUNT:Int = 4;
}
