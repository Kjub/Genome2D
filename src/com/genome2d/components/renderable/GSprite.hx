/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderable;

import com.genome2d.textures.GTextureSourceType;
import com.genome2d.animation.GFrameAnimation;
import com.genome2d.geom.GRectangle;
import com.genome2d.geom.GMatrix;
import com.genome2d.context.filters.GFilter;
import com.genome2d.context.GCamera;
import com.genome2d.input.GMouseInputType;
import com.genome2d.node.GNode;
import com.genome2d.components.GComponent;
import com.genome2d.input.GMouseInput;
import com.genome2d.textures.GTexture;

/**
    Component used for rendering textured quads used as a super class for `GSprite` and `GMovieClip`
**/
class GSprite extends GTexturedQuad
{
	static public function create(p_node:GNode, p_texture:GTexture, p_x:Float = 0, p_y:Float = 0, p_rotation:Float = 0, p_scaleX:Float = 1, p_scaleY:Float = 1):GSprite {
		var sprite:GSprite = p_node == null ? GNode.createWithComponent(GSprite) : p_node.addComponent(GSprite);
		sprite.texture = p_texture;
		sprite.node.setPosition(p_x, p_y);
		sprite.node.rotation = p_rotation;
		sprite.node.setScale(p_scaleX, p_scaleY);
		
		return sprite;
	}
	
	public var frameAnimation:GFrameAnimation;
	
	override public function init():Void {
		super.init();
	}
	
    @:dox(hide)
    inline override public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        if (frameAnimation != null) {
			frameAnimation.update(g2d_node.core.getCurrentFrameDeltaTime());
			texture = frameAnimation.currentFrameTexture;
		}

        if (texture != null && (texture.getSourceType() != GTextureSourceType.RENDER_TARGET || texture.isRenderTargetInitialized())) {
            if (p_useMatrix && !ignoreMatrix) {
                var matrix:GMatrix = node.core.g2d_renderMatrix;
                node.core.getContext().drawMatrix(texture, blendMode, matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty, node.g2d_worldRed, node.g2d_worldGreen, node.g2d_worldBlue, node.g2d_worldAlpha, filter);
            } else {
                node.core.getContext().draw(texture, blendMode, node.g2d_worldX, node.g2d_worldY, node.g2d_worldScaleX, node.g2d_worldScaleY, node.g2d_worldRotation, node.g2d_worldRed, node.g2d_worldGreen, node.g2d_worldBlue, node.g2d_worldAlpha, filter);
            }
        }
    }
}