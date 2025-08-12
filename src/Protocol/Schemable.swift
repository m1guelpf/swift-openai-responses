import Foundation

public protocol Schemable {
	static var schema: JSONSchema { get }
}

public extension Schemable {
	static func schema(description: String? = nil) -> JSONSchema {
		schema.withDescription(description ?? schema.description)
	}
}

extension UUID: Schemable {
	public static var schema: JSONSchema {
		.string(format: .uuid)
	}
}

/// > Note: This requires `JSONDecoder` to be configured with a date decoding strategy of `.iso8601`.
extension Date: Schemable {
	public static var schema: JSONSchema {
		.string(format: .dateTime)
	}
}

public struct NullableVoid: Schemable, Encodable, Sendable {
	public static var schema: JSONSchema {
		.null(description: nil)
	}

	public init() {}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encodeNil()
	}
}
