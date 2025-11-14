import Foundation

/// The model to use for generating a response.
public enum Model: Equatable, Hashable, Sendable {
	case o1
	case o1Pro
	case o1Mini
	case o3
	case o3Pro
	case o3DeepResearch
	case o3Mini
	case o4Mini
	case o4MiniDeepResearch
	case codexMini
	case gpt5
	case gpt5Pro
	case gpt5Mini
	case gpt5Nano
	case gpt5Codex
	case gpt5CodexMini
	case gpt51
	case gpt51Mini
	case gpt51Codex
	case gpt51CodexMini
	case gpt4_5Preview
	case gpt4o
	case chatGPT4o
	case gpt4oMini
	case gpt4Turbo
	case gpt4
	case gpt4_1
	case gpt4_1Mini
	case gpt4_1Nano
	case gpt3_5Turbo
	case computerUsePreview
	case other(String)

	public var rawValue: String {
		switch self {
			case .o1: "o1"
			case .o3: "o3"
			case .gpt5: "gpt-5"
			case .gpt5Pro: "gpt-5-pro"
			case .gpt5Mini: "gpt-5-mini"
			case .gpt5Nano: "gpt-5-nano"
			case .gpt51: "gpt-5.1"
			case .gpt51Mini: "gpt-5.1-mini"
			case .gpt51Codex: "gpt-5.1-codex"
			case .gpt51CodexMini: "gpt-5.1-codex-mini"
			case .gpt4: "gpt-4"
			case .o3Pro: "o3-pro"
			case .o1Pro: "o1-pro"
			case .gpt4o: "gpt-4o"
			case .o1Mini: "o1-mini"
			case .o3Mini: "o3-mini"
			case .o4Mini: "o4-mini"
			case .gpt4_1: "gpt-4.1"
			case .codexMini: "codex-mini"
			case let .other(value): value
			case .gpt5Codex: "gpt-5-codex"
			case .gpt5CodexMini: "gpt-5-codex-mini"
			case .gpt4oMini: "gpt-4o-mini"
			case .gpt4Turbo: "gpt-4o-turbo"
			case .gpt4_1Nano: "gpt-4.1-nano"
			case .gpt4_1Mini: "gpt-4.1-mini"
			case .gpt3_5Turbo: "gpt-3.5-turbo"
			case .chatGPT4o: "chatgpt-4o-latest"
			case .gpt4_5Preview: "gpt-4.5-preview"
			case .o3DeepResearch: "o3-deep-research"
			case .computerUsePreview: "computer-use-preview"
			case .o4MiniDeepResearch: "o4-mini-deep-research"
		}
	}

	/// Creates a new `Model` instance from a string.
	public init(_ model: String) {
		switch model {
			case "o1": self = .o1
			case "o3": self = .o3
			case "gpt-5": self = .gpt5
			case "gpt-4": self = .gpt4
			case "gpt-4o": self = .gpt4o
			case "o1-pro": self = .o1Pro
			case "o3-pro": self = .o3Pro
			case "gpt-5.1": self = .gpt51
			case "o1-mini": self = .o1Mini
			case "o3-mini": self = .o3Mini
			case "o4-mini": self = .o4Mini
			case "gpt-4.1": self = .gpt4_1
			case "gpt-5-pro": self = .gpt5Pro
			case "gpt-5-mini": self = .gpt5Mini
			case "gpt-5-nano": self = .gpt5Nano
			case "codex-mini": self = .codexMini
			case "gpt-5-codex": self = .gpt5Codex
			case "gpt-4o-mini": self = .gpt4oMini
			case "gpt-5.1-mini": self = .gpt51Mini
			case "gpt-4o-turbo": self = .gpt4Turbo
			case "gpt-4.1-nano": self = .gpt4_1Nano
			case "gpt-4.1-mini": self = .gpt4_1Mini
			case "gpt-5.1-codex": self = .gpt51Codex
			case "gpt-3.5-turbo": self = .gpt3_5Turbo
			case "chatgpt-4o-latest": self = .chatGPT4o
			case "gpt-4.5-preview": self = .gpt4_5Preview
			case "gpt-5-codex-mini": self = .gpt5CodexMini
			case "o3-deep-research": self = .o3DeepResearch
			case "gpt-5.1-codex-mini": self = .gpt51CodexMini
			case "computer-use-preview": self = .computerUsePreview
			case "o4-mini-deep-research": self = .o4MiniDeepResearch
			default: self = .other(model)
		}
	}
}

public extension Model {
	enum Image: Equatable, Hashable, Sendable {
		case gptImage
		case gptImageMini
		case other(String)

		public var rawValue: String {
			switch self {
				case .gptImage: "gpt-image-1"
				case .gptImageMini: "gpt-image-1-mini"
				case let .other(value): value
			}
		}

		/// Creates a new `Model.Image` instance from a string.
		public init(_ model: String) {
			switch model {
				case "gpt-image-1": self = .gptImage
				case "gpt-image-1-mini": self = .gptImageMini
				default: self = .other(model)
			}
		}
	}
}

extension Model: RawRepresentable, Codable {
	public func encode(to encoder: any Encoder) throws {
		try rawValue.encode(to: encoder)
	}

	public init(from decoder: any Decoder) throws {
		try self.init(String(from: decoder))
	}

	public init?(rawValue: String) {
		self.init(rawValue)
	}
}

extension Model.Image: RawRepresentable, Codable {
	public func encode(to encoder: any Encoder) throws {
		try rawValue.encode(to: encoder)
	}

	public init(from decoder: any Decoder) throws {
		try self.init(String(from: decoder))
	}

	public init?(rawValue: String) {
		self.init(rawValue)
	}
}
