package ;

import zui.Canvas;

class Main {

	public static var prefs:TPrefs = null;
	public static var cwd = ""; // Canvas path
	static var inst:Elements;

	public static function main() {

		var w = 1600;
		var h = 900;
		if (w > kha.Display.primary.width) w = kha.Display.primary.width;
		if (h > kha.Display.primary.height) h = kha.Display.primary.height;
		var windowFeatures = kha.WindowOptions.FeatureMaximizable | kha.WindowOptions.FeatureResizable;

		kha.System.start({ title: "Armory2D", width: w, height: h, window: { windowFeatures: windowFeatures } }, initialized);
	}

	static function initialized( _ ) {

		prefs = { path: "", scaleFactor: 1.0 };

		#if kha_krom

		var c = Krom.getArgCount();
		// ./krom . . --nosound canvas_path scale_factor
		if (c > 4) prefs.path = Krom.getArg(4);
		if (c > 5) prefs.scaleFactor = Std.parseFloat(Krom.getArg(5));

		var ar = prefs.path.split("/");
		ar.pop();
		cwd = ar.join("/");

		var path = kha.System.systemId == "Windows" ? StringTools.replace(prefs.path, "/", "\\") : prefs.path;
		kha.Assets.loadBlobFromPath(path, function(cblob:kha.Blob) {
			var raw:TCanvas = haxe.Json.parse(cblob.toString());
			inst = new Elements(raw);
		});

		#else

		var raw:TCanvas = { name: "untitled", x: 0, y: 0, width: 1280, height: 720, elements: [], assets: [] };
		inst = new Elements(raw);
		prefs.path = 'untitled.json';
		cwd = untyped __js__('__dirname');
		#end
	}
}

typedef TPrefs = {
	var path:String;
	var scaleFactor:Float;
	@:optional var window_vsync:Bool;
}
