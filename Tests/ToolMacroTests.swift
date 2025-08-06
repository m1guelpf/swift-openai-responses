import Testing
import ToolMacros
import SwiftSyntax
import MacroTesting

@Suite(.macros([ToolMacro.self], record: .missing))
struct ToolMacroTests {
	@Test("Properly generates Toolable conformance")
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

	@Test("Handles multi-parameter doc comments")
	func handlesMultiParameterDocs() {
		assertMacro {
			#"""
			@Tool
			struct GetWeather {
				/// Get the weather for a location.
				/// - Parameters:
				/// 	- location: The location to get the weather for.
				func call(location: String) -> String {
					"Sunny in \(location)"
				}
			}
			"""#
		} expansion: {
			#"""
			struct GetWeather {
				/// Get the weather for a location.
				/// - Parameters:
				/// 	- location: The location to get the weather for.
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

	@Test("Handles parameters with custom names")
	func handlesCustomNamedParameters() {
		assertMacro {
			#"""
			@Tool
			struct GetWeather {
				/// Get the weather for a location.
				/// - Parameter at: The location to get the weather for.
				func call(at location: String) -> String {
					"Sunny in \(location)"
				}
			}
			"""#
		} expansion: {
			#"""
			struct GetWeather {
				/// Get the weather for a location.
				/// - Parameter at: The location to get the weather for.
				func call(at location: String) -> String {
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
					try await self.call(at: arguments.location)
				}
			}
			"""#
		}
	}

	@Test("Requires parameters to be named")
	func errorsWithUnnamedParameters() {
		assertMacro {
			#"""
			@Tool
			struct GetWeather {
				/// Get the weather for a location.
				func call(_ location: String) -> String {
					"Sunny in \(location)"
				}
			}
			"""#
		} diagnostics: {
			#"""
			@Tool
			struct GetWeather {
				/// Get the weather for a location.
				func call(_ location: String) -> String {
			           ┬─────────────────
			           ╰─ 🛑 All parameters must be named.
					"Sunny in \(location)"
				}
			}
			"""#
		}
	}

	@Test("Requires call method")
	func requiresCallMethod() {
		assertMacro {
			#"""
			@Tool
			struct GetWeather {
				/// Get the weather for a location.
				func somethingElse(location: String) -> String {
					"Sunny in \(location)"
				}
			}
			"""#
		} diagnostics: {
			#"""
			@Tool
			╰─ 🛑 Structs annotated with the @Tool macro must contain a `call` function.
			struct GetWeather {
				/// Get the weather for a location.
				func somethingElse(location: String) -> String {
					"Sunny in \(location)"
				}
			}
			"""#
		}
	}

	@Test("Requires a struct")
	func requiresStruct() {
		assertMacro {
			#"""
			@Tool
			class GetWeather {
				/// Get the weather for a location.
				func call(location: String) -> String {
					"Sunny in \(location)"
				}
			}
			"""#
		} diagnostics: {
			#"""
			@Tool
			╰─ 🛑 The @Tool macro can only be applied to structs.
			class GetWeather {
				/// Get the weather for a location.
				func call(location: String) -> String {
					"Sunny in \(location)"
				}
			}
			"""#
		}
	}

	@Test("Must only have one call method")
	func errorsWithMultipleCallMethods() {
		assertMacro {
			#"""
			@Tool
			struct GetWeather {
				/// Get the weather for a location.
				func call(location: String) -> String {
					"Sunny in \(location)"
				}

				/// Get the weather for a country.
				func call(country: String) -> String {
					"Rainy in \(location)"
				}
			}
			"""#
		} diagnostics: {
			#"""
			@Tool
			╰─ 🛑 Structs annotated with the @Tool macro may only contain a single `call` function.
			struct GetWeather {
				/// Get the weather for a location.
				func call(location: String) -> String {
					"Sunny in \(location)"
				}

				/// Get the weather for a country.
				func call(country: String) -> String {
					"Rainy in \(location)"
				}
			}
			"""#
		}
	}

	@Test("Call method in struct must not be the Toolable implementation")
	func callMethodMustNotBeDefault() {
		assertMacro {
			#"""
			@Tool
			struct GetWeather {
				/// Get the weather for a location.
				func call(arguments: Arguments) -> String {
					"Sunny in \(arguments.location)"
				}
			}
			"""#
		} diagnostics: {
			#"""
			@Tool
			struct GetWeather {
				/// Get the weather for a location.
				func call(arguments: Arguments) -> String {
			 ╰─ 🛑 When using the @Tool macro, use function parameters directly instead of manually creating an `Arguments` struct.
					"Sunny in \(arguments.location)"
				}
			}
			"""#
		}
	}

	@Test("Providing no documentation on your tool shows a warning")
	func noDocumentationWarning() {
		assertMacro {
			#"""
			@Tool
			struct GetWeather {
				func call(location: String) -> String {
					"Sunny in \(location)"
				}
			}
			"""#
		} diagnostics: {
			#"""
			@Tool
			struct GetWeather {
				func call(location: String) -> String {
			 ╰─ ⚠️ It's recommended to add documentation to the `call` function of your tool to help the model understand its purpose and usage.
					"Sunny in \(location)"
				}
			}
			"""#
		} expansion: {
			#"""
			struct GetWeather {
				func call(location: String) -> String {
					"Sunny in \(location)"
				}
			}

			extension GetWeather: Toolable {
				var name: String {
					"GetWeather"
				}

				@Schemable struct Arguments {
					let location: String
				}

				func call(arguments: Arguments) async throws -> Output {
					try await self.call(location: arguments.location)
				}
			}
			"""#
		}
	}

	@Test("Skips generating name and description if they're already present")
	func skipsNameAndDescriptionIfPresent() {
		assertMacro {
			#"""
			@Tool
			struct GetWeather {
				var name: String {
					"Weather Tool"
				}

				var description: String {
					"Get the weather for a location."
				}

				/// A different description here.
				func call(location: String) -> String {
					"Sunny in \(location)"
				}
			}
			"""#
		} expansion: {
			#"""
			struct GetWeather {
				var name: String {
					"Weather Tool"
				}

				var description: String {
					"Get the weather for a location."
				}

				/// A different description here.
				func call(location: String) -> String {
					"Sunny in \(location)"
				}
			}

			extension GetWeather: Toolable {
				@Schemable struct Arguments {
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
