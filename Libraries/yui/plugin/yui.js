var plugin = new Plugin();

// TODO (DK) this is the generated code from zui.Ext.list
//	how do we import that better?

// typedef ListOpts = {
// 	?addCb: String->Void,
// 	?removeCb: Int->Void,
// 	?getNameCb: Int->String,
// 	?setNameCb: Int->String->Void,
// 	?getLabelCb: Int->String,
// 	?itemDrawCb: Handle->Int->Void,
// 	?showRadio: Bool, // false
// 	?editable: Bool, // true
// 	?showAdd: Bool, // true
// 	?addLabel: String // 'Add'
// }

function list(ui,handle,ar,opts) {
	console.log(opts);

	var selected = 0;
	if(opts == null) {
		opts = { };
	}
	var addCb = opts.addCb != null ? opts.addCb : function(name) {
		ar.push(name);
	};
	var removeCb = opts.removeCb != null ? opts.removeCb : function(i) {
		ar.splice(i,1);
	};
	var getNameCb = opts.getNameCb != null ? opts.getNameCb : function(i1) {
		return ar[i1];
	};
	var setNameCb = opts.setNameCb != null ? opts.setNameCb : function(i2,name1) {
		ar[i2] = name1;
	};
	var getLabelCb = opts.getLabelCb != null ? opts.getLabelCb : function(i3) {
		return "";
	};
	var itemDrawCb = opts.itemDrawCb;
	var showRadio = opts.showRadio != null && opts.showRadio;
	var editable = opts.editable != null ? opts.editable : true;
	var showAdd = opts.showAdd != null ? opts.showAdd : true;
	var addLabel = opts.addLabel != null ? opts.addLabel : "Add";
	var i4 = 0;
	while(i4 < ar.length) {
		if(showRadio) {
			ui.row([0.12,0.68,0.2]);
			if(ui.radio(handle.nest(0),i4,"")) {
				selected = i4;
			}
		} else {
			ui.row([0.8,0.2]);
		}
		var itemHandle = handle.nest(i4);
		itemHandle.text = getNameCb(i4);
		if(editable) {
			setNameCb(i4,ui.textInput(itemHandle,getLabelCb(i4)));
		} else {
			ui.text(getNameCb(i4));
		}
		if(ui.button("X")) {
			removeCb(i4);
		} else {
			++i4;
		}
		if(itemDrawCb != null) {
			itemDrawCb(itemHandle.nest(i4),i4 - 1);
		}
	}
	if(showAdd && ui.button(addLabel)) {
		addCb("untitled");
	}
	return selected;
};

const spritesPanel = plugin.handle({ selected: true });
const fontSpritesPanel = plugin.handle({ selected: true });

const newSprite = plugin.handle();
	const newImageSpriteAsset = plugin.handle();

	const newAtlasSpriteAsset = plugin.handle();
	const newAtlasSpriteRegion = plugin.handle();

	const newNineSliceSpriteAsset = plugin.handle();
	const newNineSliceSpriteRegion = plugin.handle();
	const newNineSliceSpriteGridX = plugin.handle();
	const newNineSliceSpriteGridY = plugin.handle();
	const newNineSliceSpriteGridW = plugin.handle();
	const newNineSliceSpriteGridH = plugin.handle();

	const newSpriterEntityScml = plugin.handle();
	const newSpriterEntityEntity = plugin.handle();

const spritesList = plugin.handle();

// public function combo(handle: Handle, texts: Array<String>, label = "", showLabel = false, align: Align = Left): Int {
// public function textInput(handle: Handle, label = "", align:Align = Left, asFloat = false): String {
// public static function list(ui: Zui, handle: Handle, ar: Array<Dynamic>, ?opts: ListOpts ): Int {

plugin.drawRightUi = function( root, ui, tabs ) {
	if (ui.tab(tabs, 'YUI')) {
		if (ui.panel(spritesPanel, 'SPRITES')) {
			const spriteToCreate = ui.combo(newSprite, ['Image', 'AtlasTexture', 'NineSlice', 'SpriterEntity'], 'SpriteType', true);

			switch (spriteToCreate) {
				case 0:
					const imAssetId = ui.combo(newImageSpriteAsset, ['TODO', 'LIST', 'OF', 'ASSETS'], 'Image', true);
					break;
				case 1:
					const atAssetId = ui.combo(newAtlasSpriteAsset, ['TODO', 'LIST', 'OF', 'ASSETS'], 'Atlas', true);
					const atRegionId = ui.combo(newAtlasSpriteRegion, ['TODO', 'LIST', 'OF', 'REGIONS'], 'Region', true);
					break;
				case 2:
					const nsAssetId = ui.combo(newNineSliceSpriteAsset, ['TODO', 'LIST', 'OF', 'ASSETS'], 'Atlas', true);
					const nsRegionId = ui.combo(newNineSliceSpriteRegion, ['TODO', 'LIST', 'OF', 'REGIONS'], 'Region', true);
					ui.row([1 / 2, 1 / 2]);
					const nsGridX = ui.textInput(newNineSliceSpriteGridX, 'X');
					const nsGridY = ui.textInput(newNineSliceSpriteGridY, 'Y');
					ui.row([1 / 2, 1 / 2]);
					const nsGridW = ui.textInput(newNineSliceSpriteGridW, 'Width');
					const nsGridH = ui.textInput(newNineSliceSpriteGridH, 'Height');
					break;
				case 3:
					const spScml = ui.combo(newSpriterEntityScml, ['TODO', 'LIST', 'OF', 'ASSETS'], 'Scml', true);
					const spEntity = ui.combo(newSpriterEntityEntity, ['TODO', 'LIST', 'OF', 'ENTITIES'], 'Entity', true);
					// const spScml = ui.combo(newSpriterEntityScml, ['TODO', 'LIST', 'OF', 'ASSETS'], 'Scml', true);
					break;
			}

			if (ui.button('Create Sprite')) {

			}

			ui.separator();

			// public static function list(ui: Zui, handle: Handle, ar: Array<Dynamic>, ?opts: ListOpts ): Int {

			ui.indent();

			var selectedSprite = list(ui, spritesList, ['ABC', 'DEF', 'GHI', 'JKL'], {
				showAdd: false,
				editable: false,
			});

			ui.unindent();
		}

		ui.separator();

		if (ui.panel(fontSpritesPanel, 'FONT-SPRITES')) {
		}
	}
}

// plugin.drawToolbarUi = function( root, ui, tabs ) {
//     if (ui.tab(tabs, 'YUI')) {
//         if (ui.button('Composite')) {
//         }
//     }
// }

// plugin.drawToolsUi = function( root, ui ) {
//     if (ui.button('YuiComposite')) {
//     }
// }
