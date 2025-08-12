func tap<T, E>(_ value: T, _ closure: (inout T) throws(E) -> Void) throws(E) -> T {
	var mutableValue = value
	try closure(&mutableValue)
	return mutableValue
}

extension Sequence {
	func map(tapping: (inout Element) -> Void) -> [Element] {
		map { element in tap(element, tapping) }
	}
}
