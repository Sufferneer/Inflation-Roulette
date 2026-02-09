package states;

import openfl.display.BlendMode;
import backend.Addons;
import backend.types.AddonData;
import flixel.util.FlxGradient;
import states.MainMenuState;
import ui.objects.AddonMenuBG;
import ui.objects.AddonMenuBG.AddonMenuBGTile;
import ui.objects.AddonMenuItem;
import ui.objects.SuffIconButton;
import tjson.TJSON as Json;

class AddonsMenuState extends SuffState {
	var bg:FlxSprite;
	var icons:FlxTypedSpriteGroup<AddonMenuBG> = new FlxTypedSpriteGroup<AddonMenuBG>();
	var modBG:FlxSprite;
	var modItems:FlxTypedSpriteGroup<AddonMenuItem> = new FlxTypedSpriteGroup<AddonMenuItem>();
	var modItemsScrollLimit:Float = 0;
	var modItemsScrollBar:FlxSprite;

	var modBannerBG:FlxSprite;
	var modBanner:FlxSprite;
	var modBannerVignette:FlxSprite;

	var modMetadataItems:FlxSpriteGroup = new FlxSpriteGroup();
	var modMetadataItemsScrollLimit:Float = 0;
	var modTitleText:FlxText;
	var modDescriptionText:FlxText;
	var modAuthorTitleText:FlxText;
	var modAuthorsText:FlxText;
	var modMetadataItemsScrollBar:FlxSprite;

	public static final padding:Int = 20;
	public static final itemCount:Int = 5;

	final scrollBarWidth:Int = 30;

	var curCrochet:Float = 0;
	var prevBeat:Int = 0;
	var curBeat:Int = 0;

	override function create() {
		super.create();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		bg.alpha = 0.5;
		add(bg);

		add(icons);

		var size = AddonMenuBGTile.bgSize * 2;
		for (h in 0...Math.ceil(FlxG.height / size) + 1) {
			for (w in 0...Math.ceil(FlxG.width / size) + 1) {
				var tile = new AddonMenuBG(w * size, h * size);
				for (item in tile.members) {
					item.alpha = 0.25;
					item.blend = BlendMode.ADD;
				}
				icons.add(tile);
			}
		}
		icons.velocity.set(-40, -40);

		var leAddons = Addons.getGlobalAddons();

		modBG = new FlxSprite(padding, 0).makeGraphic(Std.int(FlxG.width / 2 - padding - scrollBarWidth), Std.int(FlxG.height), 0xFF000000);
		modBG.alpha = 0.5;
		add(modBG);

		AddonMenuItem.defaultWidth = Std.int(modBG.width);
		AddonMenuItem.defaultHeight = Std.int(modBG.height / AddonsMenuState.itemCount);

		add(modItems);
		for (i in 0...leAddons.length) {
			var folder:String = leAddons[i];
			var leModData:AddonData = cast Addons.getAddonData(folder);

			var item:AddonMenuItem = new AddonMenuItem(modBG.x, modBG.y + AddonMenuItem.defaultHeight * i, folder, leModData);
			item.onClick = function() {
				changeDisplayedMetadata(folder, leModData);
			}
			modItems.add(item);
		}

		if (modItems.height > FlxG.height) {
			modItemsScrollLimit = modItems.height - FlxG.height;
		}

		modItemsScrollBar = new FlxSprite(modBG.x + modBG.width,
			modBG.y).makeGraphic(Std.int(scrollBarWidth), Std.int(FlxG.height * (FlxG.height / (Math.abs(modItemsScrollLimit) + FlxG.height))), 0xFFFFFFFF);
		modItemsScrollBar.alpha = 0.5;
		modItemsScrollBar.visible = (modItems.height > FlxG.height);
		updateModItemsScrollBar();
		add(modItemsScrollBar);

		modBanner = new FlxSprite();

		modBannerVignette = new FlxSprite().loadGraphic(Paths.image('gui/menus/addons/bannerVignette'));
		changeBanner('');

		modBannerBG = new FlxSprite();
		modBannerBG.makeGraphic(Std.int(modBanner.width), FlxG.height, 0xFF000000);
		modBannerBG.alpha = 0.5;
		modBannerBG.x = modBanner.x;
		modBannerBG.y = modBanner.y;
		add(modBannerBG);

		add(modMetadataItems);

		add(modBanner);
		add(modBannerVignette);

		modTitleText = new FlxText(0, 0, modBannerBG.width - 16 * 2, 'NULL');
		modTitleText.setFormat(Paths.font('default'), 64);
		modMetadataItems.add(modTitleText);

		modDescriptionText = new FlxText(0, 0, modBannerBG.width - 16 * 2, 'NULL');
		modDescriptionText.setFormat(Paths.font('default'), 32);
		modDescriptionText.alpha = 0.75;
		modMetadataItems.add(modDescriptionText);

		modAuthorTitleText = new FlxText(0, 0, modBannerBG.width - 16 * 2, 'Authors:\n');
		modAuthorTitleText.setFormat(Paths.font('default'), 16);
		modAuthorTitleText.alpha = 0.75;
		modMetadataItems.add(modAuthorTitleText);

		modAuthorsText = new FlxText(0, 0, modBannerBG.width - 16 * 2, 'NULL - NULL');
		modAuthorsText.setFormat(Paths.font('default'), 32);
		modAuthorsText.alpha = 0.75;
		modMetadataItems.add(modAuthorsText);

		modMetadataItemsScrollBar = new FlxSprite(modBannerBG.x - scrollBarWidth, modBannerBG.y);
		updateModMetadataItemsScrollBar();
		add(modMetadataItemsScrollBar);

		if (leAddons.length > 0) {
			changeDisplayedMetadata(leAddons[0], modItems.members[0].addon);
		} else {
			changeDisplayedMetadata('', null);
		}

		var exitButton = new SuffIconButton(20, 20, 'buttons/exit', null, 2);
		exitButton.x = FlxG.width - exitButton.width - 20;
		exitButton.onClick = function() {
			backToMainMenu();
		};
		add(exitButton);

		SuffState.playMusic('options');
		curCrochet = 60 / SuffState.currentMusicBPM * 1000;
	}

	function updateModItemsScrollBar() {
		modItemsScrollBar.y = modItemsScrollLerped / modItemsScrollLimit * (FlxG.height - modItemsScrollBar.height);
	}

	function updateModMetadataItemsScrollBar() {
		var percent:Float = (modMetadataItemsScrollLimit > 0) ? modMetadataItemsScrollLerped / modMetadataItemsScrollLimit : 0;
		modMetadataItemsScrollBar.y = modBanner.y + modBanner.height + percent * (FlxG.height - modMetadataItemsScrollBar.height - modBanner.height);
	}

	function changeDisplayedMetadata(folder:String, addon:AddonData = null) {
		changeBanner(folder);

		if (addon == null)
			return;
		modTitleText.text = addon.name;
		modTitleText.updateHitbox();
		modDescriptionText.text = addon.description + '\n';
		modDescriptionText.updateHitbox();
		var authorStr:String = '';
		var authors:Array<Array<String>> = addon.authors;
		for (i in 0...authors.length) {
			var name:String = authors[i][0];
			var role:String = authors[i][1];
			if (authorStr.length > 0)
				authorStr += '\n';
			authorStr += '$name - $role';
		}
		modAuthorsText.text = authorStr;
		modAuthorsText.updateHitbox();

		modDescriptionText.y = modTitleText.y + modTitleText.height;
		modAuthorTitleText.y = modDescriptionText.y + modDescriptionText.height;
		modAuthorsText.y = modAuthorTitleText.y + modAuthorTitleText.height;
		modTitleText.x = modDescriptionText.x = modAuthorTitleText.x = modAuthorsText.x = modBannerBG.x + 16;

		modMetadataItems.y = modBanner.y + modBanner.height;
		if (modMetadataItems.height > (FlxG.height - modMetadataItems.y)) {
			modMetadataItemsScrollLimit = modMetadataItems.height - (FlxG.height - modMetadataItems.y);
		} else {
			modMetadataItemsScrollLimit = 0;
		}

		if (modMetadataItemsScrollBar != null) {
			modMetadataItemsScrollBar.makeGraphic(Std.int(scrollBarWidth),
				Std.int((FlxG.height - modBanner.height) * (FlxG.height / (modMetadataItemsScrollLimit + FlxG.height))), 0xFFFFFFFF);
			modMetadataItemsScrollBar.alpha = 0.5;
			modMetadataItemsScrollBar.visible = (modMetadataItemsScrollLimit > 0);
		}

		FlxTween.cancelTweensOf(bg, ['color']);
		FlxTween.color(bg, 1, bg.color, FlxColor.fromString(addon.color));
	}

	function changeBanner(folder:String) {
		var path:String = Paths.addons('$folder/metadata/banner.png');
		if (!FileSystem.exists(path)) {
			path = Paths.getImagePath('gui/menus/addons/defaultBanner');
		}
		var leWidth:Float = Std.int(FlxG.width / 2 - padding - scrollBarWidth);
		modBanner.loadGraphic(path);
		modBanner.setGraphicSize(Std.int(leWidth), Std.int(leWidth / 16 * 9));
		modBanner.updateHitbox();

		modBannerVignette.setGraphicSize(Std.int(modBanner.width), Std.int(modBanner.height));
		modBannerVignette.updateHitbox();

		modBannerVignette.x = modBanner.x = FlxG.width - modBanner.width - padding;
		modBannerVignette.y = modBanner.y;
	}

	var modItemsScroll:Float = 0;
	var modItemsScrollLerped:Float = 0;

	var modMetadataItemsScroll:Float = 0;
	var modMetadataItemsScrollLerped:Float = 0;

	static final scrollLerpFactor:Float = 10;

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (icons.x + icons.velocity.x * elapsed < AddonMenuBGTile.bgSize * -2) {
			icons.x = 0;
		}
		if (icons.y + icons.velocity.y * elapsed < AddonMenuBGTile.bgSize * -2) {
			icons.y = 0;
		}

		if (FlxG.mouse.wheel != 0) {
			if (FlxG.mouse.overlaps(modBG)) {
				modItemsScroll += FlxG.mouse.wheel * 64;
				boundModItemsY();
			} else if (FlxG.mouse.overlaps(modBannerBG)) {
				modMetadataItemsScroll += FlxG.mouse.wheel * 32;
				boundModMetadataItemsY();
			}
		}

		if (FlxG.keys.justPressed.ESCAPE) {
			backToMainMenu();
		}
		if (FlxG.mouse.pressed) {
			if (modMetadataItemsScrollBar.visible && FlxG.mouse.x > FlxG.width / 2) {
				modMetadataItemsScroll = modMetadataItemsScroll + (FlxG.mouse.deltaScreenY) * (FlxG.height / modMetadataItemsScrollBar.height);
				boundModMetadataItemsY();
			} else if (modItemsScrollBar.visible && FlxG.mouse.x < FlxG.width / 2) {
				modItemsScroll = modItemsScroll + (FlxG.mouse.deltaScreenY) * (FlxG.height / modItemsScrollBar.height);
				boundModItemsY();
				updateModItemsScrollBar();
			}
		}

		modItemsScrollLerped = FlxMath.lerp(modItemsScrollLerped, modItemsScroll, elapsed * scrollLerpFactor);
		modItems.y = -modItemsScrollLerped;

		modMetadataItemsScrollLerped = FlxMath.lerp(modMetadataItemsScrollLerped, modMetadataItemsScroll, elapsed * scrollLerpFactor);
		modMetadataItems.y = modBanner.y + modBanner.height - modMetadataItemsScrollLerped;

		updateModItemsScrollBar();
		updateModMetadataItemsScrollBar();

		curBeat = Std.int(FlxG.sound.music.time / curCrochet);
		if (prevBeat != curBeat) {
			prevBeat = curBeat;
			if (curBeat % 2 == 0)
				spin();
		}
	}

	function boundModMetadataItemsY() {
		if (modMetadataItemsScroll < 0) {
			modMetadataItemsScroll = 0;
		} else if (modMetadataItemsScroll > modMetadataItemsScrollLimit) {
			modMetadataItemsScroll = modMetadataItemsScrollLimit;
		}
	}

	function boundModItemsY() {
		if (modItemsScroll > modItemsScrollLimit) {
			modItemsScroll = modItemsScrollLimit;
		} else if (modItemsScroll < 0) {
			modItemsScroll = 0;
		}
	}

	function backToMainMenu() {
		SuffState.playMusic('mainMenu');
		SuffState.switchState(new MainMenuState());
	}

	function spin() {
		for (item in icons) {
			item.rotate(1, curCrochet / 1000 * 2);
		}
	}
}
