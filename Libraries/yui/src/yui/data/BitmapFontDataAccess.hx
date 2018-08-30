package yui.data;

import format.bmfont.types.BitmapFont;

class BitmapFontDataAccess {
	var core: CoreDataAccess;
	var cachedDatas = new Map<String, BitmapFont>();

	public function new( core: CoreDataAccess )
		this.core = core;

	public function getBitmapFontXML( url: String ) : BitmapFont {
		var cached = cachedDatas.get(url);

		if (cached != null) {
			return cached;
		}

		var blob = core.getBlob(url);
		var fnt = format.bmfont.XmlReader.readSync(blob.bytes.getData());
		cachedDatas.set(url, fnt);
		return fnt;
	}
}
