package yui.format;

// copy and paste of haxe-format-tpjsaa, use that instead

typedef TpjsaaFrame = {
	filename: String,
	frame: { x: Int, y: Int, w: Int, h: Int },
	?pivot: { x: Float, y: Float },
	rotated: Bool,
	sourceSize: { w: Int, h: Int },
	spriteSourceSize: { x: Int, y: Int, w: Int, h: Int },
	trimmed: Bool,
}

typedef TpjsaaMeta = {
	app: String,
	format: String,
	image: String,
	scale: String,
	size: { w: Int, h: Int },
	smartupdate: String,
	version: String,
}

typedef TpjsaaAtlas = {
	frames: Array<TpjsaaFrame>,
	meta: TpjsaaMeta,
}

typedef TpjsaaError = Any;

class TpjsaaReader {
	public static function readSync( data: String ) : TpjsaaAtlas
		return tink.Json.parse(data);

	public static function read( data: String, done: TpjsaaAtlas -> TpjsaaError -> Void )
		done(readSync(data), null);
}
