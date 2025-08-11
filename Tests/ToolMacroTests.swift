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
				typealias Error = Never
				typealias Output = String

				var name: String {
					"GetWeather"
				}

				var description: String {
					"Get the weather for a location."
				}

				@Schemable struct Arguments: Decodable {
					/// The location to get the weather for.
					let location: String
				}

				func call(parameters: Arguments) async throws -> Output {
					try await self.call(location: parameters.location)
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
				typealias Error = Never
				typealias Output = String

				var name: String {
					"GetWeather"
				}

				var description: String {
					"Get the weather for a location."
				}

				@Schemable struct Arguments: Decodable {
					/// The location to get the weather for.
					let location: String
				}

				func call(parameters: Arguments) async throws -> Output {
					try await self.call(location: parameters.location)
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
				typealias Error = Never
				typealias Output = String

				var name: String {
					"GetWeather"
				}

				var description: String {
					"Get the weather for a location."
				}

				@Schemable struct Arguments: Decodable {
					/// The location to get the weather for.
					let location: String
				}

				func call(parameters: Arguments) async throws -> Output {
					try await self.call(at: parameters.location)
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
			struct GetWeather {}
			"""#
		} diagnostics: {
			#"""
			@Tool
			╰─ 🛑 Structs annotated with the @Tool macro must contain a `call` function.
			   ✏️ Add a `call` function
			struct GetWeather {}
			"""#
		} fixes: {
			#"""
			@Tool
			struct GetWeather {
				/// <#Describe the purpose of your tool to help the model understand when to use it#>
				func call(<#Any arguments your tool call requires#>) async throws {
					<#The implementation of your tool call, which can optionally return information to the model#>
				}
			}
			"""#
		} expansion: {
			"""
			struct GetWeather {
				/// <#Describe the purpose of your tool to help the model understand when to use it#>
				func call(<#Any arguments your tool call requires#>) async throws {
					<#The implementation of your tool call, which can optionally return information to the model#>
				}
			}

			extension GetWeather: Toolable {
			    typealias Error = Swift.Error
			    typealias Output = Void

			    var name: String {
			        "GetWeather"
			    }

			    @Schemable struct Arguments: Decodable {
			        let <#Any arguments your tool call requires#>:
			    }

			    func call(parameters: Arguments) async throws -> Output {
			    	try await self.call(<#Any arguments your tool call requires#>: parameters.<#Any arguments your tool call requires#>)
			    }
			}
			"""
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
				func call(parameters: Arguments) -> String {
					"Sunny in \(parameters.location)"
				}
			}
			"""#
		} diagnostics: {
			#"""
			@Tool
			struct GetWeather {
				/// Get the weather for a location.
				func call(parameters: Arguments) -> String {
			 ╰─ 🛑 When using the @Tool macro, use function parameters directly instead of manually creating an `Arguments` struct.
					"Sunny in \(parameters.location)"
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
				typealias Error = Never
				typealias Output = String

				var name: String {
					"GetWeather"
				}

				@Schemable struct Arguments: Decodable {
					let location: String
				}

				func call(parameters: Arguments) async throws -> Output {
					try await self.call(location: parameters.location)
				}
			}
			"""#
		}

		assertMacro {
			#"""
			@Tool
			struct GetWeather {
				/// <#Describe the purpose of your tool to help the model understand when to use it#>
				func call(location: String) -> String {
					"Sunny in \(location)"
				}
			}
			"""#
		} diagnostics: {
			#"""
			@Tool
			struct GetWeather {
				/// <#Describe the purpose of your tool to help the model understand when to use it#>
				func call(location: String) -> String {
			 ╰─ ⚠️ It's recommended to add documentation to the `call` function of your tool to help the model understand its purpose and usage.
					"Sunny in \(location)"
				}
			}
			"""#
		} expansion: {
			#"""
			struct GetWeather {
				/// <#Describe the purpose of your tool to help the model understand when to use it#>
				func call(location: String) -> String {
					"Sunny in \(location)"
				}
			}

			extension GetWeather: Toolable {
				typealias Error = Never
				typealias Output = String

				var name: String {
					"GetWeather"
				}

				@Schemable struct Arguments: Decodable {
					let location: String
				}

				func call(parameters: Arguments) async throws -> Output {
					try await self.call(location: parameters.location)
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
				typealias Error = Never
				typealias Output = String

				@Schemable struct Arguments: Decodable {
					let location: String
				}

				func call(parameters: Arguments) async throws -> Output {
					try await self.call(location: parameters.location)
				}
			}
			"""#
		}
	}
}
