import Foundation

/// The model to use for generating a response.
public enum Model: Equatable, Hashable, Sendable {
	case o1
	case o1Mini
	case o3Mini
	case gpt4_5Preview
	case gpt4o
	case gpt4oMini
	case gpt4Turbo
	case gpt4
	case gpt3_5Turbo
	case computerUsePreview
	case other(String)
}

extension Model: Codable {
	public func encode(to encoder: any Encoder) throws {
		switch self {
			case .o1: try "o1".encode(to: encoder)
			case .gpt4: try "gpt-4".encode(to: encoder)
			case .gpt4o: try "gpt-4o".encode(to: encoder)
			case .o1Mini: try "o1-mini".encode(to: encoder)
			case .o3Mini: try "o3-mini".encode(to: encoder)
			case .gpt4oMini: try "gpt-4o-mini".encode(to: encoder)
			case .gpt4Turbo: try "gpt-4o-turbo".encode(to: encoder)
			case .gpt3_5Turbo: try "gpt-3.5-turbo".encode(to: encoder)
			case .gpt4_5Preview: try "gpt-4.5-preview".encode(to: encoder)
			case .computerUsePreview: try "computer-use-preview".encode(to: encoder)
			case let .other(value): try value.encode(to: encoder)
		}
	}

	public init(from decoder: any Decoder) throws {
		let value = try String(from: decoder)

		switch value {
			case "o1": self = .o1
			case "gpt-4": self = .gpt4
			case "gpt-4o": self = .gpt4o
			case "o1-mini": self = .o1Mini
			case "o3-mini": self = .o3Mini
			case "gpt-4o-mini": self = .gpt4oMini
			case "gpt-4o-turbo": self = .gpt4Turbo
			case "gpt-3.5-turbo": self = .gpt3_5Turbo
			case "gpt-4.5-preview": self = .gpt4_5Preview
			case "computer-use-preview": self = .computerUsePreview
			default: self = .other(value)
		}
	}
}
