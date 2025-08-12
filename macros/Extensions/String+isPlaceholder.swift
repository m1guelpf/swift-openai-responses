import Foundation

nonisolated(unsafe) let placeholderPattern = /\<\#[\w ]*\#\>/

extension String {
	var isPlaceholder: Bool {
		trimmingCharacters(in: .whitespacesAndNewlines).contains(placeholderPattern)
	}
}
