import Foundation
import SwiftSyntax

extension SyntaxProtocol {
	var docString: String? {
		var docStringLines: [String] = []

		for piece in leadingTrivia {
			switch piece {
				case let .docLineComment(comment):
					let line = String(comment.dropFirst(3)).trimmingCharacters(in: .whitespaces) // remove leading ///
					docStringLines.append(line)
				case let .docBlockComment(comment):
					let content = comment.dropFirst(3).dropLast(2) // remove /** and */

					for line in content.split(separator: "\n") {
						// Remove leading asterisks and trim whitespace
						var trimmed = line.trimmingCharacters(in: .whitespaces)
						if !trimmed.isEmpty {
							if trimmed.hasPrefix("*") { trimmed = String(trimmed.dropFirst()) } // remove leading asterisk

							docStringLines.append(trimmed.trimmingCharacters(in: .whitespaces))
						}
					}
				default: break
			}
		}

		return docStringLines.isEmpty ? nil : docStringLines.joined(separator: "\n")
	}
}
