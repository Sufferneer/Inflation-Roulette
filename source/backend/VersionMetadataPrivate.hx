package backend;

class VersionMetadata {
	public static var majorVersionMap:Map<String, String> = [
		'0' => 'Closed Beta',
		'1' => 'Initial Release',
		'2' => 'Modder\'s Catalogue',
		'3' => 'Better Together',
		'4' => 'The Chamber Flips',
		'5' => 'Hit the Stage'
	];

	public static function getVersionName(version:String) {
		var arr = version.split('.');
		var text = majorVersionMap.get(arr[0]);
		text += '(';
		if (Std.parseInt(arr[1]) > 0)
			text += ' Pitstop ${arr[1]}';
		if (arr[2] != null && Std.int(arr[2]) > 0)
			text += ' Hotfix ${arr[2]}';
		text += ')';
		return text;
	}

	public function new() {
	}
}
