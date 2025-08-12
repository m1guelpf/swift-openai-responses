import SwiftSyntax

nonisolated(unsafe) let PARAMETERS_HEADER_REGEX = /(?m)^\s*-\s*Parameters:\s*$/
nonisolated(unsafe) let PARAMETER_REGEX = /- Parameter (?<parameter>\w+): ?(?<comment>.*)/
nonisolated(unsafe) let PARAMETERS_ITEM_REGEX = /(?m)^\s*-\s*(?<parameter>\w+)\s*:\s*(?<comment>.*)$/

struct DocString {
	let docString: String
	let properties: [String: String]

	var fullDocString: String {
		var docString = self.docString.trimmingCharacters(in: .whitespacesAndNewlines)

		for (key, value) in properties {
			docString.append("\n- Parameter \(key): \(value)")
		}

		return docString
	}

	var trivia: Trivia {
		fullDocString.split(separator: "\n").reduce(into: Trivia()) { trivia, line in
			if !trivia.isEmpty { trivia = trivia.appending(.newline) }

			trivia = trivia.merging(.docLineComment("/// \(line)"))
		}
	}

	static func parse(_ docString: String?) -> DocString? {
		guard let docString, !docString.isEmpty else { return nil }

		return parse(docString)
	}

	static func parse(_ docString: String) -> DocString {
		var docString = docString
		let properties = parseParameters(&docString)

		return DocString(
			docString: docString.trimmingCharacters(in: .whitespacesAndNewlines),
			properties: properties
		)
	}

	func `for`(property: String) -> String? {
		properties[property]
	}

	func `for`(properties: String?...) -> String? {
		for property in properties {
			if let property, let value = self.properties[property] {
				return value
			}
		}

		return nil
	}

	func withComment(forProperty property: String, _ comment: String) -> DocString {
		var properties = self.properties
		properties[property] = comment

		return DocString(docString: docString, properties: properties)
	}

	private static func parseParameters(_ docString: inout String) -> [String: String] {
		var properties: [String: String] = [:]

		for match in docString.matches(of: PARAMETER_REGEX) {
			docString.removeSubrange(match.range.lowerBound..<match.range.upperBound)
			properties[String(match.output.parameter)] = String(match.output.comment)
		}

		guard let match = docString.firstMatch(of: PARAMETERS_HEADER_REGEX) else { return properties }
		docString.removeSubrange(match.range.lowerBound..<match.range.upperBound)

		for match in docString.matches(of: PARAMETERS_ITEM_REGEX) {
			docString.removeSubrange(match.range.lowerBound..<match.range.upperBound)
			properties[String(match.output.parameter)] = String(match.output.comment)
		}

		return properties
	}
}

extension DocString? {
	var isMissing: Bool {
		switch self {
			case .none: true
			case let .some(docString): docString.docString.isEmpty || docString.docString.isPlaceholder
		}
	}
}
