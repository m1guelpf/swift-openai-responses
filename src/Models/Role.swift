import Foundation

/// The role of a message.
public enum Role: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
	case user
	case system
	case assistant
	case developer
}
