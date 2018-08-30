package yui.data;

import yui.atlas.TextureAtlas;
import yui.format.KenneyAtlas;
import yui.format.Tpjsaa;

class AtlasDataAccess {
	var core: CoreDataAccess;
	var cachedTpjsaaAtlasDatas = new Map<String, TpjsaaAtlas>();
	var cachedKenneyAtlasDatas = new Map<String, KenneyAtlas>();
	var cachedAtlas = new Map<String, TextureAtlas>();

	public function new( core: CoreDataAccess )
		this.core = core;

	public function getAtlasKENNEY( url: String ) : TextureAtlas {
		var cached = cachedAtlas.get(url);

		if (cached != null) {
			return cached;
		}

		var data = getKenneyAtlasData(url);
		var img = core.getImage(data.imagePath);
		var atlas = new TextureAtlas();

		for (st in data.subTextures) {
			atlas.set(st.name, {
				image: img,
				sx: st.x, sy: st.y, sw: st.width, sh: st.height,
				fx: st.x, fy: st.y, fw: st.width, fh: st.height,
				rotated: false,
			});
		}

		cachedAtlas.set(url, atlas);
		return atlas;
	}

	public function getAtlasTPJSAA( url: String ) : TextureAtlas {
		var cached = cachedAtlas.get(url);

		if (cached != null) {
			return cached;
		}

		var data = getTpjsaaAtlasData(url);
		var img = core.getImage(data.meta.image);
		var atlas = new TextureAtlas();

		for (frame in data.frames) {
			// TODO (DK) handle split/frame stuff?
			// TODO (DK) move to utility library?
			atlas.set(frame.filename, {
				image: img,
				sx: frame.frame.x, sy: frame.frame.y,
				sw: frame.frame.w, sh: frame.frame.h,
				// TODO (DK) figure out correct frame data
				fx: frame.spriteSourceSize.x, fy: frame.spriteSourceSize.y,
				fw: frame.spriteSourceSize.w, fh: frame.spriteSourceSize.h,
				rotated: frame.rotated,
			});
		}

		cachedAtlas.set(url, atlas);
		return atlas;
	}

	function getTpjsaaAtlasData( url: String ) : TpjsaaAtlas {
		var cached = cachedTpjsaaAtlasDatas.get(url);

		if (cached != null) {
			return cached;
		}

		var blob = core.getBlob(url);
		var parsed = TpjsaaReader.readSync(blob.toString());
		cachedTpjsaaAtlasDatas.set(url, parsed);
		return parsed;
	}

	function getKenneyAtlasData( url: String ) : KenneyAtlas {
		var cached = cachedKenneyAtlasDatas.get(url);

		if (cached != null) {
			return cached;
		}

		var blob = core.getBlob(url);
		var parsed = KenneyAtlasReader.readSync(blob.toString());
		cachedKenneyAtlasDatas.set(url, parsed);
		return parsed;
	}
}
