package backend.types;

typedef AnimationData = {
	name:String,
	prefix:String,
	fps:Int,
	offsets:Array<Int>,
	indices:Array<Int>,
	loop:Bool,
	soundPaths:Array<String>
}
