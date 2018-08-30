package yui.data;

import spriter.Spriter;

class SpriterDataAccess {
	var core: CoreDataAccess;
	var cachedSpriter = new Map<String, Spriter>();

	public function new( core: CoreDataAccess )
		this.core = core;

	public function getSpriter( url: String ) : Spriter {
		var cached = cachedSpriter.get(url);

		if (cached != null) {
			return cached;
		}

		var blob = core.getBlob(url);
		var spriter = Spriter.parseScml(blob.toString());
		cachedSpriter.set(url, spriter);
		return spriter;
	}
}
