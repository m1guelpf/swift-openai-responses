import Macros
import Testing
import SwiftSyntax
import MacroTesting

@Suite(.macros([SchemaMacro.self, ArraySchemaMacro.self, StringSchemaMacro.self, NumberSchemaMacro.self], record: .missing))
struct SchemaMacroTests {
	@Test("Properly generates schema for a struct with primitives")
	func structSchemaWithPrimitives() {
		assertMacro {
			"""
			/// Represents a user in the system.
			@Schema
			struct User {
				/// Unique identifier for the user.
				let id: Int
				let username: String
				let isAdmin: Bool
				let balance: Float
				/// Flags associated with the user.
				let flags: [String]
				let creditScore: Double?
			}
			"""
		} expansion: {
			"""
			/// Represents a user in the system.
			struct User {
				/// Unique identifier for the user.
				let id: Int
				let username: String
				let isAdmin: Bool
				let balance: Float
				/// Flags associated with the user.
				let flags: [String]
				let creditScore: Double?
			}

			extension User: Schemable {
				static var schema: JSONSchema {
					.object(properties: [
						"id": .integer(description: "Unique identifier for the user."),
						"username": .string(description: nil),
						"isAdmin": .boolean(description: nil),
						"balance": .number(description: nil),
						"flags": .array(of: .string(description: nil), description: "Flags associated with the user."),
						"creditScore": .anyOf([.number(description: nil), .null], description: nil),
					], description: "Represents a user in the system.")
				}
			}
			"""
		}
	}

	@Test("Treats default values in struct as optional")
	func structSchemaWithDefault() async throws {
		assertMacro {
			"""
			@Schema
			struct UserPermissions {
				/// Whether the user is an admin.
				let isAdmin: Bool = false
				let flags: Float
			}
			"""
		} expansion: {
			"""
			struct UserPermissions {
				/// Whether the user is an admin.
				let isAdmin: Bool = false
				let flags: Float
			}

			extension UserPermissions: Schemable {
				static var schema: JSONSchema {
					.object(properties: [
						"isAdmin": .anyOf([.boolean(description: nil), .null], description: "Whether the user is an admin."),
						"flags": .number(description: nil),
					], description: nil)
				}
			}
			"""
		}
	}

	@Test("Handles nested structs with primitives")
	func structContainingStruct() {
		assertMacro {
			"""
			@Schema
			struct Address {
				let street: String
				let city: String
				let zipCode: Int
			}

			@Schema
			struct UserProfile {
				let name: String
				let age: Int
				/// The user's address.
				let address: Address
			}
			"""
		} expansion: {
			"""
			struct Address {
				let street: String
				let city: String
				let zipCode: Int
			}
			struct UserProfile {
				let name: String
				let age: Int
				/// The user's address.
				let address: Address
			}

			extension Address: Schemable {
				static var schema: JSONSchema {
					.object(properties: [
						"street": .string(description: nil),
						"city": .string(description: nil),
						"zipCode": .integer(description: nil),
					], description: nil)
				}
			}

			extension UserProfile: Schemable {
				static var schema: JSONSchema {
					.object(properties: [
						"name": .string(description: nil),
						"age": .integer(description: nil),
						"address": Address.schema(description: "The user's address."),
					], description: nil)
				}
			}
			"""
		}
	}

	@Test("Ignores computed properties in struct")
	func structWithComputedProperty() {
		assertMacro {
			"""
			@Schema
			struct User {
				let id: Int
				let username: String

				/// Computed property that returns the user's full name.
				var fullName: String {
					return "\\(username) \\(id)"
				}
			}
			"""
		} expansion: {
			"""
			struct User {
				let id: Int
				let username: String

				/// Computed property that returns the user's full name.
				var fullName: String {
					return "\\(username) \\(id)"
				}
			}

			extension User: Schemable {
				static var schema: JSONSchema {
					.object(properties: [
						"id": .integer(description: nil),
						"username": .string(description: nil),
					], description: nil)
				}
			}
			"""
		}
	}

	@Test("Allows customizing string schema with @StringSchema")
	func structCustomStringSchema() {
		assertMacro {
			"""
			@Schema
			struct Server {
				/// The hostname of the server.
				@StringSchema(pattern: "^[a-zA-Z0-9_]+$", format: .hostname)
				let host: String
			}
			"""
		} expansion: {
			"""
			struct Server {
				/// The hostname of the server.
				let host: String
			}

			extension Server: Schemable {
				static var schema: JSONSchema {
					.object(properties: [
						"host": .string(pattern: "^[a-zA-Z0-9_]+$", format: .hostname, description: "The hostname of the server."),
					], description: nil)
				}
			}
			"""
		}
	}

	@Test("Allows customizing array schema with @ArraySchema")
	func structCustomArraySchema() {
		assertMacro {
			"""
			@Schema
			struct Post {
				/// A list of tags associated with the post.
				@ArraySchema(minItems: 1, maxItems: 10)
				let tags: [String]
			}
			"""
		} expansion: {
			"""
			struct Post {
				/// A list of tags associated with the post.
				let tags: [String]
			}

			extension Post: Schemable {
				static var schema: JSONSchema {
					.object(properties: [
						"tags": .array(of: .string(description: nil), minItems: 1, maxItems: 10, description: "A list of tags associated with the post."),
					], description: nil)
				}
			}
			"""
		}
	}

	@Test("Allows customizing number schema with @NumberSchema")
	func structCustomNumberSchema() {
		assertMacro {
			"""
			@Schema
			struct Product {
				@NumberSchema(maximum: 100)
				let id: Int
				/// The price of the product.
				@NumberSchema(multipleOf: 0.01, minimum: 0.0)
				let price: Double
			}
			"""
		} expansion: {
			"""
			struct Product {
				let id: Int
				/// The price of the product.
				let price: Double
			}

			extension Product: Schemable {
				static var schema: JSONSchema {
					.object(properties: [
						"id": .integer(maximum: 100, description: nil),
						"price": .number(multipleOf: 0.01, minimum: 0.0, description: "The price of the product."),
					], description: nil)
				}
			}
			"""
		}
	}

	@Test("Attribute macros get propagated correctly")
	func structWithNestedAttributes() {
		assertMacro {
			"""
			@Schema
			struct User {
				/// A collection of IDs of posts the user has liked.
				@NumberSchema(multipleOf: 2, minimum: 2)
				let likedPosts: [Int]

				/// The user's unique identifier.
				@ArraySchema(minItems: 1, maxItems: 5)
				@StringSchema(pattern: .uuid)
				let identities: [String]?

				/// The user's email address.
				@StringSchema(format: .email)
				let email: String?
			}
			"""
		} expansion: {
			"""
			struct User {
				/// A collection of IDs of posts the user has liked.
				let likedPosts: [Int]

				/// The user's unique identifier.
				let identities: [String]?

				/// The user's email address.
				let email: String?
			}

			extension User: Schemable {
				static var schema: JSONSchema {
					.object(properties: [
						"likedPosts": .array(of: .integer(multipleOf: 2, minimum: 2, description: nil), description: "A collection of IDs of posts the user has liked."),
						"identities": .anyOf([.array(of: .string(pattern: .uuid, description: nil), minItems: 1, maxItems: 5, description: nil), .null], description: "The user's unique identifier."),
						"email": .anyOf([.string(format: .email, description: nil), .null], description: "The user's email address."),
					], description: nil)
				}
			}
			"""
		}
	}

	@Test("Falls back to schema property for non-primitive types")
	func structDefaultsToSchema() {
		assertMacro {
			"""
			@Schema
			struct Cmd {
				let command: String
				let arguments: Arguments
			}
			"""
		} expansion: {
			"""
			struct Cmd {
				let command: String
				let arguments: Arguments
			}

			extension Cmd: Schemable {
				static var schema: JSONSchema {
					.object(properties: [
						"command": .string(description: nil),
						"arguments": Arguments.schema(description: nil),
					], description: nil)
				}
			}
			"""
		}
	}

	@Test("Generates schema for enum without associated values")
	func enumWithoutAssociatedValues() {
		assertMacro {
			"""
			/// A user role in the system.
			@Schema
			enum UserRole {
				case admin
				case user
				case guest
			}
			"""
		} expansion: {
			"""
			/// A user role in the system.
			enum UserRole {
				case admin
				case user
				case guest
			}

			extension UserRole: Schemable {
				static var schema: JSONSchema {
					.enum(cases: ["admin", "user", "guest"], description: "A user role in the system.")
				}
			}
			"""
		}
	}

	@Test("Propagates case comments to enum schema on enums without associated cases")
	func enumWithoutAssociatedValuesComments() {
		assertMacro {
			"""
			/// A user role in the system.
			@Schema
			enum UserRole {
				/// Admin user with full permissions.
				case admin
				case user
				/// Guest user with minimal permissions.
				case guest
			}
			"""
		} expansion: {
			#"""
			/// A user role in the system.
			enum UserRole {
				/// Admin user with full permissions.
				case admin
				case user
				/// Guest user with minimal permissions.
				case guest
			}

			extension UserRole: Schemable {
				static var schema: JSONSchema {
					.enum(cases: ["admin", "user", "guest"], description: "A user role in the system.\n\n- admin: Admin user with full permissions.\n- guest: Guest user with minimal permissions.")
				}
			}
			"""#
		}
	}

	@Test("Generates schema for enum with associated values")
	func enumWithAssociatedValues() {
		assertMacro {
			"""
			/// A model in the API.
			@Schema
			enum Model {
				case gpt4o
				case gpt5
				/// Other models with a string identifier.
				/// - Parameter name: The identifier for the model.
				case other(name: String)
			}
			"""
		} expansion: {
			"""
			/// A model in the API.
			enum Model {
				case gpt4o
				case gpt5
				/// Other models with a string identifier.
				/// - Parameter name: The identifier for the model.
				case other(name: String)
			}

			extension Model: Schemable {
				static var schema: JSONSchema {
					.anyOf(.enum(cases: ["gpt4o", "gpt5"], description: nil), .object(properties: ["other": .object(properties: ["name": .string(description: "The identifier for the model.")])], description: "Other models with a string identifier."), description: "A model in the API.")
				}
			}
			"""
		}
	}

	@Test("Errors when struct contains a property with no concrete type")
	func structWithoutConcreteTypeError() {
		assertMacro {
			"""
			@Schema
			struct User {
				let id = UUID()
			}
			"""
		} diagnostics: {
			"""
			@Schema
			struct User {
				let id = UUID()
			 ┬──────────────
			 ╰─ 🛑 You must provide a type for the property 'id'.
			}
			"""
		}
	}

	@Test("Errors when struct contains a Dictionary")
	func structWithDictionaryError() {
		assertMacro {
			"""
			@Schema
			struct User {
				let id: Int
				let attributes: [String: String]
			}
			"""
		} diagnostics: {
			"""
			@Schema
			struct User {
				let id: Int
				let attributes: [String: String]
			 ┬───────────────────────────────
			 ╰─ 🛑 Dictionaries are not supported when using @Schema. Use a custom struct instead.
			}
			"""
		}
	}

	@Test("Errors when applied to classes")
	func classError() {
		assertMacro {
			"""
			@Schema
			class User {}
			"""
		} diagnostics: {
			"""
			@Schema
			╰─ 🛑 The @Schema macro can only be applied to structs or enums.
			class User {}
			"""
		}
	}
}
