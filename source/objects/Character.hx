package objects;

import tjson.TJSON as Json;
import backend.types.CharacterData;
import backend.types.CharacterSpriteData;
import backend.types.ModifierData;
import backend.types.SkillData;
import backend.types.AnimationData;
import flash.media.Sound;

class Character extends FlxSprite {
	// Metadata //
	public var id:String = 'unnamed';
	public var name:String = 'Unnamed';
	public var description:String = 'No description.';
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var animSoundPaths:Map<String, Array<Sound>>;
	public var belchThreshold:Int = 3;
	public var gurgleThreshold:Int = 2;
	public var creakThreshold:Int = 4;
	public var positionOffset:Array<Int> = [0, 0];
	public var poppedCameraOffsetChange:Array<Int> = [0, 0];
	public var cameraOffset:Array<Int> = [0, 0];
	public var pointerOffset:Array<Int> = [0, 0];
	public var poppingGravityMultiplier:Float = 1.0;
	public var poppingVelocityMultiplier:Array<Float> = [1, 1];

	// Gameplay Variables //
	public var currentPressure:Int = 0;
	public var maxPressure:Int = 4;
	public var currentConfidence:Int = 0;
	public var maxConfidence:Int = 4;

	public var modifiers:Array<Modifier> = [];
	public var skills:Array<Skill> = [];

	public var cpuControlled:Bool = true;

	// Modifier-Related Variables //
	public var confidenceChangeOnLiveShot:Int = 1;
	public var confidenceChangeOnBlankShot:Int = 1;

	// Cosmetic Variables //
	public var idleAfterAnimation:Bool = true;
	var gurgleTimer:Float = 0;
	var creakTimer:Float = 0;

	public function new(character:String, x:Float = 0, y:Float = 0) {
		super(x, y);

		this.id = character;
		var rawJson = Paths.getTextFromFile('data/characters/' + id + '.json');
		var json:CharacterData = cast Json.parse(rawJson);

		var rawJson2 = Paths.getTextFromFile('data/characters/sprites/' + id + '.json');
		var spriteJson:CharacterSpriteData = cast Json.parse(rawJson2);

		name = json.name;
		if (json.description != null)
			description = json.description;
		maxPressure = json.maxPressure;
		maxConfidence = json.maxConfidence;
		belchThreshold = spriteJson.belchThreshold;
		gurgleThreshold = spriteJson.gurgleThreshold;
		creakThreshold = spriteJson.creakThreshold;
		if (spriteJson.positionOffset != null)
			positionOffset = spriteJson.positionOffset;
		if (spriteJson.poppedCameraOffsetChange != null)
			poppedCameraOffsetChange = spriteJson.poppedCameraOffsetChange;
		if (spriteJson.cameraOffset != null)
			cameraOffset = spriteJson.cameraOffset;
		if (spriteJson.pointerOffset != null)
			pointerOffset = spriteJson.pointerOffset;
		if (spriteJson.poppingVelocityMultiplier != null)
			poppingVelocityMultiplier = spriteJson.poppingVelocityMultiplier;
		poppingGravityMultiplier = spriteJson.poppingGravityMultiplier;

		frames = Paths.sparrowAtlas('game/characters/' + id);

		animOffsets = new Map<String, Array<Dynamic>>();
		animSoundPaths = new Map<String, Array<Sound>>();

		var animationsArray = spriteJson.animations;
		if (animationsArray != null && animationsArray.length > 0) {
			for (anim in animationsArray) {
				var animName:String = '' + anim.name;
				var animPrefix:String = '' + anim.prefix;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop;
				var animIndices:Array<Int> = anim.indices;
				if (animIndices != null && animIndices.length > 0) {
					animation.addByIndices(animName, animPrefix, animIndices, "", animFps, animLoop);
				} else {
					animation.addByPrefix(animName, animPrefix, animFps, animLoop);
				}
				if (anim.offsets != null && anim.offsets.length > 1) {
					addOffset(animName, anim.offsets[0], anim.offsets[1]);
				} else {
					trace('Character $name has no offsets for animation ${animName}. Using default offsets.');
				}
				addSoundPath(animName, anim.soundPaths);
			}
		} else {
			trace('Character $name has no animations');
			animation.addByPrefix('idle0', 'idle0', 24);
		}
		animation.finishCallback = function(animName:String) {
			if (idleAfterAnimation && !animName.startsWith('idle'))
				playAnim('idle' + parseAnimationSuffix());
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
				var skillID:String = '' + skill.id;
				var skillCost:Int = skill.cost;
				skills.push(new Skill(skillID, skillCost));
			}
		}

		trace('$name MODIFIERS: ' + modifiers);
		trace('$name SKILLS: ' + skills);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (currentPressure <= maxPressure) {
			if (Preferences.data.allowBellyGurgles) {
				if (currentPressure >= gurgleThreshold) {
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
				if (currentPressure >= creakThreshold) {
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

	public function addSoundPath(name:String, pathArray:Array<String> = null) {
		var usedName:String = name;
		var trimmedName:String = trimAnimationName(usedName);
		if (!animSoundPaths.exists(usedName))
			animSoundPaths[usedName] = [];
		if (!animSoundPaths.exists(trimmedName))
			animSoundPaths[trimmedName] = [];
		if (animSoundPaths[usedName].length > 0 || animSoundPaths[trimmedName].length > 0)
			return;
		if (pathArray != null && pathArray.length > 0) {
			for (path in pathArray)
				animSoundPaths[usedName].push(Paths.sound(path));
			return;
		}

		// I am so sorry for this amalgamation
		final checkFolders:Array<String> = [id, 'GLOBAL'];
		for (folder in checkFolders) {
			var leFolder = 'characters/$folder/$trimmedName';
			var leFolderDep = 'characters/$folder/$usedName';
			if (Paths.fileExists(Paths.appendSoundExt('sounds/' + leFolder), SOUND)) { // animation-independent single sound path
				animSoundPaths[trimmedName].push(Paths.sound(leFolder));
				return;
			} else if (Paths.fileExists(Paths.appendSoundExt('sounds/' + leFolderDep), SOUND)) { // animation-dependent single sound path
				animSoundPaths[usedName].push(Paths.sound(leFolderDep));
				return;
			}
			leFolder = leFolder + '_';
			leFolderDep = leFolderDep + '_';
			var i = 1;
			if (Paths.fileExists(Paths.appendSoundExt('sounds/' + leFolder + i), SOUND)) { // animation-independent varied sound path
				while (Paths.fileExists(Paths.appendSoundExt('sounds/' + leFolder + i), SOUND)) {
					animSoundPaths[trimmedName].push(Paths.sound(leFolder + i));
					i++;
				}
				return;
			} else if (Paths.fileExists(Paths.appendSoundExt('sounds/' + leFolderDep + i), SOUND)) { // animation-dependent varied sound path
				while (Paths.fileExists(Paths.appendSoundExt('sounds/' + leFolderDep + i), SOUND)) {
					animSoundPaths[usedName].push(Paths.sound(leFolderDep + i));
					i++;
				}
				return;
			}
		}
	}

	public function animExists(AnimName:String):Bool {
		return (animation.getByName(AnimName) != null);
	}

	public function playAnim(AnimName:String, BackToIdle:Bool = true, Force:Bool = true, flipX:Bool = false, playSound:Bool = true, Reversed:Bool = false,
			Frame:Int = 0):Void {
		var usedAnimName:String = joinAnimationName(AnimName);
		if (!animExists(usedAnimName)) {
			trace('Animation [${AnimName + parseAnimationSuffix()}] for $name does not exist');
			return;
		}
		animation.getByName(usedAnimName).flipX = flipX;
		animation.play(usedAnimName, Force, Reversed, Frame);

		if (Force)
			idleAfterAnimation = BackToIdle;

		var daOffset = animOffsets.get(usedAnimName);
		if (animOffsets.exists(usedAnimName)) {
			offset.set(daOffset[0] - positionOffset[0], daOffset[1] - positionOffset[1]);
		} else {
			offset.set(-positionOffset[0], -positionOffset[1]);
		}

		if (playSound) {
			var daSoundList:Array<Sound> = animSoundPaths.get(joinSoundName(AnimName));
			if (daSoundList.length > 0) {
				var daSound = daSoundList[FlxG.random.int(0, daSoundList.length - 1)];
				if (daSound != null) {
					SuffState.playSound(daSound);
				}
			}
		}
	}

	function parseAnimationSuffix() {
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

	function joinAnimationName(AnimName:String):String {
		var usedAnimName:String = AnimName;
		if (animExists(AnimName + parseAnimationSuffix()))
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

	public function getLengthOfCurAnim():Float {
		return getLengthOfAnim(animation.curAnim.name);
	}

	public function getLengthOfAnim(AnimName:String):Float {
		var usedAnimName:String = joinAnimationName(AnimName);
		var leAnim = animation.getByName(usedAnimName);
		return leAnim != null ? leAnim.frames.length / leAnim.frameRate : 0;
	}

	public function isEliminated() {
		return currentPressure > maxPressure;
	}

	override function toString():String {
		return 'Character(id: ${id} || name: ${name} || ${currentPressure} / ${maxPressure})';
	}
}
