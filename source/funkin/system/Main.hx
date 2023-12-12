package funkin.system;

// OpenFL Application stuff
import openfl.Lib;
import openfl.events.Event;
import lime.app.Application;

class InitState extends flixel.FlxState {}

class Main extends openfl.display.Sprite {
	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: InitState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 120, // default framerate
		skipSplash: false, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var statisticMonitor:StatisticMonitor;

	public static function main():Void {
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		stage != null ? init() : addEventListener(Event.ADDED_TO_STAGE, init);

		Application.current.window.onFocusOut.add(onWindowFocusOut);
		Application.current.window.onFocusIn.add(onWindowFocusIn);
		Application.current.window.onClose.add(onWindowClose);
	}

	function onWindowClose() {
		trace('Application closed by User');
	}

	function onWindowFocusOut() { 
		trace("Game unfocused");
	}

	function onWindowFocusIn() {
		trace("Game focused");
	}

	private function init(?E:Event):Void {
		Application.current.window.focus();

		trace('Game Init');

		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void {
		final stageWidth:Int = Lib.current.stage.stageWidth;
		final stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0) {
			final ratioX:Float = stageWidth / game.width;
			final ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}

		addChild(new flixel.FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate,
			game.skipSplash, game.startFullscreen));

		initBaseGameSettings();

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
	}

	public static function initBaseGameSettings() {
		//WindowsAPI.setDarkMode(true);
		//ClientPrefs.loadDefaultKeys();
		//AudioSwitchFix.init();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 30;

		//grafex.system.statesystem.ScriptedState.init();
		//grafex.system.statesystem.ScriptedSubState.init();

		final bgColor = 0xFF0D1211;
		FlxG.stage.color = bgColor;

		/*#if (flixel >= "5.1.0")
		FlxG.game.soundTray.volumeUpSound = Paths.getPath('sounds/'+appConfig.appUpSound+'.ogg', SOUND, true);
		FlxG.game.soundTray.volumeDownSound = Paths.getPath('sounds/'+appConfig.appDownSound+'.ogg', SOUND, true);
		#end*/

		/*FlxG.signals.preStateSwitch.add(function() {
			Paths.clearStoredMemory();
			clearCache();
			gc();
		});

		FlxG.signals.postStateSwitch.add(function() {
			//Paths.clearUnusedMemory();
			clearCache();
			gc();
		});*/

		FlxG.signals.gameResized.add(function (w, h) {
		     if (FlxG.cameras != null) {
			   for (cam in FlxG.cameras.list) {
				//@:privateAccess
				if (cam != null && cam.filters != null)
					resetSpriteCache(cam.flashSprite);
			   }
		     }

		     if (FlxG.game != null)
			 resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:openfl.display.Sprite):Void {
		@:privateAccess {
		        sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	function onCrash(e:openfl.events.UncaughtErrorEvent):Void {}
}
