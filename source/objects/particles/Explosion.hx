package objects.particles;

import states.PlayState;

class Explosion extends FlxSprite {
	public function new(x:Float = 0, y:Float = 0, scale:Float = 2, volume:Float = 1, framerateDeviation:Int = 4) {
		super(x, y);
		this.frames = Paths.sparrowAtlas('game/particles/explosion');
		this.animation.addByPrefix('idle', 'explosion clean0', 24 - FlxG.random.int(-framerateDeviation, framerateDeviation), false);
		this.animation.play('idle');
		this.scale.set(scale, scale);
		this.updateHitbox();
		this.animation.finishCallback = function(name:String) {
			this.destroy();
		};

		if (volume > 0) {
			SuffState.playSound(Paths.sound('explosion'), volume);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
