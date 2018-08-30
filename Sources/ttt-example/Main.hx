package ;

import TicTacToe;
import yui.*;

class Main {
	public static function main()
		kha.System.start({ title: "armory2d-example-ttt" }, setup);

	static function setup( _ ) {
		kha.Assets.loadBlobFromPath('untitled.json', function( blob ) {
			var raw: TCanvas = haxe.Json.parse(blob.toString());

			var ttt = new TicTacToe({
				onStateChanged: function( state: TicTacToeState ) {
					for (i in 0...state.cells.length) {
						var cell = state.cells[i];
						var elem = Yui.elementByName(raw, 'f$i');

						if (elem != null) {
							elem.asset = cell != null ? 'sprite-$cell.json' : null;
						}
					}
				},
				onGameOver: function( gameOver: GameOver ) {
					trace('game concluded "$gameOver"');
				}
			});

			var ui = new Yui({
				data: new Data(),
				renderers: [
					Image => DefaultElements.drawImage,
					Button => DefaultElements.drawButton,
					Text => DefaultElements.drawText,
					Radio => DefaultElements.drawRadioButton,
					Check => DefaultElements.drawCheckButton,
				],
				eventHandler: function( ev: String ) {
					switch ev.split(':') {
						case ['f', fieldIndex]:
							ttt.clickFieldIndex(Std.parseInt(fieldIndex));
						case ['new-game']:
							ttt.newGame();
						case invalid:
							trace('unhandled event "$ev"');
					}
				}
			});

			for (asset in raw.assets) {
				importAsset(ui, asset);
			}

			kha.input.Mouse.get().notify(
				ui.injectMouseDown,
				ui.injectMouseUp,
				ui.injectMouseMove,
				null, null
			);

			kha.System.notifyOnFrames(function( fbs ) {
				if (assetsToLoad != 0) {
					return;
				}

				var fb = fbs[0];
				var g2 = fb.g2;
				g2.begin(true, 0xff004040);
					ui.drawFrame(g2, raw);
				g2.end();
			});
		});
	}

	static function isImageAssetFilename( path: String )
		return	StringTools.endsWith(path, ".jpg")
			||	StringTools.endsWith(path, ".png")
			||	StringTools.endsWith(path, ".k")
			||	StringTools.endsWith(path, ".hdr");

	static function isFontAssetFilename( path: String )
		return StringTools.endsWith(path, ".ttf");

	static var assetsToLoad = 0;

	static function importAsset( ui: Yui, asset: { name: String, file: String } ) {
		var file = asset.file;
		var isImage = isImageAssetFilename(file);
		var isFont = isFontAssetFilename(file);

		assetsToLoad += 1;

		if (isImage) {
			kha.Assets.loadImageFromPath(file, false, function( img ) {
				ui.setCachedImage(asset.name, img);
				assetsToLoad -= 1;
			});
		} else if (isFont) {
			kha.Assets.loadFontFromPath(file, function( fnt ) {
				ui.setCachedFont(asset.name, fnt);
				assetsToLoad -= 1;
			});
		} else {
			kha.Assets.loadBlobFromPath(file, function( blob ) {
				ui.setCachedBlob(asset.name, blob);
				assetsToLoad -= 1;
			});
		}
	}
}
