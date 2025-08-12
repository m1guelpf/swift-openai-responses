import Foundation

public protocol Toolable: Equatable, Sendable {
	/// Arguments used to call the tool.
	associatedtype Arguments: Decodable & Schemable

	/// The output that the tool produces.
	associatedtype Output: Encodable

	/// The error type that the tool can throw.
	associatedtype Error: Swift.Error

	/// The name of the tool to call.
	var name: String { get }

	/// A description of the tool, used by the model to determine whether or not to call it.
	var description: String { get }

	/// Whether to enforce strict parameter validation.
	var strict: Bool { get }

	/// Initializes the tool.
	init()

	/// Runs the tool with the given parameters.
	func call(parameters: Self.Arguments) async throws(Self.Error) -> Self.Output
}

public extension Toolable {
	typealias Output = Void
	typealias Error = Swift.Error

	var strict: Bool { true }
	var description: String { "" }
}

package extension Toolable {
	func intoFunction() -> Tool.Function {
		guard case .object = Arguments.schema else {
			fatalError("Tool arguments must be a struct.")
		}

		return Tool.Function(name: name, description: description, parameters: Arguments.schema, strict: strict)
	}

	func respond(to functionCall: Item.FunctionCall) async throws -> Item.FunctionCallOutput {
		let parameters = try decoder.decode(Arguments.self, from: Data(functionCall.arguments.utf8))

		let output = try await call(parameters: parameters)

		return try Item.FunctionCallOutput(
			callId: functionCall.callId,
			output: encoder.encodeToString(output)
		)
	}
}

fileprivate nonisolated let encoder = JSONEncoder()
fileprivate nonisolated let decoder = JSONDecoder()
