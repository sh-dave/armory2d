package yui;

import format.bmfont.types.BitmapFont;
import spriter.EntityInstance;
import yui.atlas.SubTexture;
import yui.atlas.TextureAtlas;
import yui.format.KenneyAtlas;
import yui.format.Tpjsaa;

enum AtlasFormat {
	KenneyAtlasFormat( atlasUrl: String );
	TpjsaaAtlasFormat( atlasUrl: String );
}

enum AtlasData {
	KenneyAtlasData( imageUrl: String, subTextures: Array<KenneyAtlasSubTexture> );
	TpjsaaAtlasData( imageUrl: String, frames: Array<TpjsaaFrame> );
}

typedef NineSliceRegion = {
	left: Int,
	top: Int,
	width: Int,
	height: Int,
}

enum SpriteData {
	ImageSpriteData( imageUrl: String );
	AtlasTextureSpriteData( atlasFmt: AtlasFormat, atlasRegionId: String );
	NineSliceSpriteData( atlasFmt: AtlasFormat, atlasRegionId: String, cutRegion: NineSliceRegion );
	SpriterEntityData( scml: String, entityName: String, atlasFmt: AtlasFormat, animation: String, scale: Float );
}

typedef SpritesData = Map<String, Array<String>>;

enum Sprite {
	ImageSprite( image: kha.Image );
	AtlasTextureSprite( subTexture: SubTexture );
	NineSliceSprite( subTexture: SubTexture, cutRegion: NineSliceRegion );
	SpriterEntitySprite( entity: EntityInstance, atlas: TextureAtlas, scale: Float );
}

enum FontSpriteData {
	TrueTypeFontSpriteData( fontUrl: String, size: Int, ?argb: String );
	BitmapFontSpriteData( fontUrl: String, ?argb: String );
}

enum FontSprite {
	TrueTypeFontSprite( fnt: kha.Font, size: Int, color: kha.Color ); // TODO (DK) x/y offset
	BitmapFontSprite( fnt: BitmapFont, pages: Array<kha.Image>, color: kha.Color );
}

typedef FontSpritesData = Map<String, Array<String>>;
