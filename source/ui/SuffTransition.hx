package ui;

import backend.enums.SuffTransitionStyle;

class SuffTransition extends SuffSubState {
	public static var finishCallback:Void->Void;
	public static var style:SuffTransitionStyle = DEFAULT;

	private var leTween:FlxTween = null;

	var isTransIn:Bool = false;
	var trans:FlxSpriteGroup = new FlxSpriteGroup();
	var loadingTxt:FlxText;

	var duration:Float = 0;
	static final widthHeightGCF:Int = 80;

	// Blocky
	var blockDuration:Float = 0;
	var transitionProgess:Float = 0;
	var durationPerBlock:Float = 0;
	var curBlock:Int = 0;
	static final blockSize:Int = 160;

	static final randomLoadingLines:Array<String> = [
		'Loading',
		'Please wait',
		'Please be patient',
		'Setting things up',
		'Tidying furniture',
		'Scavenging weapons',
		'Recasing bullets',
		'Patching abdomens',
		'Interviewing participants',
		'Deflating participants',
		'Preparing refreshments',
		'Spiking refreshments'
	];

	static final randomLoadingLinesRare:Array<String> = [
		'Unloading then reloading everything',
		'Collecting tears',
		'Calling the police',
		'Running the hell machine',
		'Preparing for the DSE',
		'Wasting time',
		'Creating more bugs',
		'Fixing modding support',
		'Dark was the night',
		'Cold was the ground',
		'This game is 10 days overdue'
	];

	public function new(duration:Float, isTransIn:Bool) {
		super();

		this.isTransIn = isTransIn;
		this.duration = duration;

		trans.scrollFactor.set();
		add(trans);

		switch (style) {
			case DEFAULT:
				var tran:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gui/transitions/default'));
				tran.setGraphicSize(Std.int(tran.width * FlxG.width / 1280), Std.int(tran.height * FlxG.height / 720));
				tran.updateHitbox();
				trans.add(tran);
			case BLOCKY:
				var fileList = [];
				var imageList = [];
				#if sys
				fileList = FileSystem.readDirectory(Paths.getPath('images/gui/transitions/blocky'));
				#else
				fileList = Util.textFileToArray(Paths.getPath('images/gui/transitions/blocky/blockList.txt'));
				#end
				for (folder in fileList) {
					if (!folder.toLowerCase().endsWith('.txt')) {
						imageList.push(folder.replace('.png', ''));
					}
				}

				for (h in 0...Math.ceil(FlxG.height / blockSize)) {
					for (w in 0...Math.ceil(FlxG.width / blockSize)) {
						var tran:TransitionBlock = new TransitionBlock(w * blockSize - (FlxG.width % blockSize) / 2,
							h * blockSize - (FlxG.height % blockSize) / 2, imageList[FlxG.random.int(0, imageList.length - 1)], blockSize, (w + h) % 2 == 0 ? 0xFF000000 : 0xFF202020);
						tran.visible = isTransIn;
						trans.add(tran);
					}
				}
		}

		var leText = '';
		if (FlxG.random.bool(25)) {
			leText = randomLoadingLinesRare[FlxG.random.int(0, randomLoadingLinesRare.length - 1)];
		} else {
			leText = randomLoadingLines[FlxG.random.int(0, randomLoadingLines.length - 1)];
		}

		loadingTxt = new FlxText(0, 0, FlxG.width / 2, leText.toUpperCase() + '...');
		loadingTxt.setFormat(Paths.font('default'), 72, FlxColor.WHITE);
		loadingTxt.setPosition(72, FlxG.height - 72 - loadingTxt.height);
		add(loadingTxt);
		loadingTxt.visible = false;

		runTransition(isTransIn, style);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
	}

	function runTransition(transIn:Bool, style:SuffTransitionStyle = DEFAULT) {
		switch (style) {
			case DEFAULT:
				if (!transIn) {
					trans.y = -trans.height;
					FlxTween.tween(trans, {y: -widthHeightGCF}, duration, {
						onComplete: function(twn:FlxTween) {
							startLoading();
						},
						ease: FlxEase.quadIn
					});
				} else {
					endLoading();
					trans.y = -widthHeightGCF;
					leTween = FlxTween.tween(trans, {y: FlxG.height}, duration, {
						onComplete: function(twn:FlxTween) {
							close();
						},
						ease: FlxEase.quadOut
					});
				}
			case BLOCKY:
				var usedDuration:Float = duration * 5;
				durationPerBlock = usedDuration / (trans.members.length - 1);
				if (!transIn) {
					FlxTween.num(0, 1, usedDuration, {
						onComplete: function(_) {
							startLoading();
						}
					}, function(value:Float) {
						transitionProgess = value;
					});
				} else {
					endLoading();
					FlxTween.num(0, 1, usedDuration, {
						onComplete: function(_) {
							close();
						}
					}, function(value:Float) {
						transitionProgess = value;
					});
				}
		}
	}

	function updateTransition(elapsed:Float, style:SuffTransitionStyle = DEFAULT) {
		switch (style) {
			case DEFAULT:
				// Nothing to update, yet
			case BLOCKY:
				blockDuration += elapsed;
				if (blockDuration >= durationPerBlock) {
					for (_ in 0...Math.ceil(blockDuration / durationPerBlock)) {
						if (curBlock < trans.members.length) {
							trans.members[curBlock].visible = !isTransIn;
							curBlock++;
							SuffState.playUISound(Paths.soundRandom('ui/transition/pop', 1, 5), FlxG.random.float(0.25, 0.75), FlxG.random.float(2, 3));
						}
					}
					blockDuration = 0;
				}
		}
	}

	function startLoading() {
		if (finishCallback != null) {
			loadingTxt.visible = true;
			finishCallback();
		}
	}

	function endLoading() {
		loadingTxt.visible = false;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		updateTransition(elapsed, style);
	}
}
