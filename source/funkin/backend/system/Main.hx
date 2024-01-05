package funkin.backend.system;

// OpenFL Application stuff
import openfl.Lib;
import openfl.events.Event;
import lime.app.Application;

class InitState extends flixel.FlxState 
{
	override function create() {
		super.create();
		initBaseGameSettings();
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}

	private static function initBaseGameSettings() {
		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;

		final bgColor = 0xFF0D1211;
		FlxG.stage.color = bgColor;

		FlxG.signals.gameResized.add(function (w, h) {
		     if (FlxG.cameras != null) for (cam in FlxG.cameras.list) if (cam != null && cam.filters != null) resetSpriteCache(cam.flashSprite);

		     if (FlxG.game != null) resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:openfl.display.Sprite):Void {
		@:privateAccess {
		    sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
}

class Main extends openfl.display.Sprite {

	public static var instance:Main;
	#if !mobile
	public static var statisticMonitor:StatisticMonitor;
	#end
	public static var scaleMode:FunkinRatioScaleMode;
	public static var game:FunkinGame;

	public static var modToLoad:String = null;

	public static var time:Int = 0;


	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: InitState, // initial game state
		framerate: 120, // default framerate
		skipSplash: false, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};


	public static function main():Void {
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		addChild(new flixel.FlxGame(
			game.width, game.height, game.initialState,
			game.framerate, game.framerate,
			game.skipSplash, game.startFullscreen
		));

		#if !mobile
		statisticMonitor = new StatisticMonitor(6, 6, 0xFFFFFF);
		addChild(statisticMonitor);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = openfl.display.StageScaleMode.NO_SCALE;
		#end

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#if debug
		trace('Debug Build');
		#else
		trace('NonDebug Build');
		#end

		Application.current.window.onFocusOut.add(onWindowFocusOut);
		Application.current.window.onFocusIn.add(onWindowFocusIn);
		Application.current.window.onClose.add(onWindowClose);
	}

	function onWindowFocusOut() { 
		trace("Game unfocused");
	}

	function onWindowFocusIn() {
		trace("Game focused");
	}

	function onWindowClose() {
		trace('Application closed by User');
	}

	function onCrash(e:openfl.events.UncaughtErrorEvent):Void {}
}
