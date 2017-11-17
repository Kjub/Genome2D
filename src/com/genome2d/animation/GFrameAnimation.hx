package com.genome2d.animation;
import com.genome2d.debug.GDebug;
import com.genome2d.textures.GTextureManager;
import com.genome2d.proto.GPrototypeExtras;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.GPrototype;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.textures.GTexture;

class GFrameAnimation implements IGPrototypable
{

    @prototype
	public var timeDilation:Float = 1;

    /**
        Is movieclip repeating after reaching the last frame, default true
    **/
    @prototype
    public var repeatable:Bool = true;

    /**
        Is playback reversed, default false
    **/
    @prototype
    public var reversed:Bool = false;

    private var g2d_speed:Float = 1000/30;
    private var g2d_accumulatedTime:Float = 0;
    private var g2d_lastUpdatedFrameId:Int = 0;
    private var g2d_startIndex:Int = -1;
    private var g2d_endIndex:Int = -1;
    private var g2d_playing:Bool = true;
	
	public var currentFrameTexture:GTexture;

    @prototype
	public var frameRate(get, set):Int;
    #if swc @:getter(frameRate) #end
    inline private function get_frameRate():Int {
        return Std.int(1000 / g2d_speed);
    }
	#if swc @:setter(frameRate) #end
    inline private function set_frameRate(p_value:Int):Int {
        g2d_speed = 1000 / p_value;
		return p_value;
    }
	
    /**
        Get the current frame count
    **/
    private var g2d_frameCount:Int;
    #if swc @:extern #end
    public var frameCount(get, never):Int;
    #if swc @:getter(frameCount) #end
    inline private function get_frameCount():Int {
        return g2d_frameCount;
    }

    /**
        Get the current frame index the movieclip is at
    **/
    private var g2d_currentFrame:Int = -1;
    #if swc @:extern #end
    public var currentFrame(get, never):Int;
    #if swc @:getter(currentFrame) #end
    inline private function get_currentFrame():Int {
        return g2d_currentFrame;
    }

    private var frames:String;

    /**
        Textures used for frames
    **/
    private var g2d_frameTextures:Array<GTexture>;
    #if swc @:extern #end
    public var frameTextures(never, set):Array<GTexture>;
    #if swc @:setter(frameTextures) #end
    inline private function set_frameTextures(p_value:Array<GTexture>):Array<GTexture> {
        g2d_frameTextures = p_value;
        g2d_frameCount = p_value.length;
        g2d_currentFrame = 0;
        if (g2d_frameTextures.length>0) {
            currentFrameTexture = g2d_frameTextures[0];
        } else {
            currentFrameTexture = null;
        }

        return g2d_frameTextures;
    }

    /**
	    Go to a specified frame
	**/
    public function gotoFrame(p_frame:Int):Void {
        if (g2d_frameTextures == null) return;
        g2d_currentFrame = p_frame;
        g2d_currentFrame %= g2d_frameCount;
        currentFrameTexture = g2d_frameTextures[g2d_currentFrame];
    }

    /**
        Go to a specified frame and start playing
    **/
    public function gotoAndPlay(p_frame:Int):Void {
        gotoFrame(p_frame);
        play();
    }

    /**
        Go to a specified frame and stop playing
    **/
    public function gotoAndStop(p_frame:Int):Void {
        gotoFrame(p_frame);
        stop();
    }

    /**
	    Stop playback
	**/
    public function stop():Void {
        g2d_playing = false;
    }

    /**
	    Start the playback
	**/
    public function play():Void {
        g2d_playing = true;
    }
	
	public function new():Void {
	}
	
	inline public function update(p_deltaTime:Float):Void {
        if (g2d_playing && g2d_frameCount>1) {
            g2d_accumulatedTime += p_deltaTime*timeDilation;

            if (g2d_accumulatedTime >= g2d_speed) {
                g2d_currentFrame += (reversed) ? -Std.int(g2d_accumulatedTime / g2d_speed) : Std.int(g2d_accumulatedTime / g2d_speed);
                if (reversed && g2d_currentFrame<0) {
                    if (repeatable) {
                        g2d_currentFrame = g2d_frameCount+g2d_currentFrame%g2d_frameCount;
                    } else {
                        g2d_currentFrame = 0;
                        g2d_playing = false;
                    }
                } else if (!reversed && g2d_currentFrame>=g2d_frameCount) {
                    if (repeatable) {
                        g2d_currentFrame = g2d_currentFrame%g2d_frameCount;
                    } else {
                        g2d_currentFrame = g2d_frameCount-1;
                        g2d_playing = false;
                    }
                }
                currentFrameTexture = g2d_frameTextures[g2d_currentFrame];
            }
            g2d_accumulatedTime %= g2d_speed;
        }
    }

    /****************************************************************************************************
	 * 	PROTOTYPE CODE
	 ****************************************************************************************************/

    public function getPrototype(p_prototype:GPrototype = null):GPrototype {
        p_prototype = getPrototypeDefault(p_prototype);

        if (g2d_frameTextures != null && g2d_frameTextures.length>0) {
            var textureIds:String = "@"+g2d_frameTextures[0].id;
            for (i in 1...g2d_frameTextures.length) {
                textureIds += ",@"+g2d_frameTextures[i].id;
            }
            p_prototype.createPrototypeProperty("frames", "String", GPrototypeExtras.IGNORE_AUTO_BIND, null, textureIds);
        }
        return p_prototype;
    }

    public function bindPrototype(p_prototype:GPrototype):Void {
        bindPrototypeDefault(p_prototype);

        if (p_prototype.hasProperty("frames")) {
            var textureString:String = p_prototype.getProperty("frames").value;
            if (textureString != "") {
                var textureIds:Array<String> = textureString.split(",");
                g2d_frameTextures = new Array<GTexture>();
                for (textureId in textureIds) {
                    var texture:GTexture = GTextureManager.getTexture(textureId.substr(1));
                    if (texture != null) g2d_frameTextures.push(texture);
                }
                g2d_frameCount = g2d_frameTextures.length;
            } else {
                g2d_frameTextures = null;
            }
        }
    }
}