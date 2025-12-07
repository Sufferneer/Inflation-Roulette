package backend;

import backend.types.AddonData;
import tjson.TJSON as Json;

class Addons {
	private static var globalAddons:Array<String> = [];

	inline public static function getGlobalAddons()
		return globalAddons;

	inline public static function pushGlobalAddons() {
		globalAddons = [];
		for (addon in updateAddonList()) {
			var pack:Dynamic = getPack(addon);
			if (pack != null)
				globalAddons.push(addon);
			trace(addon);
		}
		return globalAddons;
	}

	inline public static function getAddonDirectories():Array<String> {
		var list:Array<String> = [];
		#if ADDONS_ALLOWED
		var addonsFolder:String = Paths.addons();
		if (FileSystem.exists(addonsFolder)) {
			for (folder in FileSystem.readDirectory(addonsFolder)) {
				var path = haxe.io.Path.join([addonsFolder, folder]);
				if (FileSystem.isDirectory(path) && !list.contains(folder))
					list.push(folder);
			}
		}
		#end
		return list;
	}

	public static function getPack(?folder:String = null):AddonData {
		#if ADDONS_ALLOWED
		var path = Paths.addons(folder + '/metadata.json');
		if (FileSystem.exists(path)) {
			try {
				#if sys
				var rawJson:String = File.getContent(path);
				#else
				var rawJson:String = Assets.getText(path);
				#end
				var leParsedJson:AddonData = Json.parse(rawJson);
				if (rawJson != null && rawJson.length > 0)
					return leParsedJson;
			}
			catch (e:Dynamic) {
				trace(e);
			}
		}
		#end
		return null;
	}

	private static function updateAddonList() {
		#if ADDONS_ALLOWED
		var list:Array<String> = [];

		// Scan for folders
		for (folder in getAddonDirectories()) {
			if (folder.trim().length > 0 && FileSystem.exists(Paths.addons(folder)) && FileSystem.isDirectory(Paths.addons(folder))) {
				list.push(folder);
			}
		}

		return list;
		#end
	}
}
