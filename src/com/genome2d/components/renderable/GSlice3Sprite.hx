package com.genome2d.components.renderable;

import com.genome2d.context.GCamera;
import com.genome2d.textures.GTexture;

class GSlice3Sprite extends GTiledSprite {
    public var texture1:GTexture;
    public var texture2:GTexture;
    public var texture3:GTexture;

    @:dox(hide)
    override public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        // Calculate rotation
        var sin:Float = 0;
        var cos:Float = 1;
        if (node.g2d_worldRotation != 0) {
            sin = Math.sin(node.g2d_worldRotation);
            cos = Math.cos(node.g2d_worldRotation);
        }

        var ix:Int = Math.ceil(g2d_width/texture1.width);
        var iy:Int = Math.ceil(g2d_height/texture1.height);

        var w:Float = texture1.region.width;
        var h:Float = texture1.region.height;
        var cw:Float = w;
        var ch:Float = h;
        var cx:Float = 0;
        var cy:Float = 0;

        for (j in 0...iy) {
            for (i in 0...ix) {
                if (i==0) texture = texture1; else if (i==ix-1) texture = texture3; else texture = texture2;

                cw = (i==ix-2 && i!=0 && g2d_width%texture.width!=0) ? w*(g2d_width%texture.width)/texture.width : w;
                ch = (j==iy-1 && g2d_height%texture.height!=0) ? h*(g2d_height%texture.height)/texture.height : h;
                node.core.getContext().drawSource(texture, blendMode,
                                                  texture.region.x, texture.region.y, cw, ch, -cw*.5, -ch*.5,
                                                  node.g2d_worldX+cx*cos-cy*sin, node.g2d_worldY+cy*cos+cx*sin, node.g2d_worldScaleX, node.g2d_worldScaleY, node.g2d_worldRotation,
                                                  node.g2d_worldRed, node.g2d_worldGreen, node.g2d_worldBlue, node.g2d_worldAlpha,
                                                  filter);
                cx += cw*node.g2d_worldScaleX;
            }
            cx = 0;
            cy += ch*node.g2d_worldScaleY;
        }
    }
}
