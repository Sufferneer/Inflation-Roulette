package states;

import backend.Addons;
import backend.types.AddonData;
import flixel.util.FlxGradient;
import states.MainMenuState;
import ui.objects.AddonMenuBG;
import ui.objects.AddonMenuBG.AddonMenuBGTile;
import ui.objects.AddonMenuItem;
import ui.objects.SuffIconButton;
import tjson.TJSON as Json;

class AddonMenuState extends SuffState {
	var icons:FlxTypedSpriteGroup<AddonMenuBG> = new FlxTypedSpriteGroup<AddonMenuBG>();
	var modBG:FlxSprite;
	var modItems:FlxTypedSpriteGroup<AddonMenuItem> = new FlxTypedSpriteGroup<AddonMenuItem>();
	var modItemsUpperY:Float = 0;
	var modItemsLowerY:Float = 0;
	var modItemScrollBar:FlxSprite;

	var modBannerBG:FlxSprite;
	var modBanner:FlxSprite;
	var modBannerVignette:FlxSprite;

	var modMetadataItems:FlxSpriteGroup = new FlxSpriteGroup();
	var modMetadataItemsUpperY:Float = 0;
	var modMetadataItemsLowerY:Float = 0;
	var modTitleText:FlxText;
	var modDescriptionText:FlxText;
	var modAuthorTitleText:FlxText;
	var modAuthorsText:FlxText;
	var modMetadataScrollBar:FlxSprite;

	public static final padding:Int = 20;
	public static final itemCount:Int = 5;

	final scrollBarWidth:Int = 30;

	var curCrochet:Float = 0;
	var prevBeat:Int = 0;
	var curBeat:Int = 0;

	override function create() {
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [0xFF0000FF, 0xFF8000FF, 0xFFFF00FF]));
		bg.alpha = 0.5;
		add(bg);

		add(icons);

		var size = AddonMenuBGTile.bgSize * 2;
		for (h in 0...Math.ceil(FlxG.height / size) + 1) {
			for (w in 0...Math.ceil(FlxG.width / size) + 1) {
				var tile = new AddonMenuBG(w * size, h * size);
				for (item in tile.members) {
					item.color = 0xFF8000FF;
					item.alpha = 0.5;
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
		AddonMenuItem.defaultHeight = Std.int(modBG.height / AddonMenuState.itemCount);

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
			modItemsLowerY = FlxG.height - modItems.height;
		}

		modItemScrollBar = new FlxSprite(modBG.x + modBG.width,
			modBG.y).makeGraphic(Std.int(scrollBarWidth), Std.int(FlxG.height * (FlxG.height / (Math.abs(modItemsLowerY) + FlxG.height))), 0xFFFFFFFF);
		modItemScrollBar.alpha = 0.25;
		modItemScrollBar.visible = (modItems.height > FlxG.height);
		updateModItemScrollBar();
		add(modItemScrollBar);

		modBanner = new FlxSprite();

		modBannerVignette = new FlxSprite().loadGraphic(Paths.image('gui/menus/addon/bannerVignette'));
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

		modMetadataScrollBar = new FlxSprite(modBannerBG.x - scrollBarWidth, modBannerBG.y);
		updateModMetadataScrollBar();
		add(modMetadataScrollBar);

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

	function updateModItemScrollBar() {
		modItemScrollBar.y = modItems.y / modItemsLowerY * (FlxG.height - modItemScrollBar.height);
	}

	function updateModMetadataScrollBar() {
		modMetadataScrollBar.y = modMetadataItems.y / modMetadataItemsLowerY * (FlxG.height - modMetadataScrollBar.height);
	}

	function changeDisplayedMetadata(folder:String, addon:AddonData = null) {
		changeBanner(folder);

		if (addon == null) return;
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

		modMetadataItems.y = modMetadataItemsUpperY = modBanner.y + modBanner.height;
		if ((FlxG.height - modMetadataItems.y) < modMetadataItems.height) {
			modMetadataItemsLowerY = (FlxG.height - modMetadataItems.y) - modMetadataItems.height;
			modMetadataItemsLowerY = modMetadataItemsUpperY + modMetadataItemsLowerY - 16;
		} else {
			modMetadataItemsLowerY = modMetadataItemsUpperY;
		}

		if (modMetadataScrollBar != null) {
			modMetadataScrollBar.makeGraphic(Std.int(scrollBarWidth),
				Std.int((FlxG.height - modBanner.height) * (FlxG.height / (Math.abs(modMetadataItemsUpperY - modMetadataItemsLowerY) + FlxG.height))),
				0xFFFFFFFF);
			modMetadataScrollBar.alpha = 0.25;
			modMetadataScrollBar.visible = (modMetadataItemsUpperY != modMetadataItemsLowerY);
		}
	}

	function changeBanner(folder:String) {
		var path:String = Paths.addons('$folder/banner.png');
		if (!FileSystem.exists(path)) {
			path = Paths.getImagePath('gui/menus/addon/defaultBanner');
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
				modItems.y += FlxG.mouse.wheel * 64;
				updateModItemScrollBar();
				boundModItemsY();
			} else if (FlxG.mouse.overlaps(modBannerBG)) {
				modMetadataItems.y += FlxG.mouse.wheel * 32;
				updateModMetadataScrollBar();
				boundModMetadataItemsY();
			}
		}
		if (FlxG.keys.justPressed.ESCAPE) {
			backToMainMenu();
		}
		if (FlxG.mouse.pressed) {
			if (FlxG.mouse.x > FlxG.width / 2) {
				if (modMetadataScrollBar.visible) {
					modMetadataItems.y = modMetadataItems.y - (FlxG.mouse.deltaScreenY) * (FlxG.height / modMetadataScrollBar.height);
					boundModMetadataItemsY();
					updateModMetadataScrollBar();
				}
			} else {
				modItems.y = modItems.y - (FlxG.mouse.deltaScreenY) * (FlxG.height / modItemScrollBar.height);
				boundModItemsY();
				updateModItemScrollBar();
			}
		}

		curBeat = Std.int(FlxG.sound.music.time / curCrochet);
		if (prevBeat != curBeat) {
			prevBeat = curBeat;
			if (curBeat % 2 == 0)
				spin();
		}
	}

	function boundModMetadataItemsY() {
		if (modMetadataItems.y < modMetadataItemsLowerY) {
			modMetadataItems.y = modMetadataItemsLowerY;
		} else if (modMetadataItems.y > modMetadataItemsUpperY) {
			modMetadataItems.y = modMetadataItemsUpperY;
		}
	}

	function boundModItemsY() {
		if (modItems.y < modItemsLowerY) {
			modItems.y = modItemsLowerY;
		} else if (modItems.y > modItemsUpperY) {
			modItems.y = modItemsUpperY;
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
