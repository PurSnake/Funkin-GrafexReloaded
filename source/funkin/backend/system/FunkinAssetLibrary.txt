package funkin.system;

class FunkinAssetLibrary extends lime.utils.AssetLibrary
{
	public override function exists(id:String, type:String):Bool
	{
		var requestedType = type != null ? cast(type, AssetType) : null;
		var assetType = types.get(id);

		if (assetType != null)
		{
			if (assetType == requestedType
				|| ((requestedType == SOUND || requestedType == MUSIC) && (assetType == MUSIC || assetType == SOUND)))
			{
				return true;
			}

			#if flash
			if (requestedType == BINARY && (assetType == BINARY || assetType == TEXT || assetType == IMAGE))
			{
				return true;
			}
			else if (requestedType == TEXT && assetType == BINARY)
			{
				return true;
			}
			else if (requestedType == null)
			{
				return true;
			}
			#else
			if (requestedType == BINARY || requestedType == null || (assetType == BINARY && requestedType == TEXT))
			{
				return true;
			}
			#end
		}

		#if sys
		return sys.FileSystem.exists(id);
		#end

		return false;
	}

	public override function getAudioBuffer(id:String):AudioBuffer
	{
		if (cachedAudioBuffers.exists(id))
		{
			return cachedAudioBuffers.get(id);
		}
		else if (classTypes.exists(id))
		{
			#if flash
			var buffer = new AudioBuffer();
			buffer.src = cast(Type.createInstance(classTypes.get(id), []), Sound);
			return buffer;
			#else
			return AudioBuffer.fromBytes(cast(Type.createInstance(classTypes.get(id), []), Bytes));
			#end
		}
		else
		{
			return AudioBuffer.fromFile(id);
		}
	}

	public override function getBytes(id:String):Bytes
	{
		if (cachedBytes.exists(id))
		{
			return cachedBytes.get(id);
		}
		else if (cachedText.exists(id))
		{
			var bytes = Bytes.ofString(cachedText.get(id));
			cachedBytes.set(id, bytes);
			return bytes;
		}
		else if (classTypes.exists(id))
		{
			#if flash
			var data = Type.createInstance(classTypes.get(id), []);

			switch (types.get(id))
			{
				case TEXT, BINARY:
					return Bytes.ofData(cast(Type.createInstance(classTypes.get(id), []), flash.utils.ByteArray));

				case IMAGE:
					var bitmapData = cast(Type.createInstance(classTypes.get(id), []), BitmapData);
					return Bytes.ofData(bitmapData.getPixels(bitmapData.rect));

				default:
					return null;
			}
			#else
			return cast(Type.createInstance(classTypes.get(id), []), Bytes);
			#end
		}
		else
		{
			return Bytes.fromFile(id);
		}
	}

	public override function getFont(id:String):Font
	{
		if (cachedFonts.exists(id))
		{
			return cachedFonts.get(id);
		}
		else if (classTypes.exists(id))
		{
			#if flash
			var src = Type.createInstance(classTypes.get(id), []);

			var font = new Font(src.fontName);
			font.src = src;
			return font;
			#else
			return cast(Type.createInstance(classTypes.get(id), []), Font);
			#end
		}
		else
		{
			return Font.fromFile(id);
		}
	}

	public override function getImage(id:String):Image
	{
		if (cachedImages.exists(id))
		{
			return cachedImages.get(id);
		}
		else if (classTypes.exists(id))
		{
			#if flash
			return Image.fromBitmapData(cast(Type.createInstance(classTypes.get(id), []), BitmapData));
			#else
			return cast(Type.createInstance(classTypes.get(id), []), Image);
			#end
		}
		else
		{
			return Image.fromFile(id);
		}
	}

	public override function getPath(id:String):String
	{
		if (paths.exists(id))
		{
			return paths.get(id);
		}
		else if (pathGroups.exists(id))
		{
			return pathGroups.get(id)[0];
		}
		else
		{
			return id;
		}
	}


	public override function loadAudioBuffer(id:String):Future<AudioBuffer>
	{
		if (cachedAudioBuffers.exists(id))
		{
			return Future.withValue(cachedAudioBuffers.get(id));
		}
		else if (classTypes.exists(id))
		{
			return Future.withValue(AudioBuffer.fromBytes(cast(Type.createInstance(classTypes.get(id), []), Bytes)));
		}
		else
		{
			if (pathGroups.exists(id))
			{
				return AudioBuffer.loadFromFiles(pathGroups.get(id));
			}
			else
			{
				return AudioBuffer.loadFromFile(id);
			}
		}
	}

	public override function loadBytes(id:String):Future<Bytes>
	{
		if (cachedBytes.exists(id))
		{
			return Future.withValue(cachedBytes.get(id));
		}
		else if (classTypes.exists(id))
		{
			#if flash
			return Future.withValue(Bytes.ofData(Type.createInstance(classTypes.get(id), [])));
			#else
			return Future.withValue(Type.createInstance(classTypes.get(id), []));
			#end
		}
		else
		{
			return Bytes.loadFromFile(id);
		}
	}

	public override function loadFont(id:String):Future<Font>
	{
		if (cachedFonts.exists(id))
		{
			return Future.withValue(cachedFonts.get(id));
		}
		else if (classTypes.exists(id))
		{
			var font:Font = Type.createInstance(classTypes.get(id), []);

			#if (js && html5)
			return font.__loadFromName(font.name);
			#else
			return Future.withValue(font);
			#end
		}
		else
		{
			#if (js && html5)
			return Font.loadFromName(id);
			#else
			return Font.loadFromFile(id);
			#end
		}
	}

	public override function loadImage(id:String):Future<Image>
	{
		if (cachedImages.exists(id))
		{
			return Future.withValue(cachedImages.get(id));
		}
		else if (classTypes.exists(id))
		{
			return Future.withValue(Type.createInstance(classTypes.get(id), []));
		}
		else if (cachedBytes.exists(id))
		{
			return Image.loadFromBytes(cachedBytes.get(id)).then(function(image)
			{
				cachedBytes.remove(id);
				cachedImages.set(id, image);
				return Future.withValue(image);
			});
		}
		else
		{
			return Image.loadFromFile(id);
		}
	}

	public override function loadText(id:String):Future<String>
	{
		if (cachedText.exists(id))
		{
			return Future.withValue(cachedText.get(id));
		}
		else if (cachedBytes.exists(id) || classTypes.exists(id))
		{
			var bytes = getBytes(id);

			if (bytes == null)
			{
				return cast Future.withValue(null);
			}
			else
			{
				var text = bytes.getString(0, bytes.length);
				cachedText.set(id, text);
				return Future.withValue(text);
			}
		}
		else
		{
			var request = new HTTPRequest<String>();
			return request.load(id);
		}
	}
}