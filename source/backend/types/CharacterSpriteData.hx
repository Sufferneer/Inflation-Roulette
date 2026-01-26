package backend.types;

typedef CharacterSpriteData = {
	spriteSheets:Array<String>,
	animations:Array<AnimationData>,
	belchThreshold:Int,
	gurgleThreshold:Int,
	creakThreshold:Int,
	antialiasing:Bool,
	disablePopping:Bool,
	positionOffset:Array<Int>,
	poppedCameraOffsetChange:Array<Int>,
	cameraOffset:Array<Int>,
	pointerOffset:Array<Int>,
	poppingVelocityMultiplier:Array<Float>,
	poppingGravityMultiplier:Float
}
