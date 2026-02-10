package backend;

class PlatformMetadata {
	#if _ALLOW_BUILD_HANDLING
	public static final platformFormattedNames:Map<String, String> = [
		'windows' => 'Windows',
		'linux' => 'Linux',
		'macos' => 'macOS',
		'android' => 'Android',
		'ios' => 'iOS',
		'html5' => 'HTML5',
		'unknown' => 'UNKNOWN'
	];

	public static function getBuildID() {
		#if windows
		return 'WINDOWS';
		#elseif linux
		return 'LINUX';
		#elseif mac
		return 'MACOS';
		#elseif android
		return 'ANDROID';
		#elseif ios
		return 'IOS';
		#elseif html5
		return 'HTML5';
		#else
		return 'UNKNOWN';
		#end
	}

	public static function getBuildName() {
		return platformFormattedNames.get(getBuildID().toLowerCase());
	}
	#end

	public function new() {}
}
