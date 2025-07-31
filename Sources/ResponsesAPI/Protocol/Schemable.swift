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
