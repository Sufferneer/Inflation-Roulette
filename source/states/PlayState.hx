package states;

import ui.objects.GameIcon;
import backend.CharacterManager;
import backend.GameplayManager;
import backend.enums.RoundRandomStatus;
import backend.enums.SuffTransitionStyle;
import objects.Character;
import objects.particles.Confetti;
import objects.particles.Scraps;
import objects.Skill;
import substates.PauseSubState;
import ui.objects.SkillCard;
import ui.objects.SuffBar;
import ui.objects.SuffIconButton;

class PlayState extends SuffState {
	// graphics
	var bg:FlxSprite;
	var pumpRack:FlxSprite;
	var floor:FlxSprite;

	public static final floorY:Float = 690;

	var floorBoundXLeft:Float = 0;
	var floorBoundXRight:Float = 0;
	var tableTop:FlxSprite;
	var tableStand:FlxSprite;

	var characterGroup:FlxTypedContainer<Character> = new FlxTypedContainer<Character>();

	var letterboxTop:FlxSprite;
	var letterboxBottom:FlxSprite;
	var letterboxDisplayed:Bool = false;

	var pumpGun:FlxSprite;
	var pumpGunDefaultY:Float = 0;
	var pumpGunDestinations:Array<Float> = [];

	var uiBGTop:FlxSprite;
	var uiBGBottom:FlxSprite;
	var uiBGGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var skillsText:FlxText;
	var skillsIcon:GameIcon;
	var skillCardsGroup:FlxTypedSpriteGroup<SkillCard> = new FlxTypedSpriteGroup<SkillCard>();

	static final skillCardsGroupPaddingX:Int = 10;
	static final skillCardsGroupPaddingY:Int = 50;

	var shootButton:SuffButton;

	var pressureBar:SuffBar;
	final pressureBarColors:Array<FlxColor> = [0xFF404060, 0xFFFFFFFF];
	var pressureIcon:GameIcon;
	var pressureText:FlxText;
	var confidenceIcon:GameIcon;
	var confidenceBar:SuffBar;
	final confidenceBarColors:Array<FlxColor> = [0xFF4A4399, 0xFF7970FF];
	var confidenceText:FlxText;
	var pauseButton:SuffIconButton;
	var cameraFocusButton:SuffIconButton;

	public static final playerWidthOffset:Float = 140;

	// Sounds
	public var ambientSound:FlxSound;

	// Game Logic
	var currentTurnIndex:Int = 0;
	var winnerIndex:Null<Int> = null;

	var cylinderContent:Array<Bool> = []; // True: Live, False: Blank
	var liveRoundDamage:Int = 1;
	// This array is only used when cylinderTrueRandomness is true.
	var roundRandomStatuses:Array<RoundRandomStatus> = [POSSIBLE];

	public static var hasSeenStartCutscene = false;

	public var canPause = true;
	public var isPaused = false;
	public var isEnding = false;

	public static var gameTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public static var gameTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();

	// cameras
	var camFollow:FlxObject;
	var camFollowOffset:Array<Float> = [0, 0];
	var camFollowZoom:Float = 0.8;
	var isManuallyFocusingStage:Bool = false;

	public static var camGame:FlxCamera;
	public static var camHUD:FlxCamera;
	public static var camOther:FlxCamera;

	// backend shit
	public static var instance:PlayState;

	public static var currentSessionAllowPopping:Bool = true;

	override public function create() {
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		Paths.precacheBellySounds();

		super.create();

		currentSessionAllowPopping = Preferences.data.allowPopping;

		currentTurnIndex = 0;

		camFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2, 1, 1);
		FlxG.camera.follow(camFollow, LOCKON);
		FlxG.camera.followLerp = Constants.DEFAULT_CAMERA_FOLLOW_LERP;

		reloadCylinder(GameplayManager.currentGamemode.cylinderLiveCount);

		bg = new FlxSprite().loadGraphic(Paths.image('game/backgrounds/${GameplayManager.currentBackground}/bg'));
		bg.screenCenter();
		bg.scrollFactor.set(0.3, 0.5);
		add(bg);

		pumpRack = new FlxSprite().loadGraphic(Paths.image('game/backgrounds/${GameplayManager.currentBackground}/pumpRack'));
		pumpRack.x = bg.x + (bg.width - pumpRack.width) / 2;
		pumpRack.y = -50;
		pumpRack.scrollFactor.set(0.4, 0.6);
		add(pumpRack);

		floor = new FlxSprite().loadGraphic(Paths.image('game/backgrounds/${GameplayManager.currentBackground}/floor'));
		floor.x = bg.x;
		floor.y = bg.y;
		floor.scrollFactor.set(0.5, 0.8);
		add(floor);

		var boundX = floor.x / floor.scrollFactor.x;
		var boundY = floor.y / floor.scrollFactor.y;
		floorBoundXLeft = boundX;
		floorBoundXRight = floorBoundXLeft + floor.width + floor.width * floor.scrollFactor.x * (2 / 3);

		FlxG.camera.setScrollBoundsRect(boundX, boundY, floorBoundXRight - floorBoundXLeft, floor.height + floor.height * floor.scrollFactor.y * (2 / 3));

		tableTop = new FlxSprite().loadGraphic(Paths.image('game/backgrounds/${GameplayManager.currentBackground}/tableTop'));
		tableTop.x = floor.x + (floor.width - tableTop.width) / 2;
		tableTop.y = 500;
		tableTop.scrollFactor.set(1.2, 1.1);
		tableTop.alpha = 0.75;

		tableStand = new FlxSprite().loadGraphic(Paths.image('game/backgrounds/${GameplayManager.currentBackground}/tableStand'));
		tableStand.x = tableTop.x;
		tableStand.y = tableTop.y;
		tableStand.scrollFactor.set(1.2, 1.1);

		pumpGun = new FlxSprite().loadGraphic(Paths.image('game/pumpGun'));

		add(characterGroup);
		for (i in 0...CharacterManager.selectedCharacterList.length) {
			var leX:Int = Std.int(tableTop.x
				+ playerWidthOffset
				+ i * (tableTop.width - playerWidthOffset * 2) / (CharacterManager.selectedCharacterList.length - 1));
			var char:Character = new Character(CharacterManager.selectedCharacterList[i], leX, floorY);
			if (i >= Std.int(CharacterManager.selectedCharacterList.length / 2)) {
				char.flipX = true;
			}
			char.playAnim('idle' + char.currentPressure);

			char.cpuControlled = !CharacterManager.playerControlled[i];

			pumpGunDestinations.push(char.x - pumpGun.width / 2);

			characterGroup.add(char);

			/* Create markers to indicate location of origin
				var cameraFollowPointer = new FlxSprite(char.x, char.y).loadGraphic(Paths.image('debug/pointer_cross'));
				cameraFollowPointer.offset.set(32, 32);
				add(cameraFollowPointer);
			 */
		}

		// skillsFixedPool or skillsRandomPool is not empty
		if (GameplayManager.currentGamemode.skillsFixedPool.length + GameplayManager.currentGamemode.skillsRandomPool.length > 0) {
			for (char in characterGroup) {
				char.currentSkills = [];
			}
			giveSkillsToAllPlayers(1);
		}

		pumpGun.x = pumpGunDestinations[currentTurnIndex];

		pumpGunDefaultY = tableStand.y + 20;
		pumpGun.y = pumpGunDefaultY;
		pumpGun.scrollFactor.set(1.25, 1.15);

		add(tableStand);
		add(tableTop);

		add(pumpGun);

		ambientSound = new FlxSound().loadEmbedded(Paths.sound('ambient'));
		ambientSound.volume = 0.25 * Preferences.data.gameSoundVolume;
		ambientSound.looped = true;
		ambientSound.play();

		// UI Stuff//
		letterboxTop = new FlxSprite().makeGraphic(FlxG.width, Std.int((FlxG.height - FlxG.width / 20 * 9) / 2), FlxColor.BLACK);
		letterboxTop.camera = camOther;
		letterboxTop.y = -letterboxTop.height;
		add(letterboxTop);

		letterboxBottom = new FlxSprite().makeGraphic(Std.int(letterboxTop.width), Std.int(letterboxTop.height), FlxColor.BLACK);
		letterboxBottom.camera = camOther;
		letterboxBottom.y = FlxG.height;
		add(letterboxBottom);

		uiBGGroup.camera = camHUD;
		add(uiBGGroup);

		uiBGTop = new FlxSprite().makeGraphic(500, FlxG.height, FlxColor.BLACK);
		uiBGTop.alpha = 0.25;
		uiBGGroup.add(uiBGTop);

		uiBGBottom = new FlxSprite().makeGraphic(500, FlxG.height, FlxColor.WHITE);
		uiBGBottom.alpha = 0.25;
		uiBGGroup.add(uiBGBottom);

		skillsText = new FlxText(0, 0, 0, 'SKILLS');
		skillsText.setFormat(Paths.font('default'), 32, FlxColor.WHITE);
		skillsText.x = uiBGTop.width - skillsText.width;
		uiBGGroup.add(skillsText);

		skillsIcon = new GameIcon(0, 0, 'stats/skill', 32);
		skillsIcon.x = skillsText.x - skillsIcon.width - 4;
		skillsIcon.y = skillsText.y + (skillsText.height - skillsIcon.height) / 2;
		uiBGGroup.add(skillsIcon);

		pressureIcon = new GameIcon(0, 0, 'stats/pressure', 32);
		uiBGGroup.add(pressureIcon);

		pressureText = new FlxText(pressureIcon.width + 4, 0, 0, '');
		pressureText.setFormat(Paths.font('default'), 16, pressureBarColors[0]);
		uiBGGroup.add(pressureText);

		pressureIcon.color = pressureText.color;

		pressureBar = new SuffBar(0, 0, function() return 0, 0, 1, 500, 20, 4, 1, pressureBarColors[0], pressureBarColors[1]);
		uiBGGroup.add(pressureBar);

		confidenceBar = new SuffBar(0, 0, function() return 0, 0, 1, 500, 20, 4, 1, confidenceBarColors[0], confidenceBarColors[1]);
		uiBGGroup.add(confidenceBar);

		confidenceIcon = new GameIcon(0, 0, 'stats/confidence', 32);
		uiBGGroup.add(confidenceIcon);

		confidenceText = new FlxText(confidenceIcon.width + 4, 0, 0, '');
		confidenceText.setFormat(Paths.font('default'), 16, confidenceBarColors[0]);
		uiBGGroup.add(confidenceText);

		confidenceIcon.color = confidenceText.color;

		skillCardsGroup.y = skillCardsGroupPaddingY;
		skillCardsGroup.camera = camHUD;
		add(skillCardsGroup);

		var shootButtonImage = Paths.image('gui/icons/buttons/shoot');
		var shootButtonHighlightedImage = Paths.image('gui/icons/buttons/shootHighlighted');
		shootButton = new SuffButton(0, 0, null, shootButtonImage, shootButtonHighlightedImage, shootButtonImage.width, shootButtonImage.height, false);
		shootButton.y = FlxG.height - shootButton.height;
		shootButton.camera = camHUD;
		shootButton.onClick = function() {
			deployGun(currentTurnIndex, function() return getPlayer(currentTurnIndex).calculatePressurePercentage());
		}
		add(shootButton);

		pauseButton = new SuffIconButton(20, 20, 'buttons/pause', null, 2);
		pauseButton.x = FlxG.width - pauseButton.width - 20;
		pauseButton.camera = camHUD;
		pauseButton.onClick = function() {
			pauseGame();
		};
		add(pauseButton);

		cameraFocusButton = new SuffIconButton(20, 20, 'buttons/camera', null, 2);
		cameraFocusButton.x = FlxG.width - cameraFocusButton.width - 20;
		cameraFocusButton.y = FlxG.height - cameraFocusButton.height - 20;
		cameraFocusButton.camera = camHUD;
		cameraFocusButton.onClick = function() {
			isManuallyFocusingStage = !isManuallyFocusingStage;
			if (isManuallyFocusingStage) {
				focusCameraOnStage();
				togglePlayerUI(false);
			} else {
				focusCameraOnPlayer(currentTurnIndex);
				togglePlayerUI(true);
			}
			updateSkillAvailability(currentTurnIndex);
		};
		add(cameraFocusButton);

		focusCameraOnPlayer(currentTurnIndex);
		if (!hasSeenStartCutscene) {
			playStartCutscene();
			hasSeenStartCutscene = true;
		} else {
			finishStartCutscene();
		}

		instance = this;
	}

	function deployGun(playerIndex:Int, delay:Void->Float = null) {
		// Delay is a function for dynamic value update via calculation
		var usedDelay = delay;
		if (delay == null)
			usedDelay = function() return 0;
		togglePlayerUI(false);
		toggleCameraFocusButton(false);
		toggleLetterbox(true);
		getPlayer(playerIndex).playAnim('preShoot', false);
		doTimer('playerShoot', new FlxTimer().start(getPlayer(playerIndex).getAnimLength('preShoot') + usedDelay(), function(_:FlxTimer) {
			shoot(playerIndex);
		}));
	}

	function toggleCameraFocusButton(show:Bool = false) {
		cameraFocusButton.disabled = !show;
		FlxTween.cancelTweensOf(cameraFocusButton, ['alpha']);
		FlxTween.tween(cameraFocusButton, {alpha: show ? 1 : 0}, 0.25);
	}

	function reloadPlayerUI(playerIndex:Int) {
		for (skillCard in skillCardsGroup) {
			skillCard.kill();
			skillCard.destroy();
		}
		skillCardsGroup.clear();

		// Dummy skill card to fix issue regarding tween issues after switching from a player with no skill.
		var skillCard:SkillCard = new SkillCard(0, 0, new Skill('reload'));
		skillCard.visible = false;
		skillCardsGroup.add(skillCard);

		var skills:Array<Skill> = getPlayer(playerIndex).currentSkills;
		skillsText.visible = skillsIcon.visible = (skills.length > 0);
		for (i in 0...skills.length) {
			var leSkill = skills[i];
			var skillCard:SkillCard = new SkillCard(0, i * (120 + skillCardsGroupPaddingX), leSkill);
			skillCard.onClick = function() {
				activateSkill(currentTurnIndex, i);
			}
			skillCardsGroup.add(skillCard);
		}
		updateSkillAvailability(playerIndex);

		uiBGTop.setGraphicSize(Std.int(skillCardsGroupPaddingX + 480 + skillCardsGroupPaddingX),
			Std.int(skillCardsGroupPaddingY + skillCardsGroup.height + skillCardsGroupPaddingX));
		uiBGTop.updateHitbox();
		uiBGBottom.y = pressureIcon.y = uiBGTop.height;
		pressureText.y = pressureIcon.y + (pressureIcon.height - pressureText.height) / 2;
		pressureBar.y = pressureIcon.y + pressureIcon.height;
		uiBGBottom.setGraphicSize(Std.int(uiBGTop.width), Std.int(FlxG.height - uiBGTop.height));
		uiBGBottom.updateHitbox();

		pressureBar.segments = Std.int(Math.max(1, getPlayer(playerIndex).maxPressure));
		pressureBar.valueFunction = function() {
			return getPlayer(playerIndex).currentPressure;
		}
		pressureBar.setBounds(0, getPlayer(playerIndex).maxPressure);

		confidenceBar.y = pressureBar.y + pressureBar.height;
		confidenceIcon.y = confidenceBar.y + confidenceBar.height;
		confidenceText.y = confidenceIcon.y + (confidenceIcon.height - confidenceText.height) / 2;

		updateUIText(playerIndex);

		confidenceBar.segments = Std.int(Math.max(1, getPlayer(playerIndex).maxConfidence));
		confidenceBar.valueFunction = function() {
			return getPlayer(playerIndex).currentConfidence;
		}
		confidenceBar.setBounds(0, getPlayer(playerIndex).maxConfidence);
	}

	function updateUIText(playerIndex:Int) {
		pressureText.text = getPlayer(playerIndex).currentPressure + ' / ' + getPlayer(playerIndex).maxPressure;
		confidenceText.text = getPlayer(playerIndex).currentConfidence + ' / ' + getPlayer(playerIndex).maxConfidence;
	}

	function updateSkillAvailability(playerIndex:Int) {
		for (skillCard in skillCardsGroup) {
			var disabled:Bool = getPlayer(playerIndex).currentConfidence < skillCard.skill.cost;
			if (disabled) {
				skillCard.notEnoughConfidence = true;
			} else {
				skillCard.notEnoughConfidence = false;
			}
		}
		updateUIText(playerIndex);
	}

	function animAllCharacters(animation:String, maxDelay:Float = 0.5, snapBackToIdle:Bool = true) {
		for (character in characterGroup) {
			new FlxTimer().start(FlxG.random.float() * maxDelay, function(_:FlxTimer) {
				character.playAnim(animation, snapBackToIdle);
			});
		}
	}

	function getMaximumAnimLength(animName:String) {
		var maxLength:Float = 0;
		for (character in characterGroup) {
			var length:Float = character.getAnimLength(animName);
			if (length > maxLength) {
				maxLength = length;
			}
		}
		return maxLength;
	}

	function playGunContactSound(volume:Float = 1) {
		SuffState.playSound(Paths.soundRandom('weapon', 1, 3));
	}

	function togglePauseFunctionality(enable:Bool = true) {
		canPause = enable;
		pauseButton.disabled = !enable;
	}

	function playStartCutscene() {
		togglePauseFunctionality(false);
		togglePlayerUI(false);
		cameraFocusButton.visible = false;
		toggleLetterbox(true);
		doTween('camHUD', FlxTween.tween(camHUD, {alpha: 0}, 0.5));
		focusCameraOnStage();
		SuffState.playMusic('cutscene', 0);
		FlxG.sound.music.fadeIn(1, 0, Preferences.data.musicVolume);
		pumpGun.y = -1000;

		// I am sorry future me
		animAllCharacters('introPartOne', 1, false); // All characters play their first intro animation
		new FlxTimer().start(1 + getMaximumAnimLength('introPartOne'), function(_:FlxTimer) { // First intro animation delay + 1.5 seconds
			FlxTween.tween(pumpGun, {y: pumpGunDefaultY}, 0.5, { // Gun lands on table
				onComplete: function(_:FlxTween) {
					animAllCharacters('introPartTwo', 0.5, true); // All characters play their second intro animation
					new FlxTimer().start(1 + getMaximumAnimLength('introPartTwo'), function(_:FlxTimer) {
						finishStartCutscene();
					});
					playGunContactSound(); // Gun bounces on table
					FlxTween.tween(pumpGun, {y: pumpGunDefaultY - 50}, 0.25, {
						ease: FlxEase.quadOut,
						onComplete: function(_:FlxTween) { // Gun lands on table 2nd time
							FlxTween.tween(pumpGun, {y: pumpGunDefaultY}, 0.25, {
								ease: FlxEase.quadIn,
								onComplete: function(_:FlxTween) { // Gun bounces on table 2nd time
									playGunContactSound();
									FlxTween.tween(pumpGun, {y: pumpGunDefaultY - 10}, 0.125, {
										ease: FlxEase.quadOut,
										onComplete: function(_:FlxTween) { // Gun lands on table FINAL TIME
											FlxTween.tween(pumpGun, {y: pumpGunDefaultY}, 0.125, {
												ease: FlxEase.quadIn,
												onComplete: function(_:FlxTween) {
													playGunContactSound();
												}
											});
										}
									});
								}
							});
						}
					});
				}
			});
		});
	}

	function finishStartCutscene() {
		togglePauseFunctionality(true);
		toggleLetterbox(false);
		cameraFocusButton.visible = true;
		SuffState.playMusic('game', 1, true);

		doTween('camHUD', FlxTween.tween(camHUD, {alpha: 1}, 0.5));

		changeTurn();
		if (getPlayer(currentTurnIndex).cpuControlled) {
			cpuAction();
		}
	}

	function reloadCylinder(liveRounds:Int = 1) {
		cylinderContent = [];
		var liveRoundsInserted:Int = 0;
		for (i in 0...GameplayManager.currentGamemode.cylinderSize) {
			cylinderContent.push(false);
		}
		while (liveRoundsInserted < Math.min(GameplayManager.currentGamemode.cylinderSize, liveRounds)) {
			var leIndex = FlxG.random.int(0, GameplayManager.currentGamemode.cylinderSize - 1);
			if (cylinderContent[leIndex] != true) {
				cylinderContent[leIndex] = true;
				liveRoundsInserted++;
			}
		}
		trace(cylinderContent);
	}

	function getPlayer(index:Int) {
		return characterGroup.members[index];
	}

	function activateSkill(playerIndex:Int, skillIndex:Int) {
		var skill = getPlayer(playerIndex).currentSkills[skillIndex];
		if (getPlayer(playerIndex).currentConfidence < skill.cost) {
			trace('Not enough confidence for Player ${playerIndex + 1}');
			return;
		}
		getPlayer(playerIndex).currentConfidence -= skill.cost;

		if (GameplayManager.currentGamemode.skillsExhaustible) {
			getPlayer(playerIndex).currentSkills.remove(skill);
		}

		var animName:String = 'skill' + Utils.capitalize(skill.id);
		var actualAnimName:String = animName + getPlayer(playerIndex).parseAnimationSuffix();
		var soundName:String = animName;
		if (getPlayer(playerIndex).animExists(actualAnimName)) {
			// Do nothing
		} else if (getPlayer(playerIndex).animExists(animName)) {
			actualAnimName = animName;
		} else {
			actualAnimName = 'skill';
		}
		getPlayer(playerIndex).playAnim(actualAnimName);

		switch (skill.id) {
			case 'reload':
				reloadCylinder(GameplayManager.currentGamemode.cylinderLiveCount);
			case 'sabotage':
				cylinderContent[0] = false;
				if (cylinderContent.length > 1) {
					cylinderContent[1] = true;
				} else {
					cylinderContent.push(true);
				}
				if (GameplayManager.currentGamemode.cylinderTrueRandomness) {
					roundRandomStatuses[0] = IMPOSSIBLE;
					if (roundRandomStatuses.length > 1) {
						roundRandomStatuses[1] = GUARANTEED;
					} else {
						roundRandomStatuses.push(GUARANTEED);
					}
				}
			case 'pressurize':
				liveRoundDamage *= 2;
			case 'polarize':
				cylinderContent[0] = !cylinderContent[0];
			case 'deflate':
				getPlayer(playerIndex).currentPressure -= 1;
				if (getPlayer(playerIndex).currentPressure < 0) {
					getPlayer(playerIndex).currentPressure = 0;
				}
		}

		toggleLetterbox(true);
		togglePlayerUI(false);
		toggleCameraFocusButton(false);
		// trace(getPlayer(playerIndex).animSoundPaths[soundName]);
		if (getPlayer(playerIndex).animSoundPaths[soundName] == null || getPlayer(playerIndex).animSoundPaths[soundName].length <= 0) {
			if (Paths.fileExists(Paths.appendSoundExt('sounds/characters/GLOBAL/' + soundName), SOUND)) {
				SuffState.playSound(Paths.sound('characters/GLOBAL/' + soundName));
			}
		}
		doTimer('reenablePlayerUI', new FlxTimer().start(getPlayer(playerIndex).getCurAnimLength(), function(_:FlxTimer) {
			getPlayer(playerIndex).playAnim('prepareShoot', false);
			reloadPlayerUI(playerIndex);
			togglePlayerUI((currentTurnIndex == playerIndex && CharacterManager.playerControlled[currentTurnIndex]));
			if (currentTurnIndex == playerIndex) {
				updateSkillAvailability(playerIndex);
				toggleCameraFocusButton(true);
			}
			toggleLetterbox(false);
		}));
	}

	function shoot(playerIndex:Int) {
		var dealDamage:Bool = false;
		if (!GameplayManager.currentGamemode.cylinderTrueRandomness)
			dealDamage = cylinderContent[0];
		else {
			switch (roundRandomStatuses[0]) {
				case GUARANTEED:
					dealDamage = true;
				case IMPOSSIBLE:
					dealDamage = false;
				default:
					dealDamage = FlxG.random.bool((GameplayManager.currentGamemode.cylinderLiveCount / GameplayManager.currentGamemode.cylinderSize) * 100);
			}
			roundRandomStatuses.shift();
			if (roundRandomStatuses.length <= 0)
				roundRandomStatuses = [POSSIBLE];
		}
		var playerAnimName:String = 'idle';

		SuffState.playSound(Paths.sound('shoot'));
		if (dealDamage) {
			playerAnimName = 'shootLive';
		} else {
			playerAnimName = 'shootBlank';
		}
		getPlayer(playerIndex).playAnim(playerAnimName, false);
		if (getPlayer(playerIndex).currentPressure >= getPlayer(playerIndex).maxPressure) {
			FlxG.sound.music.pause();
		}
		if (dealDamage) {
			SuffState.playSound(Paths.sound('shootLive'));
			getPlayer(playerIndex).currentPressure += 1;
			getPlayer(playerIndex).currentConfidence += getPlayer(playerIndex).confidenceChangeOnLiveShot;
			if (liveRoundDamage > 1) {
				liveRoundDamage -= 1;
				if (!getPlayer(playerIndex).isEliminated()) {
					doTimer('morePressure', new FlxTimer().start(0.75, function(_) {
						shoot(playerIndex);
					}));
				} else {
					liveRoundDamage = GameplayManager.currentGamemode.cylinderInitialDamage;
					cylinderContent.shift();
					checkToReloadCylinder();
					if (GameplayManager.currentGamemode.skillsFixedPool.length + GameplayManager.currentGamemode.skillsRandomPool.length > 0) {
						giveSkillsToAllPlayers(GameplayManager.currentGamemode.skillsReplenishCountOnLive);
					}
				}
			} else {
				cylinderContent.shift();
				checkToReloadCylinder();
				if (GameplayManager.currentGamemode.skillsFixedPool.length + GameplayManager.currentGamemode.skillsRandomPool.length > 0) {
					giveSkillsToAllPlayers(GameplayManager.currentGamemode.skillsReplenishCountOnLive);
				}
			}

			liveRoundDamage += GameplayManager.currentGamemode.cylinderDamageChangeOnLive;

			var percent = getPlayer(playerIndex).calculatePressurePercentage();
			var fwoompSuffix:String = percent >= 0.5 ? 'Large' : 'Small';
			SuffState.playSound(Paths.soundRandom('belly/fwoomps/fwoomp' + fwoompSuffix, 1, Constants.FWOOMPS_SAMPLE_COUNT), 0.75, 0.5);
			if (Preferences.data.allowBellyCreaks) {
				SuffState.playSound(Paths.soundRandom('belly/creaks/creak', 1, Constants.CREAKS_SAMPLE_COUNT), percent, percent * 1.5 + 1);
			}

			screenShake(0.01, 0.1);
		} else {
			getPlayer(playerIndex).currentConfidence += getPlayer(playerIndex).confidenceChangeOnBlankShot;
			cylinderContent.shift();
			checkToReloadCylinder();
			if (GameplayManager.currentGamemode.skillsFixedPool.length + GameplayManager.currentGamemode.skillsRandomPool.length > 0) {
				giveSkillsToAllPlayers(GameplayManager.currentGamemode.skillsReplenishCountOnBlank);
			}
			liveRoundDamage += GameplayManager.currentGamemode.cylinderDamageChangeOnBlank;
		}
		trace(cylinderContent);

		getPlayer(playerIndex).currentConfidence = Std.int(FlxMath.bound(getPlayer(playerIndex).currentConfidence, 0, getPlayer(playerIndex).maxConfidence));

		doTimer('playerChangeTurn', new FlxTimer().start(getPlayer(playerIndex).getCurAnimLength(), function(_:FlxTimer) {
			if (getPlayer(playerIndex).currentPressure > getPlayer(playerIndex).maxPressure) {
				eliminatePlayer(playerIndex, 1);
			} else {
				FlxG.sound.music.resume();
				changeTurn(1);
			}
		}));
	}

	function checkToReloadCylinder() {
		if ((!cylinderContent.contains(true) && GameplayManager.currentGamemode.cylinderReloadOnNoLives) || cylinderContent.length <= 0) {
			reloadCylinder(GameplayManager.currentGamemode.cylinderLiveCount);
		}
	}

	function screenShake(intensity:Float = 0.02, duration:Float = 0.25) {
		if (Preferences.data.cameraEffectIntensity <= 0)
			return;
		FlxG.camera.shake(intensity * Preferences.data.cameraEffectIntensity, duration);
	}

	function screenFlash(color:FlxColor = 0xFFFFFFFF, duration:Float = 0.125) {
		var usedColor = color;
		if (Preferences.data.enablePhotosensitiveMode)
			usedColor.alpha = 32;
		FlxG.camera.flash(usedColor, duration, true);
	}

	function giveSkillsToAllPlayers(count:Int = 1) {
		var leArray = (GameplayManager.currentGamemode.skillsRandomPool.length > 0) ? GameplayManager.currentGamemode.skillsRandomPool : GameplayManager.currentGamemode.skillsFixedPool;
		var leCount = (GameplayManager.currentGamemode.skillsRandomPool.length > 0) ? count : leArray.length;
		for (char in characterGroup) {
			if (GameplayManager.currentGamemode.skillsFixedPool.length > 0)
				char.currentSkills = [];
			if (char.currentSkills.length >= 3)
				continue; // Maximum of three skills
			for (i in 0...leCount) {
				var skillName = '';
				if (GameplayManager.currentGamemode.skillsRandomPool.length > 0)
					skillName = GameplayManager.currentGamemode.skillsRandomPool[FlxG.random.int(0,
						GameplayManager.currentGamemode.skillsRandomPool.length - 1)];
				else if (GameplayManager.currentGamemode.skillsFixedPool.length > 0)
					skillName = leArray[i];
				char.currentSkills.push(new Skill(skillName, null, GameplayManager.currentGamemode.skillsCostMultiplier));
			}
		}
	}

	function eliminatePlayer(playerIndex:Int, turnChangeAfterwards:Int = 0) {
		getPlayer(playerIndex).currentPressure = getPlayer(playerIndex).maxPressure + 1;
		isEnding = evaluateEnding(); // Check if remaining players are eliminated
		playGunContactSound();
		pumpGun.visible = true;
		if (currentSessionAllowPopping && !getPlayer(playerIndex).disablePopping) { // Pop player instead
			getPlayer(playerIndex).playAnim('popped', false);
			members.insert(members.indexOf(tableTop) - 1, new Scraps(getPlayer(playerIndex)));
			SuffState.playSound(Paths.sound('belly/burst'));
			getPlayer(playerIndex).disableBellySounds = true;
			screenShake(0.03, 0.5);
			screenFlash();
			getPlayer(playerIndex).acceleration.y = 4800 * getPlayer(playerIndex).poppingGravityMultiplier;
			getPlayer(playerIndex).velocity.x += 320 * (playerIndex >= characterGroup.members.length / 2 ? 1 : -1) * getPlayer(playerIndex)
				.poppingVelocityMultiplier[0];
			getPlayer(playerIndex).velocity.y = -1600 * getPlayer(playerIndex).poppingVelocityMultiplier[1];
		} else {
			getPlayer(playerIndex).playAnim('idle');
		}

		if (!isEnding) {
			FlxG.sound.music.resume();
			doTween('aTweenButItsATimerLol', FlxTween.tween(camGame, {alpha: 1}, (currentSessionAllowPopping ? 2.5 : 1), {
				onUpdate: function(_:FlxTween) {
					focusCameraOnPlayer(playerIndex);
				},
				onComplete: function(_:FlxTween) {
					changeTurn(turnChangeAfterwards);
				}
			}));
		} else {
			doTween('camHUD', FlxTween.tween(camHUD, {alpha: 0}, 0.5));
			doTween('winningTimer', FlxTween.tween(camGame, {alpha: 1}, 1.5, {
				onUpdate: function(_:FlxTween) {
					focusCameraOnPlayer(playerIndex);
				},
				onComplete: function(_:FlxTween) {
					playEndCutscene();
				}
			}));
		}
	}

	function playEndCutscene() {
		focusCameraOnStage();
		cameraFocusButton.visible = false;
		doTimer('confettiTimer', new FlxTimer().start(0.5, function(_:FlxTimer) {
			getPlayer(winnerIndex).playAnim('preWin', false);
			SuffState.playSound(Paths.sound('confetti'));
			members.insert(members.indexOf(tableTop) - 1,
				new Confetti(getPlayer(winnerIndex).x - FlxG.width / 2.5, getPlayer(winnerIndex).y - getPlayer(winnerIndex).height, 30));
			members.insert(members.indexOf(tableTop) - 1,
				new Confetti(getPlayer(winnerIndex).x + FlxG.width / 2.5, getPlayer(winnerIndex).y - getPlayer(winnerIndex).height, 150));
			doTimer('winAnim', new FlxTimer().start(0.5 + getPlayer(winnerIndex).getCurAnimLength(), function(_:FlxTimer) {
				SuffState.playMusic('win', 1);
				getPlayer(winnerIndex).playAnim('win', false);
				doTimer('finishCutscene', new FlxTimer().start(Math.max(4.5, getPlayer(currentTurnIndex).getCurAnimLength()), function(_:FlxTimer) {
					finishEndCutscene();
				}));
			}));
		}));
	}

	function finishEndCutscene() {
		ambientSound.pause();
		SuffState.playMusic('null');
		SuffState.switchState(new MainMenuState(), BLOCKY);
	}

	function changeTurnNumber(change:Int = 0) {
		currentTurnIndex = (currentTurnIndex + change) % CharacterManager.selectedCharacterList.length;
	}

	function changeTurn(change:Int = 0, slient:Bool = false) {
		var PrevTurn:Int = currentTurnIndex;
		var flipX:Bool = PrevTurn >= Std.int(CharacterManager.selectedCharacterList.length / 2)
			&& PrevTurn != CharacterManager.selectedCharacterList.length - 1;
		changeTurnNumber(change);
		if (!(Preferences.data.ignoreEliminatedPlayers && getPlayer(PrevTurn).isEliminated())) {
			focusCameraOnPlayer(PrevTurn);
			getPlayer(PrevTurn).playAnim('pass', true, true, flipX);
		}
		if (!pumpGun.visible)
			playGunContactSound();
		if (change != 0) {
			pumpGun.visible = true;
			doTween('pumpGunPass', FlxTween.tween(pumpGun, {x: pumpGunDestinations[currentTurnIndex]}, 0.5, {
				startDelay: (!(Preferences.data.ignoreEliminatedPlayers && getPlayer(currentTurnIndex).isEliminated()) ? 0.5 : 0),
				ease: FlxEase.quadOut,
				onStart: function(_:FlxTween) {
					if (!slient)
						SuffState.playSound(Paths.sound('weaponSlide'));
					if (!(Preferences.data.ignoreEliminatedPlayers && getPlayer(currentTurnIndex).isEliminated()))
						focusCameraOnPlayer(currentTurnIndex);
					else
						changeTurn(change, true);
				},
				onComplete: function(_:FlxTween) {
					if (!getPlayer(currentTurnIndex).isEliminated()) {
						getPlayer(currentTurnIndex).playAnim('prepareShoot', false);
						playGunContactSound();
						pumpGun.visible = false;
						togglePlayerUI(CharacterManager.playerControlled[currentTurnIndex]);
						toggleLetterbox(!CharacterManager.playerControlled[currentTurnIndex]);
						if (getPlayer(currentTurnIndex).cpuControlled) {
							cpuAction();
						} else {
							toggleCameraFocusButton(true);
						}
					} else {
						doTimer('helplessPreAnim', new FlxTimer().start(0.5, function(_:FlxTimer) {
							getPlayer(currentTurnIndex).playAnim('helpless', false);
							doTimer('helplessAnim', new FlxTimer().start(getPlayer(currentTurnIndex).getCurAnimLength(), function(_:FlxTimer) {
								changeTurn(change);
							}));
						}));
					}
				}
			}));
		} else {
			getPlayer(currentTurnIndex).playAnim('prepareShoot', false);
			pumpGun.visible = false;
			togglePlayerUI(CharacterManager.playerControlled[currentTurnIndex]);
		}
		reloadPlayerUI(currentTurnIndex);
	}

	function cpuAction() {
		new FlxTimer().start(FlxG.random.float(1.0, 1.5), function(_) {
			deployGun(currentTurnIndex, function() return getPlayer(currentTurnIndex).calculatePressurePercentage());
		});
	}

	function focusCameraOnPlayer(playerIndex:Int) {
		var characterCameraOffset:Array<Int> = getPlayer(playerIndex).cameraOffset;
		if (getPlayer(playerIndex).isEliminated())
			characterCameraOffset = getPlayer(playerIndex).poppedCameraOffset;

		camFollow.x = getPlayer(playerIndex).x + characterCameraOffset[0];
		camFollow.y = getPlayer(playerIndex).y + characterCameraOffset[1];
		camFollowZoom = 1.2;
	}

	function focusCameraOnStage() {
		camFollow.x = FlxG.width / 2;
		camFollow.y = FlxG.height / 2;
		camFollowZoom = 0.8;
	}

	function doTween(tag:String, tween:FlxTween) {
		if (gameTweens.exists(tag)) {
			gameTweens.get(tag).cancel();
			gameTweens.get(tag).destroy();
			gameTweens.remove(tag);
		}
		gameTweens.set(tag, tween);
	}

	function doTimer(tag:String, timer:FlxTimer) {
		if (gameTimers.exists(tag)) {
			gameTimers.get(tag).cancel();
			gameTimers.get(tag).destroy();
			gameTimers.remove(tag);
		}
		gameTimers.set(tag, timer);
	}

	function toggleLetterbox(moveIn:Bool = true) {
		var reallyMoveIn:Bool = moveIn;
		if (!Preferences.data.enableLetterbox)
			reallyMoveIn = false;
		letterboxDisplayed = reallyMoveIn;
		if (reallyMoveIn) {
			doTween('letterboxTopTween', FlxTween.tween(letterboxTop, {y: 0}, 1, {
				ease: FlxEase.cubeOut,
				onUpdate: function(_:FlxTween) {
					pauseButton.y = letterboxTop.y + letterboxTop.height + 20;
				}
			}));
			doTween('letterboxBottomTween', FlxTween.tween(letterboxBottom, {y: FlxG.height - letterboxBottom.height}, 1, {
				ease: FlxEase.cubeOut,
				onUpdate: function(_) {
					cameraFocusButton.y = letterboxBottom.y - cameraFocusButton.height - 20;
				}
			}));
		} else {
			doTween('letterboxTopTween', FlxTween.tween(letterboxTop, {y: -letterboxTop.height}, 1, {
				ease: FlxEase.cubeOut,
				onUpdate: function(_:FlxTween) {
					pauseButton.y = letterboxTop.y + letterboxTop.height + 20;
				}
			}));
			doTween('letterboxBottomTween', FlxTween.tween(letterboxBottom, {y: FlxG.height}, 1, {
				ease: FlxEase.cubeOut,
				onUpdate: function(_) {
					cameraFocusButton.y = letterboxBottom.y - cameraFocusButton.height - 20;
				}
			}));
		}
	}

	function togglePlayerUI(moveIn:Bool = false) {
		shootButton.disabled = !moveIn;
		if (!moveIn) {
			for (skillCard in skillCardsGroup) {
				skillCard.disabled = false;
			}
		}
		if (moveIn) {
			doTween('shootButtonMoveTween', FlxTween.tween(shootButton, {x: 0}, 0.5, {ease: FlxEase.cubeOut}));
			doTween('skillCardsGroupMoveTween', FlxTween.tween(skillCardsGroup, {x: skillCardsGroupPaddingX}, 0.5, {ease: FlxEase.cubeOut}));
			doTween('uiBGGroupMoveTween', FlxTween.tween(uiBGGroup, {x: 0}, 0.25, {ease: FlxEase.cubeOut}));
		} else {
			doTween('shootButtonMoveTween', FlxTween.tween(shootButton, {x: -shootButton.width}, 0.5, {ease: FlxEase.cubeOut}));
			doTween('skillCardsGroupMoveTween', FlxTween.tween(skillCardsGroup, {x: -skillCardsGroup.width}, 0.5, {ease: FlxEase.cubeOut}));
			doTween('uiBGGroupMoveTween', FlxTween.tween(uiBGGroup, {x: -uiBGGroup.width}, 0.25, {ease: FlxEase.cubeOut}));
		}
	}

	function evaluateEnding() {
		var aliveCharCount:Int = 0;
		var aliveCharIndex:Int = 0;
		for (char in characterGroup) {
			if (!char.isEliminated()) {
				aliveCharCount++;
				aliveCharIndex = characterGroup.members.indexOf(char);
			}
		}
		if (aliveCharCount <= 1) {
			winnerIndex = aliveCharIndex;
			togglePauseFunctionality(false);
		}
		return (aliveCharCount <= 1);
	}

	public function pauseGame() {
		if (!canPause)
			return;
		persistentUpdate = false;
		isPaused = true;
		toggleMonochrome(true);
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if (!tmr.finished)
			tmr.active = false);
		FlxTween.globalManager.forEach(function(twn:FlxTween) if (!twn.finished)
			twn.active = false);

		openSubState(new PauseSubState());
	}

	public function resumeGame() {
		persistentUpdate = true;
		isPaused = false;
		toggleMonochrome(false);
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if (!tmr.finished)
			tmr.active = true);
		FlxTween.globalManager.forEach(function(twn:FlxTween) if (!twn.finished)
			twn.active = true);

		super.closeSubState();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		pressureBar.updateBar();
		confidenceBar.updateBar();

		if (FlxG.keys.justPressed.ESCAPE) {
			pauseGame();
		}

		if (!isPaused) {
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, camFollowZoom, FlxMath.bound(elapsed * 5, 0, 1));

			if (FlxG.keys.justPressed.ENTER && CharacterManager.playerControlled[currentTurnIndex] && !shootButton.disabled) {
				deployGun(currentTurnIndex, function() return getPlayer(currentTurnIndex).calculatePressurePercentage());
			}

			if (Preferences.data.enableDebugMode) {
				if (FlxG.keys.justPressed.Z) {
					getPlayer(currentTurnIndex).currentConfidence += 1;
					updateSkillAvailability(currentTurnIndex);
				}
				if (FlxG.keys.justPressed.X) {
					shoot(currentTurnIndex);
				}
			}

			for (player in characterGroup) {
				if (player.velocity.x != 0 && player.velocity.y != 0) {
					if (player.x + player.velocity.x * elapsed < floorBoundXLeft
						|| player.x + player.velocity.x * elapsed > floorBoundXRight) {
						player.velocity.x *= -1;
						player.x = player.x + player.velocity.x * elapsed;
					}
					if (player.y + player.velocity.y * elapsed > floorY) {
						player.velocity.y *= -0.5;
						player.y = floorY + player.velocity.y * elapsed;
						player.velocity.x *= 0.5;
						player.playAnim('idleNull', false);
						if (Math.abs(player.velocity.y) < 100) {
							player.velocity.x = 0;
							player.velocity.y = 0;
							player.acceleration.y = 0;
						}
					}
				}
			}
		}
	}
}
