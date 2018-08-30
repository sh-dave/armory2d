package yui;

import yui.data.*;

class Data {
	public var core(default, null): CoreDataAccess;
	public var atlas(default, null): AtlasDataAccess;
	public var spriter(default, null): SpriterDataAccess;
	public var bmfont(default, null): BitmapFontDataAccess;

	public function new() {
		core = new CoreDataAccess();
		atlas = new AtlasDataAccess(core);
		spriter = new SpriterDataAccess(core);
		bmfont = new BitmapFontDataAccess(core);
	}
}
