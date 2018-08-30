package yui;

import kha.graphics2.Graphics;
import yui.Sprites;
import zui.Canvas.Anchor;
import zui.Canvas.ElementType;
import zui.Canvas.ElementState;

typedef YuiOpts = {
	data: Data,
	renderers: Map<ElementType, Yui -> TCanvas -> TElement -> Float -> Float -> Float -> Float -> (String -> Void) -> Void>,
	eventHandler: String -> Void,
}

class RadioGroup {
	var name: String;
	var active: Null<Int>;

	public function new( name: String ) {
		this.name = name;
	}

	public function makeActive( elementId: Int ) {
		active = elementId;
	}
}

// TODO (DK) split into YuiEd and YuiRT
	// -most of the data lookup stuff is uneccessary at runtime,
	//  we could already resolve that during loading to make things faster?
class Yui {
	var s = new YuiInputState();
	var data: Data;
	var renderers: Map<ElementType, Yui -> TCanvas -> TElement -> Float -> Float -> Float -> Float -> (String -> Void) -> Void> = new Map();
	var eventHandler: String -> Void;

	public var uiScale = 1.0;
	public var _screenW: Float;
	public var _screenH: Float;

	var _x: Float;
	var _y: Float;
	var _w: Float;
	var _h: Float;

	var _g2: Graphics;

	var spriteCache: Map<String, Sprite> = new Map(); // TODO (DK) assets have an int-id as well, use that?
	var spritesDataCache: Map<Int, SpritesData> = new Map();

	var fontSpriteCache: Map<String, FontSprite> = new Map(); // TODO (DK) assets have an int-id as well, use that?
	var fontSpritesDataCache: Map<Int, FontSpritesData> = new Map();

	var elementStates: Map<Int, ElementState> = new Map();

	var activeStyles: Map<Int, String> = new Map();

	var checkStates: Map<Int, Bool> = new Map();
	var elementToRadioGroup: Map<Int, RadioGroup> = new Map(); // TODO (DK) map during parsing

	public function new( opts: YuiOpts ) {
		this.data = opts.data;
		this.renderers = opts.renderers;
		this.eventHandler = opts.eventHandler;
	}

	public function setActiveStyle( canvas: TCanvas, element: TElement, style: String ) {
		if (element.parent != null) {
			setActiveStyle(canvas, elementById(canvas, element.parent), style);
		}

		activeStyles[element.id] = style;
	}

	public function getActiveStyles( canvas: TCanvas, element: TElement ) : String {
		if (element.parent != null) {
			return getActiveStyles(canvas, elementById(canvas, element.parent));
		}

		return activeStyles[element.id];
	}

	public function toggleCheck( elementId: Int ) {
		checkStates[elementId] = !checkStates[elementId];
	}

	public function activateInRadioGroup( elementId: Int ) {
		elementToRadioGroup.get(elementId).makeActive(elementId);
	}

	public function getElementState( e: TElement, defaultState: ElementState ) : ElementState {
		var state = elementStates.get(e.id);

		if (state == null) {
			elementStates.set(e.id, defaultState);
			return defaultState;
		}

		return state;
	}

	public function getFontSprites( e: TElement ) : Null<FontSpritesData> {
		switch fontSpritesDataCache.get(e.id) {
			case null:
				if (e.asset != '') {
					try {
						var data = data.core.getBlob(e.asset).toString();
						var parsed: FontSpritesData = tink.Json.parse(data);
						fontSpritesDataCache.set(e.id, parsed);
						return parsed;
					} catch (x: Dynamic) {
						trace(x);
					}
				}
			case other:
				return other;
		}

		return null;
	}

	public function getSprites( e: TElement ) : Null<SpritesData> {
		switch spritesDataCache.get(e.id) {
			case null:
				if (e.asset != '') {
					try {
						var data = data.core.getBlob(e.asset).toString();
						var parsed: SpritesData = tink.Json.parse(data);
						spritesDataCache.set(e.id, parsed);
						return parsed;
					} catch (x: Dynamic) {
						trace(x);
					}
				}
			case other:
				return other;
		}

		return null;
	}

	public function getSprite( id: String ) : Null<Sprite>
		return id != null && id != '' ? resolveSprite(id) : null;

	public function getFontSprite( id: String ) : Null<FontSprite>
		return id != null && id != '' ? resolveFontSprite(id) : null;

	public function drawSprite( s: Sprite, e: TElement, x, y, w, h ) {
		switch s {
			case null:
			case ImageSprite(img):
				// _g2.color = e.color;
				_g2.drawScaledImage(img, x, y, w, h);
			case AtlasTextureSprite(tex):
				// _g2.color = e.color;
				_g2.drawScaledSubImage(tex.image, tex.sx, tex.sy, tex.sw, tex.sh, x, y, w, h);
			case NineSliceSprite(tex, cuts):
				// _g2.color = e.color;
				yui.slice.G2SliceExtension.draw9SliceSubImage(
					_g2, tex.image,
					tex.sx, tex.sy, tex.sw, tex.sh,
					cuts.left, cuts.top, cuts.width, cuts.height,
					x, y, w, h
				);
			case SpriterEntitySprite(entity, atlas, scale):
				yui.spriter.G2SpriterExtension.drawSpriter(_g2, atlas, entity, x + w / 2, y + h / 2, scale);
		}
	}

	public function drawFontSprite( fs: FontSprite, e: TElement, x, y, w, h ) {
		switch fs {
			case TrueTypeFontSprite(fnt, size, color):
				_g2.font = fnt;
				_g2.fontSize = size;
				var oc = _g2.color;
				_g2.color = color;
				_g2.drawString(e.text, x, y);
				_g2.color = oc;
			case BitmapFontSprite(fnt, pages, color):
				var oc = _g2.color;
				_g2.color = color;
				for (i in 0...e.text.length) {
					var cc = e.text.charCodeAt(i);
					var char = fnt.chars.get(cc);

					_g2.drawSubImage(
						pages[char.pageId],
						x + char.xOffset, y + char.yOffset,
						char.x, char.y, char.width, char.height
					);

					x += char.width;
				}
				_g2.color = oc;
		}
	}

	/* `g2.begin()` has to be called beforehand */
	public function drawFrame( g: Graphics, canvas: TCanvas ) {
		_g2 = g;
		beginFrame();
			draw(_g2, canvas);
		endFrame();
		_g2 = null;
	}

	/* Get an element by it's id */
	public static function elementById( canvas: TCanvas, id: Int ): TElement {
		for (e in canvas.elements) {
			if (e.id == id) {
				return e;
			}
		}

		return null;
	}

	/* Get an element by it's name */
	public static function elementByName( canvas: TCanvas, name: String ): TElement {
		for (e in canvas.elements) {
			if (e.name == name) {
				return e;
			}
		}

		return null;
	}

	/* The mousepointer is currently in the area */
	public function isHovered( x: Float, y: Float, w: Float, h: Float ) return
		s.pointerX >= x && s.pointerX < x + w &&
		s.pointerY >= y && s.pointerY < y + y;

	/* MouseDown was in the area
	 *  - and the mousepointer currently is in the area
	 *  - and the left button is down
	 */
	public function isPressed( x: Float, y: Float, w: Float, h: Float ) return
		s.inputDown[0] && isHovered(x, y, w, h) && hasInitialHover(x, y, w, h);

	/* MouseDown was in area
	 *  - and the mousepointer currently is in the area
	 *  - and the left button was released
	 */
	public function isReleased( x: Float, y: Float, w: Float, h: Float ) return
		s.inputReleased[0] && isHovered(x, y, w, h) && hasInitialHover(x, y, w, h);

	function hasInitialHover( x: Float, y: Float, w: Float, h: Float ) return
		s.pointerDownX >= x && s.pointerDownX < x + w &&
		s.pointerDownY >= y && s.pointerDownY < y + h;

	function getAtlas( fmt: AtlasFormat )
		return switch fmt {
			case KenneyAtlasFormat(atlasUrl):
				data.atlas.getAtlasKENNEY(atlasUrl);
			case TpjsaaAtlasFormat(atlasUrl):
				data.atlas.getAtlasTPJSAA(atlasUrl);
		}

	function resolveFontSprite( id: String ) : FontSprite {
		var cached: FontSprite = fontSpriteCache.get(id);

		if (cached != null) {
			return cached;
		}

		// TODO (DK) lookup actual assets paths via canvas.assets, don't use the id directly
		var filename = id;

		try {
			var srcData = data.core.cachedBlobs.get(filename).toString();
			var parsed: FontSpriteData = tink.Json.parse(srcData);

			switch parsed {
				case TrueTypeFontSpriteData(fntUrl, size, argb):
					var fnt = data.core.cachedFonts.get(fntUrl);
					var sprite = TrueTypeFontSprite(fnt, size, argb != null ? kha.Color.fromString(argb) : kha.Color.White);
					fontSpriteCache.set(id, sprite);
					return sprite;
				case BitmapFontSpriteData(fntUrl, argb):
					var fnt = data.bmfont.getBitmapFontXML(fntUrl);
					var pages = [for (page in fnt.pages) data.core.getImage(page)];
					var sprite = BitmapFontSprite(fnt, pages, argb != null ? kha.Color.fromString(argb) : kha.Color.White);
					fontSpriteCache.set(id, sprite);
					return sprite;
			}
		} catch (x: Dynamic) {
			trace(x);
			return null;
		}
	}

	function resolveSprite( id: String ) : Sprite {
		var cached: Sprite = spriteCache.get(id);

		if (cached != null) {
			return cached;
		}

		// TODO (DK) lookup actual assets paths via canvas.assets, don't use the id directly
		var filename = id;

		try {
			var srcData = data.core.cachedBlobs.get(filename).toString();
			var parsed: SpriteData = tink.Json.parse(srcData);

			switch parsed {
				case ImageSpriteData(imageUrl):
					var img = data.core.cachedImages.get(imageUrl);
					var sprite = ImageSprite(img);
					spriteCache.set(id, sprite);
					return sprite;
				case AtlasTextureSpriteData(atlasFmt, atlasRegionId):
					var atlas = getAtlas(atlasFmt);
					var sprite = AtlasTextureSprite(atlas.get(atlasRegionId));
					spriteCache.set(id, sprite);
					return sprite;
				case NineSliceSpriteData(atlasFmt, atlasRegionId, cutRegion):
					var atlas = getAtlas(atlasFmt);
					var sprite = NineSliceSprite(atlas.get(atlasRegionId), cutRegion);
					spriteCache.set(id, sprite);
					return sprite;
				case SpriterEntityData(scml, entityName, atlasFmt, animation, scale):
					var atlas = getAtlas(atlasFmt);
					var spriter = data.spriter.getSpriter(scml);
					var entity = spriter.createEntity(entityName);
					entity.play(animation);
					var sprite = SpriterEntitySprite(entity, atlas, scale);
					spriteCache.set(id, sprite);
					return sprite;
			}
		} catch (x: Dynamic) {
			trace(x);
			return null;
		}
	}

	function beginFrame() {
	}

	function endFrame() {
		s.inputReleased = [];
		s.pointerDeltaX = 0;
		s.pointerDeltaY = 0;
	}

	function draw( g: Graphics, canvas: TCanvas ) {
		_screenW = kha.System.windowWidth();
		_screenH = kha.System.windowHeight();

		for (e in canvas.elements) {
			if (e.parent == null) {
				drawElement(g, canvas, e, 0, 0);
			}
		}
	}

	function drawElement( g: Graphics, canvas: TCanvas, e: TElement, px: Float, py: Float ) {
		if (e == null || e.visible == false) {
			return;
		}

		_x = canvas.x + scaled(e.x) + scaled(px);
		_y = canvas.y + scaled(e.y) + scaled(py);
		_w = scaled(e.width);
		_h = scaled(e.height);

		var cw = scaled(canvas.width);
		var ch = scaled(canvas.height);

		switch e.anchor {
			case Top:
				_x -= (cw - _screenW) / 2;
			case TopRight:
				_x -= cw - _screenW;
			case CenterLeft:
				_y -= (ch - _screenH) / 2;
			case Center:
				_x -= (cw - _screenW) / 2;
				_y -= (ch - _screenH) / 2;
			case CenterRight:
				_x -= cw - _screenW;
				_y -= (ch - _screenH) / 2;
			case BottomLeft:
				_y -= ch - _screenH;
			case Bottom:
				_x -= (cw - _screenW) / 2;
				_y -= ch - _screenH;
			case BottomRight:
				_x -= cw - _screenW;
				_y -= ch - _screenH;
		}

		var rotated = e.rotation != null && e.rotation != 0;

		if (rotated) {
			g.pushRotation(e.rotation, _x + scaled(e.width) / 2, _y + scaled(e.height) / 2);
		}

		var r = renderers[e.type];

		if (r != null) {
			r(this, canvas, e, _x, _y, _w, _h, eventHandler);
		} else {
			trace('no renderer for `${e.type}`');
		}

		if (e.children != null) {
			for (id in e.children) {
				drawElement(g, canvas, elementById(canvas, id), px + e.x, py + e.y);
			}
		}

		if (rotated) {
			g.popTransformation();
		}
	}

	inline function scaled( f: Float )
		return Std.int(f * uiScale);

// asset injection
	/* Cache an already loaded image */
	public function setCachedImage( id: String, img: kha.Image )
		data.core.cachedImages.set(id, img);

	/* Cache an already loaded blob */
	public function setCachedBlob( id: String, blob: kha.Blob )
		data.core.cachedBlobs.set(id, blob);

	/* Cache an already loaded font */
	public function setCachedFont( id: String, fnt: kha.Font )
		data.core.cachedFonts.set(id, fnt);

	/* Inject a MouseDown event */
	public function injectMouseDown( b: Int, x: Int, y: Int ) {
		s.inputStarted[b] = true;
		s.inputDown[b] = true;
		s.pointerDownX = s.pointerX = x;
		s.pointerDownY = s.pointerY = y;
	}

	/* Inject a MouseUp event */
	public function injectMouseUp( b: Int, x: Int, y: Int ) {
		s.inputDown[b] = false;
		s.inputReleased[b] = true;
		s.pointerX = x;
		s.pointerY = y;
	}

	/* Inject a MouseMove event */
	public function injectMouseMove( x: Int, y: Int, dx: Int, dy: Int ) {
		s.pointerDeltaX = x - s.pointerX; // TODO (DK) dx/dy don't seem to work that well
		s.pointerDeltaY = y - s.pointerY;
		s.pointerX = x;
		s.pointerY = y;
	}
}

private class YuiInputState {
	public var inputStarted: Array<Bool> = [];
	public var inputDown: Array<Bool> = [];
	public var inputReleased: Array<Bool> = [];
	public var pointerX = -1;
	public var pointerY = -1;
	public var pointerDownX = -1;
	public var pointerDownY = -1;
	public var pointerDeltaX = -1;
	public var pointerDeltaY = -1;

	public function new() {
	}
}
