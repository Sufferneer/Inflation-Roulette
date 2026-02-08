package backend.types;

typedef GamemodeData = {
	name:String,
	description:String,
	?color:String,

	?cylinderSize:Int,
	?cylinderLiveCount:Int,
	?cylinderReloadOnNoLives:Bool,
	?cylinderInitialDamage:Int,
	?cylinderDamageChangeOnLive:Int,
	?cylinderDamageChangeOnBlank:Int,
	?cylinderTrueRandomness:Bool,

	?skillsExhaustible:Bool,
	?skillsFixedPool:Array<String>,
	?skillsRandomPool:Array<String>,
	?skillsCostMultiplier:Float,
	?skillsReplenishCountOnLive:Int,
	?skillsReplenishCountOnBlank:Int,
}
