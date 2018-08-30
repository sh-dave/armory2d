package yui.data;

import kha.Blob;
import kha.Font;
import kha.Image;

class CoreDataAccess {
	public var cachedImages(default, null) = new Map<String, Image>();
	public var cachedBlobs(default, null) = new Map<String, Blob>();
	public var cachedFonts(default, null) = new Map<String, Font>();

	public function new() {
	}

	public function getBlob( url: String ) : Blob
		return cachedBlobs.get(url);

	public function getImage( url: String ) : Image
		return cachedImages.get(url);

	public function getFont( url: String ) : Font
		return cachedFonts.get(url);
}
