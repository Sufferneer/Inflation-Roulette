package backend.types;

typedef AnimationData = {
	name:String,
	prefix:String,
	fps:Int,
	offset:Array<Int>,
	indices:Array<Int>,
	loop:Bool,
	soundPaths:Array<String>
}
