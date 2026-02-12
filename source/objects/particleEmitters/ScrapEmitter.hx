package objects.particleEmitters;

import flixel.graphics.FlxGraphic;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxParticle;
import objects.particles.Scrap;
import states.PlayState;

class ScrapEmitter extends FlxTypedEmitter<Scrap> {
	var characterID:String = 'goober';

	public function new(character:Character) {
		super(character.x, character.y - character.width / 2.5, 25);
		particleClass = Scrap;

		this.characterID = character.id;

		var leImage:FlxGraphic = Paths.image('game/particles/scrap/$characterID');
		loadParticles(leImage, FlxG.random.int(6, 10), 0, true);

		start(true, 0.1, 0);
		launchMode = FlxEmitterMode.SQUARE;
		velocity.set(-1440 * 2, -480 * 4, 1440 * 2, 360 * 3);
		acceleration.set(0, 150);
		lifespan.set(999, 999);
		scale.set(1.0, 1.5);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}