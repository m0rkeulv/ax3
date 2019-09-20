class ReverseIntIterator {
	var max:Int;
	var min:Int;

	/**
		Create a backwards int iterator.

		`reverseIntIter(10...0)` will iterate from 10 to 0 inclusively.
	**/
	@:access(IntIterator)
	public static inline function reverseIntIter(i:IntIterator) {
		// TODO: maybe this should be a macro function that checks if the argument is `a...b` expr
		// and generate `new ReverseIntIterator()` directly from it instead of relying on IntIterator inlining
		return new ReverseIntIterator(i.min, i.max);
	}

	inline function new(max:Int, min:Int) {
		this.max = max;
		this.min = min;
	}

	public inline function hasNext() {
		return max >= min;
	}

	public inline function next() {
		return max--;
	}
}
