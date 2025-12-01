package backend.types;

typedef CharacterSpriteData = {
	animations:Array<AnimationData>,
	belchThreshold:Int,
	gurgleThreshold:Int,
	creakThreshold:Int,
	positionOffset:Array<Int>,
	poppedCameraOffsetChange:Array<Int>,
	cameraOffset:Array<Int>,
	pointerOffset:Array<Int>,
	poppingVelocityMultiplier:Array<Float>,
	poppingGravityMultiplier:Float
}
