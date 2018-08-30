package yui.format;

// TODO (DK) i think this is just the starling atlas format, so use haxe-format-starling (and clean that up some)

import haxe.xml.Fast;

typedef KenneyAtlasSubTexture = {
	name: String,
	x: Int,
	y: Int,
	width: Int,
	height: Int,
}

typedef KenneyAtlas = {
	imagePath: String,
	subTextures: Array<KenneyAtlasSubTexture>,
}

typedef KenneyAtlasError = Any;

class KenneyAtlasReader {
	public static function readSync( data: String ) : KenneyAtlas {
		var xml = Xml.parse(data);
		var f = new Fast(xml).node.TextureAtlas;

		return {
			imagePath: f.att.imagePath,
			subTextures: [for (st in f.elements) readSubTexture(st)],
		}
	}

	public static function read( data: String, done: KenneyAtlas -> KenneyAtlasError -> Void ) {
		done(readSync(data), null);
	}

	static function readSubTexture( f: Fast ) : KenneyAtlasSubTexture
		return {
			name: f.att.name,
			x: _int(f.att.x),
			y: _int(f.att.y),
			width: _int(f.att.width),
			height: _int(f.att.height),
		}

	static inline function _int( v: String ) : Null<Int>
		return Std.parseInt(v);
}
