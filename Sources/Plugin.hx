package;

import zui.Zui;

// Totally not stolen from armorpaint

@:expose @:keep
class Plugin {
	public static var plugins: Array<Plugin> = [];

	public var drawRightUi: Elements -> Zui -> Handle -> Void = null;
	public var drawToolbarUi: Elements -> Zui -> Handle -> Void = null;
	public var drawToolsUi: Elements -> Zui -> Void = null;

	// public var draw: Void -> Void = null; // TODO (DK) yet unused
	// public var update: Void -> Void = null; // TODO (DK) yet unused

	// public var onSave: TCanvas -> Void = null;
	// public var onLoad: TCanvas -> Void = null;

	public function handle( ?opts: HandleOptions ) {
		return new Handle(opts);
	}

	public function new() {
		plugins.push(this);
	}

	public function log(s) {
		trace(s);
	}
}
