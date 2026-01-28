package backend;

class VersionMetadata {
	public static var majorVersionMap:Map<String, String> = [
		'0' => 'Closed Beta',
		'1' => 'Initial Release',
		/*
		'2' => nuh uh
		*/
	];

	public static function getVersionName(version:String) {
		var arr = version.split('.');
		var major = majorVersionMap.get(arr[0]);
		var minorText = '';
		if (Std.parseInt(arr[1]) > 0)
			minorText = ' (Release ${arr[1]})';
		return major + minorText;
	}

	public function new() {
	}
}
