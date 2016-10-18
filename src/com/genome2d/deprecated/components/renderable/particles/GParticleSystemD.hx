/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2014 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.deprecated.components.renderable.particles;

import com.genome2d.context.GBlendMode;
import com.genome2d.components.renderable.IGRenderable;
import com.genome2d.input.GMouseInput;
import com.genome2d.textures.GTextureManager;
import com.genome2d.deprecated.particles.GParticlePoolD;
import com.genome2d.deprecated.particles.IGInitializerD;
import com.genome2d.deprecated.particles.IGAffectorD;
import com.genome2d.deprecated.particles.GParticleD;
import com.genome2d.geom.GRectangle;
import com.genome2d.geom.GCurve;
import com.genome2d.components.GComponent;
import com.genome2d.node.GNode;
import com.genome2d.textures.GTexture;
import com.genome2d.context.GCamera;

/**
    Component handling advanced particles systems with unlimited extendibility using custom particles instances and user defined affectors and initializers
 **/
@:access(com.genome2d.deprecated.particles.GParticleD)
class GParticleSystemD extends GComponent implements IGRenderable
{
    public var blendMode:GBlendMode;

    public var timeDilation:Float = 1;

    public var emit:Bool = true;

    private var g2d_initializers:Array<IGInitializerD>;
    private var g2d_initializersCount:Int = 0;
    public function addInitializer(p_initializer:IGInitializerD):Void {
        g2d_initializers.push(p_initializer);
        g2d_initializersCount++;
    }

    private var g2d_affectors:Array<IGAffectorD>;
    private var g2d_affectorsCount:Int = 0;
    public function addAffector(p_affector:IGAffectorD):Void {
        g2d_affectors.push(p_affector);
        g2d_affectorsCount++;
    }

    /**
     *  Duration of the particles system in seconds
     */
    public var duration:Float = 0;
    /**
     *  Loop particles emission
     */
    public var loop:Bool = true;

    public var emission:GCurve;
    public var emissionPerDuration:Bool = true;

    public var particlePool:GParticlePoolD;

    private var g2d_accumulatedTime:Float = 0;
    private var g2d_accumulatedSecond:Float = 0;
    private var g2d_accumulatedEmission:Float = 0;

    private var g2d_firstParticle:GParticleD;
    private var g2d_lastParticle:GParticleD;

    public var texture:GTexture;

    override public function init():Void {
        blendMode = GBlendMode.NORMAL;
        particlePool = GParticlePoolD.g2d_defaultPool;

        g2d_initializers = new Array<IGInitializerD>();
        g2d_affectors = new Array<IGAffectorD>();

        node.core.onUpdate.add(update);
    }

    public function reset():Void {
        g2d_accumulatedTime = 0;
        g2d_accumulatedSecond = 0;
        g2d_accumulatedEmission = 0;
    }

    public function burst(p_emission:Int):Void {
        for (i in 0...p_emission) {
            activateParticle();
        }
    }

    public function update(p_deltaTime:Float):Void {
        p_deltaTime *= timeDilation;
        if (emit && emission != null ) {
            var dt:Float = p_deltaTime * .001;
            if (dt>0) {
                g2d_accumulatedTime += dt;
                g2d_accumulatedSecond += dt;
                if (loop && duration!=0 && g2d_accumulatedTime>duration) g2d_accumulatedTime-=duration;
                if (duration==0 || g2d_accumulatedTime<duration) {
                    //while (nAccumulatedTime>duration) nAccumulatedTime-=duration;
                    //var currentEmission:Float = emission.calculate(nAccumulatedTime/duration);
                    while (g2d_accumulatedSecond>1) g2d_accumulatedSecond-=1;
                    var currentEmission:Float = (emissionPerDuration && duration!=0) ? emission.calculate(g2d_accumulatedTime/duration) : emission.calculate(g2d_accumulatedSecond);

                    if (currentEmission<0) currentEmission = 0;
                    g2d_accumulatedEmission += currentEmission * dt;

                    while (g2d_accumulatedEmission > 0) {
                        activateParticle();
                        g2d_accumulatedEmission--;
                    }
                }
            }
        }
        var particle:GParticleD = g2d_firstParticle;
        while (particle!=null) {
            var next:GParticleD = particle.g2d_next;
            for (i in 0...g2d_affectorsCount) {
                g2d_affectors[i].update(this, particle, p_deltaTime);
            }
            // If particles died during update remove it
            if (particle.die) deactivateParticle(particle);
            particle = next;
        }
    }

    public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        // TODO add matrix transformations
        var particle:GParticleD = g2d_firstParticle;
        while (particle!=null) {
            var next:GParticleD = particle.g2d_next;

            if (particle.overrideRender) {
                particle.render(p_camera, this);
            } else {
                var tx:Float = node.g2d_worldX + (particle.x-node.g2d_worldX)*1;//node.g2d_worldScaleX;
                var ty:Float = node.g2d_worldY + (particle.y-node.g2d_worldY)*1;//node.g2d_worldScaleY;

                if (particle.overrideUvs) {
                /*
                    var zu:Float = particle.texture.g2d_u;
                    particle.texture.uvX = particle.u;
                    var zv:Float = particle.texture.g2d_v;
                    particle.texture.uvY = particle.v;
                    var zuScale:Float = particle.texture.g2d_uScale;
                    particle.texture.uvScaleX = particle.uScale;
                    var zvScale:Float = particle.texture.g2d_vScale;
                    particle.texture.uvScaleY = particle.vScale;
                    node.core.getContext().draw(particle.texture, tx, ty, particle.scaleX*node.g2d_worldScaleX, particle.scaleY*node.g2d_worldScaleY, particle.rotation, particle.red*node.g2d_worldRed, particle.green*node.g2d_worldGreen, particle.blue*node.g2d_worldBlue, particle.alpha*node.g2d_worldAlpha, blendMode);
                    particle.texture.g2d_u = zu;
                    particle.texture.g2d_v = zv;
                    particle.texture.g2d_uScale = zuScale;
                    particle.texture.g2d_vScale = zvScale;
                /**/
                } else {
                    node.core.getContext().draw(particle.texture, blendMode, tx, ty, particle.scaleX*node.g2d_worldScaleX, particle.scaleY*node.g2d_worldScaleY, particle.rotation, particle.red*node.g2d_worldRed, particle.green*node.g2d_worldGreen, particle.blue*node.g2d_worldBlue, particle.alpha*node.g2d_worldAlpha);
                }
            }

            particle = next;
        }
    }

    private function activateParticle():Void {
        var particle:GParticleD = particlePool.g2d_get();
        if (g2d_lastParticle != null) {
            particle.g2d_previous = g2d_lastParticle;
            g2d_lastParticle.g2d_next = particle;
            g2d_lastParticle = particle;
        } else {
            g2d_firstParticle = particle;
            g2d_lastParticle = particle;
        }

        particle.spawn(this);

        for (i in 0...g2d_initializersCount) {
            g2d_initializers[i].initialize(this, particle);
        }
    }

    private function activateParticle2():Void {
        var particle:GParticleD = particlePool.g2d_get();
        if (g2d_firstParticle != null) {
            particle.g2d_next = g2d_firstParticle;
            g2d_firstParticle.g2d_previous = particle;
            g2d_firstParticle = particle;
        } else {
            g2d_firstParticle = particle;
            g2d_lastParticle = particle;
        }

        particle.spawn(this);

        for (i in 0...g2d_initializersCount) {
            g2d_initializers[i].initialize(this, particle);
        }
    }

    public function deactivateParticle(p_particle:GParticleD):Void {
        if (p_particle == g2d_lastParticle) g2d_lastParticle = g2d_lastParticle.g2d_previous;
        if (p_particle == g2d_firstParticle) g2d_firstParticle = g2d_firstParticle.g2d_next;
        p_particle.dispose();
    }

    public function getBounds(p_target:GRectangle = null):GRectangle {
        return null;
    }

    override public function dispose():Void {
        while (g2d_firstParticle != null) deactivateParticle(g2d_firstParticle);
        node.core.onUpdate.remove(update);

        super.dispose();
    }

    public function captureMouseInput(p_input:GMouseInput):Void {
    }
	
	public function hitTest(p_x:Float, p_y:Float):Bool {
        return false;
    }
}