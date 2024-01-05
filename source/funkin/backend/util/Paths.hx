package funkin.backend.util;

#if desktop
import sys.FileSystem;
#end

class Paths
{
	inline private static final SOUND_EXT = #if web "mp3" #else "ogg" #end;
	public static var currentLevel(default, set):String;

	public static var modsFolders:Array<String> = [];
	public static var currentModDirectory:String;
	public static var ignoreModFolders:Array<String> = [
		'data',
		'fonts',
		'images',
		'songs',
		'music',
		'sounds',
		'source',
		'shaders',
		'videos',
		'source'
	];

	private static function set_currentLevel(value:String)
		return currentLevel = value.toLowerCase();

	inline public static function reloadModsPaths()
	{
		final modsFolderDirectory = modsDirectory();
		for (folder in FileSystem.readDirectory(modsFolderDirectory)) if (FileSystem.isDirectory(folder) && !modsFolders.contains(folder) && !ignoreModFolders.contains(folder)) modsFolders.push(folder);

				/*final path = haxe.io.Path.join([modsFolderDirectory, folder]);
			    if (sys.FileSystem.isDirectory(path) && !modsFolder.contains(folder)) {
			    	modsFolder.push(folder);
			    }*/
	}

	public static function getPath(file:String, ?library:Null<String> = null, ?modsAllowed:Bool = true):String
	{
		while(file.contains("//")) 
			file = file.replace("//", "/");

		if(modsAllowed)
		{
			final modded = modFolders(file);
			if(FileSystem.exists(modded)) return modded;
		}
		
		if (library != null) return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			final levelPath = getLibraryPathForce(file, currentLevel);
			if (FileSystem.exists(levelPath)) return levelPath;
		}

		return getPreloadPath(file);
	}

	inline static public function data(key:String, ?library:String, ?mods:Bool = true)
	{
		return getPath('data/$key', library, mods);
	}

	static public function getLibraryPath(file:String, library = "assets")
	{
		return if (library == "assets" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline public static function image(path:String, ?library:String):String
	{
		return getPath('images/$path.png', library);
	}

	inline public static function sound(path:String):String
	{
		return getSoundFile(path, 'sounds');
	}

	inline public static function music(path:String):String
	{
		return getSoundFile(path, 'music');
	}
	
	static public function getSoundFile(path:String, ?directory:String = 'sounds', ?library:String):String
	{
		return getPath('$directory/$path.$SOUND_EXT', library);
	}
	/*
	lime.utils.Assets.cache.clear();
	openfl.utils.Assets.cache.clear();
	*/

	inline static public function modsDirectory(key:String = ''):String {
		return 'mods/' + key;
	}

	static public function modFolders(key:String) {
		if(currentModDirectory != null && currentModDirectory.length > 0) {
			var fileToCheck:String = modsDirectory('$currentModDirectory/' + key);
			if(FileSystem.exists(fileToCheck)) return fileToCheck;
		}
		return modsDirectory(key);
	}

	inline public static function fileExists(path:String, ?ignoreMods:Bool = false, ?library:String = null):Bool
	{
		trace(path);
		trace(getPath(path, library));
		trace(modsDirectory(currentModDirectory + path));

		if (!ignoreMods && currentModDirectory != null && currentModDirectory.length > 0 && FileSystem.exists(modsDirectory(currentModDirectory + path))) return true;

		return FileSystem.exists(getPath(path, library, false));
	}

        public static function download(leUrl:String, path:String):Void {
            var http = new Http(leUrl);
            var output:BytesOutput = new BytesOutput();
            http.customRequest(false, output);
            File.saveBytes(path, output.getBytes());
        }

	//GAMEPLAY STUFF
	inline static public function chart(song:String, ?key:String = 'normal')
	{
		return getPath('data/$song/$key.json', TEXT);
	}

	inline static public function songAudio(song:String, file:String = 'Inst', ?postfix:String = ''):Any
	{
		final fileKey:String = '${formatToSongPath(song)}/$file' + postfix;
		return returnSound('songs', fileKey);
	}


	/*inline static public function songAudio(song:String, ?postfix:String = ''):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Voices'+postfix;
		trace(songKey);
		var voices = returnSound('songs', songKey);
		return voices;
	}*/
}