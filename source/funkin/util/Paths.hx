package funkin.util;

#if desktop
import sys.FileSystem;
#end

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	public static var currentLevel(default, set):String;

	public static function set_currentLevel(value:String)
		return currentLevel = value.toLowerCase();

	inline static public function exists(file:String, type:AssetType):Bool {
		#if desktop
		return FileSystem.exists(removeAssetLib(file));
		#else
		return OpenFlAssets.exists(file, type);
		#end
	}
}