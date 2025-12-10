package backend;

class VersionMetadata {
	public static var majorVersionMap:Map<String, String> = [
		'0' => 'Closed Beta',
		'1' => 'Initial Release'
	];

	public static var minorVersionMap:Map<String, String> = [
		'0' => 'Initial Release',
		'1' => 'Modder\'s Catalogue',
		'2' => 'Better Together',
		'3' => 'The Chamber Spins',
		'4' => 'Hit the Stage'
	];

	public static function getVersionName(version:String) {
		var arr = version.split('.');
		var major = majorVersionMap.get(arr[0]);
		var minor = minorVersionMap.get(arr[1]);
		if (major != minor) {
			return minor;
		}
		return major;
	}

	public function new() {
	}
}
