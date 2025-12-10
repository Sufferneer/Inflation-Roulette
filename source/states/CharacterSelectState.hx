package states;

import backend.CharacterManager;
import backend.Addons;
import backend.types.CharacterData;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;
import flixel.util.FlxGradient;
import states.MainMenuState;
import states.PlayState;
import tjson.TJSON as Json;
import ui.objects.CharacterSelectBanner;
import ui.objects.CharacterSelectCard;
import ui.objects.CharacterSelectText;
import ui.objects.ReadySign;
import ui.objects.SuffBooleanOption;
import ui.objects.SuffSliderOption;

class CharacterSelectState extends SuffState {
	var curPlayer:Int = 0;
	var curPage:Int = 0;
	var lastPage:Int = 0;
	var maxNumberInRow:Int = 0;
	var playerPages:Array<Int> = [];

	static final margin:Int = 50;
	public static final cardOccupicationHeight:Float = 0.35;
	var sectionWidth:Int = Math.ceil(FlxG.width / CharacterManager.selectedCharacterList.length);
	var optionY:Array<Float> = [16, 16, 16, 16];

	var pageXOffset:Float = 0;
	var initialCardY:Float = 0;
	var initialDescriptionY:Float = 0;
	final shadowCount:Int = 6;
	var inPlayerSettings:Bool = false;
	var isExiting:Bool = false;

	var grid:FlxBackdrop;
	var bg2:FlxSprite;
	var playerOutline:FlxSprite;
	var playerOutlineShadows:FlxTypedContainer<FlxSprite> = new FlxTypedContainer<FlxSprite>();
	var description:CharacterSelectText;
	var bannerGroup:FlxTypedContainer<CharacterSelectBanner> = new FlxTypedContainer<CharacterSelectBanner>();
	var playerSettingGroup:FlxSpriteGroup = new FlxSpriteGroup();
	var marginLeft:FlxSpriteGroup = new FlxSpriteGroup();
	var marginRight:FlxSpriteGroup = new FlxSpriteGroup();
	var leftButton:SuffButton;
	var rightButton:SuffButton;
	var readySign:ReadySign;
	var selectYourDipshit:FlxText;
	var slashBGDim:FlxSprite;
	var slashBG:FlxSprite;
	var gameOn:FlxText;

	var cardGroup:FlxTypedSpriteGroup<CharacterSelectCard> = new FlxTypedSpriteGroup<CharacterSelectCard>();

	override function create() {
		super.create();

		CharacterManager.pushGlobalCharacterList();
		var characterList = CharacterManager.globalCharacterList.copy();
		characterList.push('random');

		/*
		for (i in 0...20) { // For debug purposes only
			characterList.push('goober');
			characterList.push('random');
		}
		*/

		add(bannerGroup);
		CharacterManager.playerControlled = [];
		for (i in 0...CharacterManager.selectedCharacterList.length) {
			var banner = new CharacterSelectBanner(i);
			banner.onClick = function() {
				if (!leftButton.disabled)
					setPlayer(i);
			}
			bannerGroup.add(banner);

			CharacterManager.selectedCharacterList[i] = '';
			CharacterManager.playerControlled.push(false);

			playerPages.push(curPage);
		}
		CharacterSelectBanner.precacheBanners();
		CharacterManager.playerControlled[0] = true;

		grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(160, 160);
		add(grid);

		selectYourDipshit = new FlxText(0, 0, 0, 'CHOOSE YOUR VESSELS');
		selectYourDipshit.setFormat(Paths.font('default'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, 0x80000000);
		selectYourDipshit.borderSize = 4;
		selectYourDipshit.screenCenter();
		selectYourDipshit.y = FlxG.height * (1 - cardOccupicationHeight) - selectYourDipshit.height;
		add(selectYourDipshit);

		add(playerOutlineShadows);

		playerOutline = new FlxSprite().loadGraphic(Utils.makeBorder(Std.int(sectionWidth), Std.int(FlxG.height * (1 - cardOccupicationHeight)), 10,
			0xFFFFFFFF));
		add(playerOutline);

		for (i in 0...shadowCount) {
			var shadow = new FlxSprite(playerOutline.x, playerOutline.y).loadGraphic(playerOutline.graphic);
			shadow.alpha = (shadowCount - i - 1) / shadowCount;
			playerOutlineShadows.add(shadow);
		}

		bg2 = new FlxSprite(0, FlxG.height * (1 - cardOccupicationHeight)).makeGraphic(FlxG.width, Math.ceil(FlxG.height), 0xFF000000);
		add(bg2);

		add(cardGroup);

		var leScale = Math.min(1, FlxG.height * cardOccupicationHeight / Constants.CHARACTER_CARD_DIMENSIONS[0]);
		var calculatedWidth = Constants.CHARACTER_CARD_DIMENSIONS[0] * leScale;
		maxNumberInRow = findMaximumCardsPerRow(leScale);

		var fadeWidth:Int = 16;

		var innerMarginLeft = new FlxSprite().makeGraphic(Std.int((FlxG.width - maxNumberInRow * calculatedWidth) / 2 - fadeWidth),
			Std.int(FlxG.height * cardOccupicationHeight), 0xFF000000);

		var innerMarginRight = new FlxSprite(fadeWidth,
			0).makeGraphic(Std.int((FlxG.width - maxNumberInRow * calculatedWidth) / 2 - fadeWidth), Std.int(FlxG.height * cardOccupicationHeight), 0xFF000000);

		description = new CharacterSelectText(0, 0, null);
		description.y = FlxG.height - description.height;
		initialDescriptionY = description.y;

		add(description);
		add(marginLeft);
		add(marginRight);

		marginLeft.add(innerMarginLeft);
		marginRight.add(innerMarginRight);

		var color1:FlxColor = 0xFF000000;
		var color2:FlxColor = 0x0;

		var fadeLeft = new FlxSprite(marginLeft.width,
			0).loadGraphic(FlxGradient.createGradientBitmapData(fadeWidth, Std.int(marginLeft.height), [color1, color2], 1, 0));
		marginLeft.add(fadeLeft);

		var fadeRight = new FlxSprite().loadGraphic(FlxGradient.createGradientBitmapData(fadeWidth, Std.int(marginRight.height), [color1, color2], 1, 180));
		marginRight.add(fadeRight);

		marginLeft.y = marginRight.y = FlxG.height * (1 - cardOccupicationHeight);
		marginRight.x = FlxG.width - marginRight.width;

		add(playerSettingGroup);
		for (i in 0...CharacterManager.selectedCharacterList.length) {
			addBooleanOption(i, 'Player', function(val:Bool) {
				CharacterManager.playerControlled[i] = val;
			}, CharacterManager.playerControlled[i]);

			/*
			addSliderOption(i, 'Skill Level', function(val:Float) {
				CharacterManager.cpuLevel[i] = Std.int(val);
			}, 1, 3, 1, function(val:Float) {
				return Std.int(val) + '';
			}, CharacterManager.cpuLevel[i]);
			*/
		}
		playerSettingGroup.y = FlxG.height;

		var calculatedHeight = Constants.CHARACTER_CARD_DIMENSIONS[1] * leScale;
		lastPage = Std.int((characterList.length * calculatedWidth) / (FlxG.width - marginLeft.width - marginRight.width));
		initialCardY = FlxG.height * (1 - cardOccupicationHeight) + (FlxG.height * cardOccupicationHeight - description.height - calculatedHeight) / 2;
		for (i in 0...characterList.length) {
			var leChar:CharacterData = cast Json.parse(Paths.getTextFromFile('data/characters/' + characterList[i] + '.json'));
			if (characterList[i] == 'random') {
				leChar = {
					id: 'random',
					name: '???',
					description: 'Not sure who to choose? Let the game decide.',
					skills: [],
					modifiers: [],
					maxPressure: 0,
					maxConfidence: 0
				};
			}
			leChar.id = characterList[i];

			var card = new CharacterSelectCard(0, 0, leChar);
			card.setScale(leScale, leScale);
			card.x = (FlxG.width - maxNumberInRow * calculatedWidth) / 2 + calculatedWidth * i;
			if (lastPage == 0) {
				card.x = (FlxG.width - characterList.length * calculatedWidth) / 2 + calculatedWidth * i;
			}
			card.y = initialCardY;
			card.onIdle = function() {
				card.playAnim('selected', true, true);
			}
			card.onHover = function() {
				card.playAnim('selected', true);
				changeDescription(leChar);
			};
			card.onClick = function() {
				card.designatedPlayer = curPlayer;
				confirmCharacter(card.characterData.id, i);
				card.holdAnim = true;
			};
			cardGroup.add(card);
		}

		leftButton = new SuffButton(0, 0, null, Paths.image('gui/icons/buttons/left'), null, 100, 100);
		leftButton.x = marginLeft.x + (marginLeft.width - leftButton.width) / 2;
		leftButton.y = marginLeft.y + (marginLeft.height - leftButton.height) / 2;
		leftButton.onClick = function() {
			changePage(-1);
		};
		leftButton.visible = lastPage > 0;
		add(leftButton);

		rightButton = new SuffButton(0, 0, null, Paths.image('gui/icons/buttons/right'), null, 100, 100);
		rightButton.x = marginRight.x + (marginRight.width - rightButton.width) / 2;
		rightButton.y = marginRight.y + (marginRight.height - rightButton.height) / 2;
		rightButton.onClick = function() {
			changePage(1);
		};
		rightButton.visible = lastPage > 0;
		add(rightButton);

		readySign = new ReadySign();
		readySign.onClick = function () {
			proceedToPlayState();
		};
		add(readySign);

		slashBGDim = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		slashBGDim.alpha = 0;
		add(slashBGDim);

		slashBG = new FlxSprite();
		slashBG.frames = Paths.sparrowAtlas('gui/menus/characterSelect/slashBG');
		slashBG.animation.addByPrefix('idle', 'idle', 24, false);
		slashBG.screenCenter();
		slashBG.scale.set(1, 0.75);
		slashBG.alpha = 0;
		add(slashBG);

		gameOn = new FlxText(0, 0, 0, 'GAME ON!');
		gameOn.setFormat(Paths.font('default'), 256, FlxColor.WHITE);
		gameOn.alpha = 0;
		gameOn.screenCenter();
		gameOn.scale.set(0, 0);
		add(gameOn);

		changeDescription(null);
		changePage();

		SuffState.playMusic('characterSelect');
	}

	function addBooleanOption(i:Int, name:String, callback:Bool->Void, defaultValue:Bool) {
		var option:SuffBooleanOption = new SuffBooleanOption(0, optionY[i], callback, defaultValue);

		var text:FlxText = new FlxText(0, optionY[i], 0, name);
		text.setFormat(Paths.font('default'), 32, FlxColor.WHITE, LEFT);

		text.x = sectionWidth * i + (sectionWidth - (text.width + 8 + option.width)) / 2;
		text.y = optionY[i] + (option.height - text.height) / 2;
		option.x = sectionWidth * i + (sectionWidth - (text.width + 8 + option.width)) / 2 + (text.width + 8);

		optionY[i] += (Math.max(option.height, text.height) + 16);

		playerSettingGroup.add(option);
		playerSettingGroup.add(text);
	}

	function addSliderOption(i:Int, name:String, callback:Float->Void, rangeMin:Float, rangeMax:Float, step:Float, displayFunction:Float->String, defaultValue:Float) {
		var option:SuffSliderOption = new SuffSliderOption(sectionWidth * i + (sectionWidth - 256) / 2, optionY[i], callback, rangeMin, rangeMax, step, displayFunction, defaultValue);

		var text:FlxText = new FlxText(0, optionY[i], 0, name);
		text.setFormat(Paths.font('default'), 32, FlxColor.WHITE, LEFT);

		text.x = sectionWidth * i + (sectionWidth - (text.width)) / 2;
		option.x = sectionWidth * i + (sectionWidth - (option.width)) / 2;
		option.y += text.height;

		optionY[i] += (Math.max(option.height, text.height) + 16);

		playerSettingGroup.add(option);
		playerSettingGroup.add(text);
	}

	function changeDescription(char:CharacterData) {
		if (cardTweens.get('NOSKIP_description') != null)
			cardTweens.get('NOSKIP_description').cancel();
		
		description.reloadText(char);
		description.x = marginRight.x + marginRight.width / 2;
		description.y = initialDescriptionY;
		description.alpha = 1;

		allowMoveDescription = description.width > (FlxG.width - marginLeft.width - marginRight.width);
		resetDescriptionX(allowMoveDescription);

		moveDescription(1);
	}

	function resetDescriptionX(leftAlignment:Bool = true) {
		if (leftAlignment) {
			description.x = marginLeft.x + marginLeft.width;
		} else {
			description.screenCenter(X);
		} 
	}

	function moveDescription(direction:Int = 0, delay:Float = 1.0) {
		descriptionVel = 0;
		if (descriptionTimer != null)
			descriptionTimer.cancel();
		descriptionTimer = new FlxTimer().start(delay, function(_) {
			if (direction == 1) {
				descriptionVel = 32 * 4 * -1;
			} else {
				cardTweens.set('NOSKIP_description', FlxTween.tween(description, {y: FlxG.height + 16}, 0.5, {
					ease: FlxEase.quadIn,
					onComplete: function(_) {
						resetDescriptionX(true);
						cardTweens.set('NOSKIP_description', FlxTween.tween(description, {y: initialDescriptionY}, 0.5, {
							startDelay: 0.25,
							ease: FlxEase.quadOut,
							onComplete: function(_) {
								moveDescription(1);
							}
						}));
					}
				}));
			}
		});
	}

	var descriptionTimer:FlxTimer;
	var allowMoveDescription:Bool = false;
	var descriptionVel:Float = 0;

	var allowSelectionTimer:FlxTimer;

	function changePage(change:Int = 0) {
		curPage += change;
		if (curPage < 0) {
			curPage = lastPage;
		} else if (curPage > lastPage) {
			curPage = 0;
		}
		for (card in cardGroup.members) {
			card.disabled = true;
		}
		if (allowSelectionTimer != null)
			allowSelectionTimer.cancel();
		allowSelectionTimer = new FlxTimer().start(FlxG.elapsed * 10, function(_) {
			for (card in cardGroup.members) {
				var leIndex:Int = cardGroup.members.indexOf(card);
				card.disabled = !(leIndex >= curPage * maxNumberInRow && leIndex < (curPage + 1) * maxNumberInRow);
			}
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!isExiting) {
			if (FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT) {
				changePage(-1);
			} else if (FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT) {
				changePage(1);
			}
			if (FlxG.keys.justPressed.ESCAPE) {
				if (inPlayerSettings)
					changePlayer();
				else
					backToMainMenu();
			}
		}

		cardGroup.x = FlxMath.lerp(cardGroup.x, -curPage * (FlxG.width - marginRight.width - marginLeft.width), elapsed * 10);

		if (allowMoveDescription) {
			var predictedX = description.x + descriptionVel * elapsed;
			if (predictedX > marginLeft.x + marginLeft.width) {
				moveDescription(1);
			} else if (predictedX < marginRight.x - description.width) {
				moveDescription(-1);
			} else {
				description.x += descriptionVel * elapsed;
			}
		}
	}

	function backToMainMenu() {
		SuffState.playMusic('mainMenu');
		SuffState.switchState(new MainMenuState());
	}

	var cardTweens:Map<String, FlxTween> = new Map<String, FlxTween>();

	function cancelAllTweens() {
		for (tag => twn in cardTweens) {
			if (cardTweens.get(tag) != null && !tag.startsWith('NOSKIP_')) {
				cardTweens.get(tag).cancel();
				cardTweens.remove(tag);
			}
		}
	}

	function confirmCharacter(character:String = 'random', index:Int = 0) {
		CharacterManager.selectedCharacterList[curPlayer] = character;
		cancelAllTweens();
		leftButton.disabled = true;
		rightButton.disabled = true;
		leftButton.alpha = 0;
		rightButton.alpha = 0;
		description.alpha = 0;
		grid.velocity.set(640, 640);
		playerPages[curPlayer] = curPage;
		bannerGroup.members[curPlayer].setCharacter(character);
		for (card in cardGroup) {
			card.disabled = true;
			var leIndex:Int = cardGroup.members.indexOf(card);
			if (leIndex != index) {
				cardTweens.set(leIndex + '', FlxTween.tween(card, {y: FlxG.height}, 0.5, {
					ease: FlxEase.quintOut
				}));
			} else {
				FlxFlicker.flicker(card, 1, FlxG.elapsed * (Preferences.data.photosensitivity ? 8 : 2), true, true, function(_) {
					var index:Int = curPlayer;
					for (i in 0...CharacterManager.selectedCharacterList.length) {
						index = (index + 1) % CharacterManager.selectedCharacterList.length;
						if (CharacterManager.selectedCharacterList[index] == '') {
							break;
						}
					}
					if (curPlayer != index) {
						setPlayer(index);
					} else {
						moveOnToPlayerSettings();
					}
				});
			}
		}
	}

	function moveOnToPlayerSettings() {
		inPlayerSettings = true;
		playerOutline.visible = false;
		selectYourDipshit.visible = false;
		for (outline in playerOutlineShadows) {
			outline.visible = false;
		}
		for (banner in bannerGroup) {
			banner.disabled = true;
		}
		for (card in cardGroup) {
			var leIndex:Int = cardGroup.members.indexOf(card);
			card.visible = false;
		}
		cardTweens.set('gridVel', FlxTween.tween(grid.velocity, {x: 40, y: 40}, 1, {ease: FlxEase.quadInOut}));
		cardTweens.set('bg2', FlxTween.tween(bg2, {y: FlxG.height * 0.5}, 0.5, {ease: FlxEase.quintOut}));
		cardTweens.set('playerSettingGroup', FlxTween.tween(playerSettingGroup, {y: FlxG.height * 0.5}, 0.75, {ease: FlxEase.quintOut}));

		readySign.moveSign(false);
	}

	function setPlayer(val:Int) {
		changePlayer(val - curPlayer);
	}

	function changePlayer(change:Int = 0) {
		if (inPlayerSettings) {
			readySign.moveSign(true);
			inPlayerSettings = false;
		}
		playerOutline.visible = true;
		for (outline in playerOutlineShadows) {
			outline.visible = true;
		}
		for (banner in bannerGroup) {
			banner.disabled = false;
		}
		selectYourDipshit.visible = true;

		curPlayer += change;
		curPage = playerPages[curPlayer];
		cardGroup.x = -curPage * (FlxG.width - marginRight.width - marginLeft.width);
		cancelAllTweens();
		cardTweens.set('leftButton', FlxTween.tween(leftButton, {alpha: 1}, 0.25));
		cardTweens.set('rightButton', FlxTween.tween(rightButton, {alpha: 1}, 0.25));
		cardTweens.set('NOSKIP_description', FlxTween.tween(description, {alpha: 1}, 0.5));
		cardTweens.set('NOSKIP_playerOutline', FlxTween.tween(playerOutline, {x: bannerGroup.members[curPlayer].x}, 0.5, {ease: FlxEase.quintOut}));
		for (item in playerOutlineShadows) {
			var leIndex:Int = playerOutlineShadows.members.indexOf(item);
			cardTweens.set('NOSKIP_playerOutline' + leIndex,
				FlxTween.tween(item, {x: bannerGroup.members[curPlayer].x}, 0.5, {startDelay: leIndex * 0.05, ease: FlxEase.quintOut}));
		}
		cardTweens.set('gridVel', FlxTween.tween(grid.velocity, {x: 160, y: 160}, 0.5, {ease: FlxEase.quadInOut}));
		cardTweens.set('bg2', FlxTween.tween(bg2, {y: FlxG.height * (1 - cardOccupicationHeight)}, 0.5, {ease: FlxEase.quintOut}));
		cardTweens.set('playerSettingGroup', FlxTween.tween(playerSettingGroup, {y: FlxG.height}, 0.75, {ease: FlxEase.quintOut}));
		for (card in cardGroup) {
			var leIndex:Int = cardGroup.members.indexOf(card);
			if (card.holdAnim) {
				card.onIdle();
				card.holdAnim = false;
			}
			card.visible = true;
			card.disabled = false;
			cardTweens.set(leIndex + '', FlxTween.tween(card, {y: initialCardY}, 0.5, {
				ease: FlxEase.quintOut
			}));
		}
		changePage();
		leftButton.disabled = false;
		rightButton.disabled = false;
	}

	function findMaximumCardsPerRow(leScale:Float = 1) {
		return Std.int((FlxG.width - margin * 2) / (Constants.CHARACTER_CARD_DIMENSIONS[0] * leScale));
	}

	function proceedToPlayState() {
		SuffState.playMusic('characterSelectEnd', 1, true, true, false);
		playerSettingGroup.y = FlxG.height;
		isExiting = true;
		readySign.moveSign(true);
		cardTweens.set('slashBGDim', FlxTween.tween(slashBGDim, {alpha: 0.5}, 0.5));
		slashBG.alpha = 0.25;
		slashBG.animation.play('idle');
		cardTweens.set('gameOn', FlxTween.tween(gameOn, {alpha: 1, 'scale.x': 1, 'scale.y': 1}, 1, {
			ease: FlxEase.bounceOut,
			onComplete: function(_) {
				new FlxTimer().start(1, function(_) {
					CharacterManager.parseRandomCharacters();
					PlayState.hasSeenCutscene = false;
					SuffState.switchState(new PlayState());
				});
			}
		}));
	}
}
