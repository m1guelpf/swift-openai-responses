import Testing
import ToolMacros
import SwiftSyntax
import MacroTesting

@Suite(.macros([ToolMacro.self], record: .missing))
struct ToolMacroTests {
	@Test
	func basicExpansion() {
		assertMacro {
			#"""
			@Tool
			struct GetWeather {
				/// Get the weather for a location.
				/// - Parameter location: The location to get the weather for.
				func call(location: String) -> String {
					"Sunny in \(location)"
				}
			}
			"""#
		} expansion: {
			#"""
			struct GetWeather {
				/// Get the weather for a location.
				/// - Parameter location: The location to get the weather for.
				func call(location: String) -> String {
					"Sunny in \(location)"
				}
			}

			extension GetWeather: Toolable {
				var name: String {
					"GetWeather"
				}

				var description: String {
					"Get the weather for a location."
				}

				@Schemable struct Arguments {
					/// The location to get the weather for.
					let location: String
				}

				func call(arguments: Arguments) async throws -> Output {
					try await self.call(location: arguments.location)
				}
			}
			"""#
		}
	}
}
