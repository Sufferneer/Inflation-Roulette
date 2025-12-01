package objects;

class Modifier {
	public var id:String = 'null';
	public var value:Float = 0;
	public function new(id, value) {
		this.id = id;
		this.value = value;
	}

	public function toString():String {
		return 'Modifier(id: ${id} || value: ${value})';
	}
}