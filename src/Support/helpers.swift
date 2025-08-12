func tap<T>(_ value: T, _ closure: (inout T) -> Void) -> T {
	var value = value
	closure(&value)
	return value
}
