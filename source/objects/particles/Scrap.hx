package objects.particles;

import flixel.graphics.FlxGraphic;
import flixel.effects.particles.FlxParticle;
import states.PlayState;

class Scrap extends FlxParticle {
	var characterID:String = 'goober';

	var _swaySpeed:Float = 3;
	var _swayDist:Float = 180;
	var _age:Float = 0;
	var _maxAge:Float = 1;

	public function new() {
		super();
		this._swaySpeed = FlxG.random.float(1, 3);
		this._swayDist = FlxG.random.float(45, 180);
		this._maxAge = FlxG.random.float(1, 2);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (y + velocity.y * elapsed >= PlayState.floorY - height) {
			velocity.y = 0;
			angle = FlxMath.lerp(angle, 0, elapsed * 3);
			_age += elapsed;
		} else {
			offset.x = Math.sin(age * _swaySpeed) * _swayDist;
			angle = Math.sin(age * _swaySpeed) * _swayDist / 5;

			velocity.x = FlxMath.lerp(velocity.x, 0, elapsed * 5);
			velocity.y = FlxMath.lerp(velocity.y, 150, elapsed * 3);
		}
		alpha = FlxMath.bound(0, _maxAge - _age, 1);
		if (_age >= _maxAge) {
			destroy();
		}
	}
}
