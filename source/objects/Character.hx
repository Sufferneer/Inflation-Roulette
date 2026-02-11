package objects;

import backend.GameplayManager;
import backend.types.CharacterData;
import backend.types.CharacterSpriteData;
import backend.types.ModifierData;
import backend.types.SkillData;
import backend.types.AnimationData;
import flash.media.Sound;
import flixel.graphics.frames.FlxAtlasFrames;
import objects.Modifier;
import objects.Skill;
import states.PlayState;
import tjson.TJSON as Json;

class Character extends FlxSprite {
	// Metadata //
	public var id:String = 'unnamed';
	public var name:String = 'Unnamed';
	public var description:String = 'No description.';
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var animSoundPaths:Map<String, Array<String>>;
	public var belchThreshold:Int = 3;
	public var gurgleThreshold:Int = 2;
	public var creakThreshold:Int = 4;
	public var originPosition:Array<Int> = [0, 0];
	public var poppedCameraOffset:Array<Int> = [0, 0];
	public var cameraOffset:Array<Int> = [0, 0];
	public var pointerOffset:Array<Int> = [0, 0];
	public var poppingGravityMultiplier:Float = 1.0;
	public var poppingVelocityMultiplier:Array<Float> = [1, 1];
	public var disablePopping:Bool = false;

	// Gameplay Variables //
	public var currentPressure:Int = 0;
	public var maxPressure:Int = 4;
	public var currentConfidence:Int = 0;
	public var maxConfidence:Int = 4;
	public var currentSkills:Array<Skill> = [];

	public var modifiers:Array<Modifier> = [];
	public var skills:Array<Skill> = [];

	public var cpuControlled:Bool = true;

	// Modifier-Related Variables //
	public var confidenceChangeOnLiveShot:Int = 1;
	public var confidenceChangeOnBlankShot:Int = 1;

	// Cosmetic Variables //
	public var idleAfterAnimation:Bool = true;
	public var disableBellySounds:Bool = false;

	var gurgleTimer:Float = 0;
	var creakTimer:Float = 0;

	public function new(character:String, x:Float = 0, y:Float = 0) {
		super(x, y);

		this.id = character;
		var rawJson = Paths.getTextFromFile('data/characters/' + id + '/gameplay.json');
		var json:CharacterData = cast Json.parse(rawJson);

		var rawJson2 = Paths.getTextFromFile('data/characters/' + id + '/cosmetic.json');
		var spriteJson:CharacterSpriteData = cast Json.parse(rawJson2);

		name = json.name;
		if (json.description != null)
			description = json.description;
		maxPressure = json.maxPressure;
		maxConfidence = json.maxConfidence;
		belchThreshold = spriteJson.belchThreshold;
		gurgleThreshold = spriteJson.gurgleThreshold;
		creakThreshold = spriteJson.creakThreshold;
		if (spriteJson.originPosition != null)
			originPosition = spriteJson.originPosition;
		if (spriteJson.poppedCameraOffset != null)
			poppedCameraOffset = spriteJson.poppedCameraOffset;
		if (spriteJson.cameraOffset != null)
			cameraOffset = spriteJson.cameraOffset;
		if (spriteJson.pointerOffset != null)
			pointerOffset = spriteJson.pointerOffset;
		if (spriteJson.poppingVelocityMultiplier != null)
			poppingVelocityMultiplier = spriteJson.poppingVelocityMultiplier;
		disablePopping = !!spriteJson.disablePopping;
		poppingGravityMultiplier = spriteJson.poppingGravityMultiplier;

		var combinedAtlas:FlxAtlasFrames = Paths.sparrowAtlas('game/characters/$id/${spriteJson.spriteSheets[0]}');
		for (i in 1...spriteJson.spriteSheets.length) {
			var atlas:FlxAtlasFrames = Paths.sparrowAtlas('game/characters/$id/${spriteJson.spriteSheets[i]}');
			combinedAtlas.addAtlas(atlas, false);
		}
		frames = combinedAtlas;
		antialiasing = (!Preferences.data.enableForceAliasing) ? !!spriteJson.antialiasing : false;

		animOffsets = new Map<String, Array<Dynamic>>();
		animSoundPaths = new Map<String, Array<String>>();

		var animationsArray = spriteJson.animations;
		if (animationsArray != null && animationsArray.length > 0) {
			for (anim in animationsArray) {
				var animName:String = '' + anim.name;
				var animPrefix:String = '' + anim.prefix + '0'; // Prevent wocky shit from happening
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop;
				var animIndices:Array<Int> = anim.indices;
				if (animIndices != null && animIndices.length > 0) {
					animation.addByIndices(animName, animPrefix, animIndices, "", animFps, animLoop);
				} else {
					animation.addByPrefix(animName, animPrefix, animFps, animLoop);
				}
				if (anim.offset != null && anim.offset.length > 1) {
					addOffset(animName, anim.offset[0], anim.offset[1]);
				} else {
					trace('Character $id has no offsets for animation ${animName}. Using default offsets.');
				}
				if (anim.soundPaths != null)
					addSoundPath(animName, anim.soundPaths);
			}
		} else {
			trace('Character $id has no animations');
			animation.addByPrefix('idle0', 'idle0', 24);
		}
		animation.finishCallback = function(animName:String) {
			if (idleAfterAnimation && !animName.startsWith('idle'))
				playAnim('idle' + parseAnimationSuffix());
			else if (animExists(animName + '-loop') && !idleAfterAnimation)
				playAnim(animName + '-loop', false, false);
		}

		var modifiersArray:Array<ModifierData> = json.modifiers;
		if (modifiersArray != null && modifiersArray.length > 0) {
			for (modifier in modifiersArray) {
				var modifierID:String = '' + modifier.id;
				var modifierValue:Float = modifier.value;
				modifiers.push(new Modifier(modifierID, modifierValue));
			}
		}

		parseModifiers();

		var skillsArray:Array<SkillData> = json.skills;
		if (skillsArray != null && skillsArray.length > 0) {
			for (skill in skillsArray) {
				if (skills.length < 3) {
					var skillID:String = '' + skill.id;
					var skillCost:Int = skill.cost;
					skills.push(new Skill(skillID, skillCost, 1));
					currentSkills.push(new Skill(skillID, skillCost, GameplayManager.currentGamemode.skillsCostMultiplier));
				}
			}
		}

		trace('$id MODIFIERS: ' + modifiers);
		trace('$id SKILLS: ' + skills);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (currentPressure <= maxPressure || !disableBellySounds) {
			if (Preferences.data.allowBellyGurgles) {
				if (gurgleThreshold >= -1 && currentPressure >= gurgleThreshold) {
					gurgleTimer -= elapsed;
					if (gurgleTimer < 0) {
						var intensity = Math.min(1, (currentPressure - gurgleThreshold + 1) / (maxPressure - gurgleThreshold + 1));
						gurgleTimer = FlxG.random.float(1.0, 5.0) / intensity;
						SuffState.playSound(Paths.soundRandom('belly/gurgles/gurgle', 1, Constants.GURGLES_SAMPLE_COUNT), intensity * 0.65,
							FlxG.random.float(0.5, 2.0));
					}
				}
			}
			if (Preferences.data.allowBellyCreaks) {
				if (creakThreshold >= -1 && currentPressure >= creakThreshold) {
					creakTimer -= elapsed;
					if (creakTimer < 0) {
						var intensity = Math.min(1, (currentPressure - creakThreshold + 1) / (maxPressure - creakThreshold + 1));
						creakTimer = FlxG.random.float(1.0, 5.0) / intensity;
						SuffState.playSound(Paths.soundRandom('belly/creaks/creak', 1, Constants.CREAKS_SAMPLE_COUNT), intensity * 0.65,
							FlxG.random.float(0.5, 1.0));
					}
				}
			}
		}
	}

	public function parseModifiers() {
		for (modifier in modifiers) {
			switch (modifier.id) {
				case 'liveShotConfidenceChange':
					confidenceChangeOnLiveShot += Std.int(modifier.value);
				case 'blankShotConfidenceChange':
					confidenceChangeOnBlankShot += Std.int(modifier.value);
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) {
		animOffsets[name] = [x, y];
	}

	function trimAnimationName(AnimName:String) {
		var leAnim = AnimName;
		for (i in 0...maxPressure + 1) {
			leAnim = leAnim.replace('' + i, '');
		}
		leAnim = leAnim.replace('Null', '');
		leAnim = leAnim.replace('Overinflated', '');
		return leAnim;
	}

	public function addSoundPath(name:String, pathArray:Array<String>) {
		if (!animSoundPaths.exists(name))
			animSoundPaths[name] = [];
		for (path in pathArray) {
			animSoundPaths[name].push(path);
		}
	}

	public function animExists(AnimName:String):Bool {
		return (animation.getByName(AnimName) != null);
	}

	public function playAnim(AnimName:String, BackToIdle:Bool = true, Force:Bool = true, flipX:Bool = false, playSound:Bool = true, Reversed:Bool = false,
			Frame:Int = 0):Void {
		var usedAnimName:String = joinAnimationName(AnimName);
		if (!animExists(usedAnimName)) {
			trace('Animation [${usedAnimName}] for $id does not exist');
			return;
		}
		animation.getByName(usedAnimName).flipX = flipX;
		animation.play(usedAnimName, Force, Reversed, Frame);

		if (Force)
			idleAfterAnimation = BackToIdle;

		var daOffset = animOffsets.get(usedAnimName);
		if (animOffsets.exists(usedAnimName)) {
			offset.set(daOffset[0] + originPosition[0], daOffset[1] + originPosition[1]);
		} else {
			offset.set(originPosition[0], originPosition[1]);
		}

		if (playSound) {
			var daSoundList:Array<String> = animSoundPaths.get(usedAnimName);
			if (animSoundPaths.exists(usedAnimName)) {
				var daSound = daSoundList[FlxG.random.int(0, daSoundList.length - 1)];
				SuffState.playSound(Paths.sound(daSound));
			}
		}
	}

	public function parseAnimationSuffix() {
		return switch (currentPressure) {
			case(_ > maxPressure) => true:
				if (PlayState.currentSessionAllowPopping) 'Null'; else 'Overinflated';
			default:
				'' + currentPressure;
		}
	}

	public function calculatePressurePercentage(multiplied:Bool = false):Float {
		return currentPressure / maxPressure * (multiplied ? 100 : 1);
	}

	public function resizeOffsets() {
		for (i in animOffsets.keys())
			animOffsets[i] = [animOffsets[i][0] * scale.x, animOffsets[i][1] * scale.y];
	}

	function joinAnimationName(AnimName:String, checkForExistance:Bool = true):String {
		var usedAnimName:String = AnimName;
		if (checkForExistance && animExists(AnimName + parseAnimationSuffix()))
			usedAnimName = AnimName + parseAnimationSuffix();
		return usedAnimName;
	}

	function joinSoundName(AnimName:String):String {
		var usedAnimName:String = AnimName;
		if (animSoundPaths.get(AnimName + parseAnimationSuffix()) != null
			&& animSoundPaths.get(AnimName + parseAnimationSuffix()).length > 0)
			usedAnimName = AnimName + parseAnimationSuffix();
		return usedAnimName;
	}

	public function getCurAnimLength():Float {
		return getAnimLength(animation.curAnim.name);
	}

	public function getAnimLength(AnimName:String):Float {
		var usedAnimName:String = joinAnimationName(AnimName);
		var leAnim = animation.getByName(usedAnimName);
		return leAnim != null ? (leAnim.frames.length - 1) / leAnim.frameRate : 0;
	}

	public function isEliminated() {
		return currentPressure > maxPressure;
	}

	override function toString():String {
		return 'Character(id: ${id} | name: ${name} | ${currentPressure} / ${maxPressure})';
	}
}
