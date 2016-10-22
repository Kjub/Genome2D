/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.text;

import com.genome2d.geom.GRectangle;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.textures.GTexture;
import com.genome2d.textures.GTextureManager;

class GTextureFont implements IGPrototypable {
	@prototype
	public var texture:GTexture;
	
	@prototype
	public var id:String;
	
	@prototype
    public var lineHeight:Int = 0;

	@prototype
	public var base:Int = 0;

	@prototype
	public var face:String;

	@prototype
	public var italic:Bool = false;

	@prototype
	public var bold:Bool = false;
	
	private var g2d_chars:Map<String,GTextureChar>;
	
    public var kerning:Map<Int,Map<Int,Int>>;
	
	public function new(p_id:String, p_texture:GTexture):Void {
		id = p_id;
		texture = p_texture;
		g2d_chars = new Map<String,GTextureChar>();
	}

    public function getChar(p_subId:String):GTextureChar {
        return cast g2d_chars.get(p_subId);
    }

    public function addChar(p_charId:String, p_region:GRectangle, p_xoffset:Float, p_yoffset:Float, p_xadvance:Float):GTextureChar {
        var charTexture:GTexture = GTextureManager.createSubTexture(texture.id+"_"+p_charId, texture, p_region);
		charTexture.pivotX = -p_region.width/2;
        charTexture.pivotY = -p_region.height/2;
		
		var char:GTextureChar = new GTextureChar(charTexture);
		char.xoffset = p_xoffset;
		char.yoffset = p_yoffset;
		char.xadvance = p_xadvance;
        g2d_chars.set(p_charId, char);

        return char;
    }

    public function getKerning(p_first:Int, p_second:Int):Float {
        if (kerning != null && kerning.exists(p_first)) {
            var map:Map<Int,Int> = kerning.get(p_first);
			if (!map.exists(p_second)) {
				return 0;
			} else {
				return map.get(p_second)*texture.scaleFactor;
			}
        }
		/**/
        return 0;
    }

	/*
	 *	Get a reference value
	 */
	public function toReference():String {
		return "@"+id;
	}
	
	static public function fromReference(p_reference:String) {
		return GFontManager.getFont(p_reference.substr(1));
	}
}