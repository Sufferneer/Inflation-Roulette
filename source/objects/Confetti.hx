package objects;

import flixel.graphics.FlxGraphic;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.util.FlxDirectionFlags;
import states.PlayState;

class Confetti extends FlxTypedEmitter<ConfettiPiece> {
	public function new(x:Float, y:Float, angle:Float) {
		super(x, y);
		particleClass = ConfettiPiece;

		var leImage:FlxGraphic = Paths.image('game/bgParticles/confetti');
		loadParticles(leImage, 30, 0, true);

		launchAngle.set(angle - 45, angle + 45);
		angularVelocity.set(-90, 90);
		speed.set(250, 500);
		lifespan.set(30, 30);

		start(true, 0.1, 0);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}

class ConfettiPiece extends FlxParticle {
	var _swaySpeed:Float = 3;
	var _swayDist:Float = 90;

	var _age:Float = 0;
	var _actualScaleX:Float = 0;
	var _actualScaleY:Float = 0;

	var _dying:Bool = false;

	public function new() {
		super();
		this._swaySpeed = FlxG.random.float(2, 6);
		this._swayDist = FlxG.random.float(15, 90);
		this._actualScaleX = FlxG.random.int(50, 100) / 100;
		this._actualScaleY = FlxG.random.int(50, 100) / 100;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		_age += elapsed;
		if (y + velocity.y * elapsed >= PlayState.floorY - width / 2) {
			if (!_dying) {
				_dying = true;
				FlxTween.tween(this, {alpha: 0}, 1, {
					startDelay: FlxG.random.float(0.5, 2),
					onComplete: function(_:FlxTween) {
						destroy();
					}
				});
			}
			angularVelocity = 0;
			angle = 0;
			velocity.x /= (1 + elapsed * 15);
			velocity.y = 0;
		} else {
			offset.x = Math.sin(_age * _swaySpeed / 4) * _swayDist;
			scale.set(_actualScaleX, Math.sin(_age * _swaySpeed) * _actualScaleY);

			velocity.x = FlxMath.lerp(velocity.x, 0, elapsed / 2);
			velocity.y = FlxMath.lerp(velocity.y, 150, elapsed);
		}
	}
}
