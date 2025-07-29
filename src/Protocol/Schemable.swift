import Foundation

public protocol Schemable {
	static var schema: JSONSchema { get }
}
