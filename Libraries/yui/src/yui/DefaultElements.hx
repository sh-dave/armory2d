package yui;

// TODO (DK) this should only be the logic / state updates instead of drawing and whatnot
//   ClickBehavior:
//		onClick: send event
//   CheckBehavior
//		onClick: check <> unchecked; send event
//   RadioBehavior:
//		onClick: make active in group; send event
class DefaultElements {
	static function common( ui: Yui, canvas: TCanvas, e: TElement, x: Float, y: Float, w: Float, h: Float ) {
		var isHovered = ui.isHovered(x, y, w, h);
		var isPushed = ui.isPressed(x, y, w, h);
		var styleId = isPushed ? 'active' : isHovered ? 'hover' : 'idle';
		ui.setActiveStyle(canvas, e, styleId);
	}

	public static function drawImage( ui: Yui, canvas: TCanvas, e: TElement, x: Float, y: Float, w: Float, h: Float, on: String -> Void ) {
		common(ui, canvas, e, x, y, w, h);

		var sprite = ui.getSprite(e.asset);

		if (sprite != null) {
			ui.drawSprite(sprite, e, x, y, w, h);
		}

		// var isHovered = ui.isHovered(x, y, w, h);
		// var isPushed = ui.isPressed(x, y, w, h);
		var isReleased = ui.isReleased(x, y, w, h);

		if (isReleased) {
			var event = e.event;

			if (event != null && event != '') {
				on(event);
			}
		}
	}

	public static function drawButton( ui: Yui, canvas: TCanvas, e: TElement, x: Float, y: Float, w: Float, h: Float, on: String -> Void ) {
		common(ui, canvas, e, x, y, w, h);

		var sprites = ui.getSprites(e);

		if (sprites != null) {
			var style = ui.getActiveStyles(canvas, e);

			if (style != null) {
				var active = sprites.get(style);

				for (sp in active) {
					var sprite = ui.getSprite(sp);
					ui.drawSprite(sprite, e, x, y, w, h);
				}
			}
		}

		var isReleased = ui.isReleased(x, y, w, h);

		if (isReleased) {
			var event = e.event;

			if (event != null && event != '') {
				on(event);
			}
		}
	}

	public static function drawRadioButton( ui: Yui, canvas: TCanvas, e: TElement, x: Float, y: Float, w: Float, h: Float, on: String -> Void ) {
		common(ui, canvas, e, x, y, w, h);

		switch e.state {
			case RadioState(group, position):
				var isReleased = ui.isReleased(x, y, w, h);
				var sprites = ui.getSprites(e);

				if (sprites != null) {
					var isChecked = false;
					var checkStyle = isChecked ? 'selected:' : ''; // TODO (DK) get real state (checked / unchecked) from ui somehow
					var isHover = ui.isHovered(x, y, w, h);
					var isPushed = ui.isPressed(x, y, w, h);
					var style = isPushed ? '${checkStyle}pressed' : isHover ? '${checkStyle}hover' : '${checkStyle}idle';
					var active = sprites.get(style);

					for (sp in active) {
						var sprite = ui.getSprite(sp);
						ui.drawSprite(sprite, e, x, y, w, h);
					}
				}

				if (isReleased) {
					var event = e.event;

					if (event != null && event != '') {
						on(event);
					}
				}

			case other:
				trace('invalid state for this control');
		}
	}

	public static function drawCheckButton( ui: Yui, canvas: TCanvas, e: TElement, x: Float, y: Float, w: Float, h: Float, on: String -> Void ) {
		switch e.state {
			case CheckState(checked):
				// TODO (DK) get real state (checked / unchecked) from ui somehow

				var isReleased = ui.isReleased(x, y, w, h);
				var sprites = ui.getSprites(e);

				if (sprites != null) {
					var isChecked = false;
					var checkStyle = isChecked ? 'selected:' : '';
					var isHover = ui.isHovered(x, y, w, h);
					var isPushed = ui.isPressed(x, y, w, h);
					var stateId = isPushed ? '${checkStyle}pressed' : isHover ? '${checkStyle}hover' : '${checkStyle}idle';
					var active = sprites.get(stateId);

					for (sp in active) {
						var sprite = ui.getSprite(sp);
						ui.drawSprite(sprite, e, x, y, w, h);
					}
				}

				if (isReleased) {
					var event = e.event;

					if (event != null && event != '') {
						on(event);
					}
				}

			case other:
				trace('invalid state for this control');
		}
	}

	public static function drawText( ui: Yui, canvas: TCanvas, e: TElement, x: Float, y: Float, w: Float, h: Float, on: String -> Void ) {
		common(ui, canvas, e, x, y, w, h);

		var fsprites = ui.getFontSprites(e);

		if (fsprites != null) {
			var style = ui.getActiveStyles(canvas, e);

			if (style != null) {
				var active = fsprites.get(style);

				for (fsp in active) {
					var sprite = ui.getFontSprite(fsp);
					ui.drawFontSprite(sprite, e, x, y, w, h);
				}
			}
		}
	}
}
