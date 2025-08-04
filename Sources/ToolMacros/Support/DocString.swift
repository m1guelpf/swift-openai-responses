nonisolated(unsafe) let PARAMETER_REGEX = /- Parameter (?<parameter>\w*): ?(?<comment>.*)/

struct DocString {
	let docString: String
	let propertyDocStrings: [String: String]

	static func parse(_ docString: String?) -> DocString? {
		guard let docString, !docString.isEmpty else { return nil }

		return parse(docString)
	}

	static func parse(_ docString: String) -> DocString {
		var docString = docString
		var propertyDocStrings: [String: String] = [:]

		for match in docString.matches(of: PARAMETER_REGEX) {
			docString.removeSubrange(match.range.lowerBound..<match.range.upperBound)
			propertyDocStrings[String(match.output.parameter)] = String(match.output.comment)
		}

		return DocString(
			docString: docString.trimmingCharacters(in: .whitespacesAndNewlines),
			propertyDocStrings: propertyDocStrings
		)
	}

	func `for`(property: String) -> String? {
		propertyDocStrings[property]
	}
}
