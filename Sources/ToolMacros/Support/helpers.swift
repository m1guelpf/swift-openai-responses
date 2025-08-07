func tap<T>(_ value: T, _ closure: (inout T) -> Void) -> T {
	var mutableValue = value
	closure(&mutableValue)
	return mutableValue
}

extension Sequence {
	func map(tapping: (inout Element) -> Void) -> [Element] {
		map { element in tap(element, tapping) }
	}
}
