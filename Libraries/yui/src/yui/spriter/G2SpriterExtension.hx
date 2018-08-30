package yui.spriter;

import kha.graphics2.Graphics;
import kha.math.FastMatrix3;
import spriter.EntityInstance;
import yui.atlas.TextureAtlas;

// (DK) https://github.com/wighawag/spriterkha.git
	// - basically copy and paste of spriterkha.SpriterG2, but using a different atlas
class G2SpriterExtension {
	public static function drawSpriter( g2: Graphics, atlas: TextureAtlas, entity: EntityInstance, x: Float, y: Float, scale: Float ){
		var sprites = entity.sprites;
		var current = sprites.start;

		while (current < sprites.top) {
			var folderId = sprites.folderId(current);
			var fileId = sprites.fileId(current);
			var filename = entity.getFilename(folderId, fileId);
			var subImage = atlas.get(filename);

			if (subImage == null){
				current += entity.sprites.structSize;
				continue;
			}

			var pivotX = sprites.pivotX(current);
			var pivotY = sprites.pivotY(current);
			var offsetX = subImage.fx;
			var offsetY = subImage.fy;
			var width = subImage.fw;
			var height = subImage.fh;
			var originX = pivotX * width - offsetX;
			var originY = (1.0 - pivotY) * height - offsetY;
			var locationX = scale * sprites.x(current) + x;
			var locationY = scale * -sprites.y(current) + y;
			var scaleX = sprites.scaleX(current) * scale;
			var scaleY = sprites.scaleY(current) * scale;
			var angle = -sprites.angle(current);

			g2.pushTransformation(
				g2.transformation.multmat(
					FastMatrix3.translation(locationX, locationY)
						.multmat(
							FastMatrix3.rotation(angle)
								.multmat(FastMatrix3.scale(scaleX, scaleY))
								.multmat(FastMatrix3.translation(-originX, -originY))
						)
				)
			);
			g2.drawScaledSubImage(subImage.image, subImage.sx, subImage.sy, subImage.sw, subImage.sh, 0, 0, subImage.fw, subImage.fh);
			g2.popTransformation();

			current += entity.sprites.structSize;
		}
	}
}
