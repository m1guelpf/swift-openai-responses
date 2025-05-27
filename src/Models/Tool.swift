import Foundation
import MetaCodable

/// A tool the model may call while generating a response.
///
/// The two categories of tools you can provide the model are:
/// - **Built-in tools**: Tools that are provided by OpenAI that extend the model's capabilities, like [web search](https://platform.openai.com/docs/guides/tools-web-search) or [file search](https://platform.openai.com/docs/guides/tools-file-search). Learn more about [built-in tools](https://platform.openai.com/docs/guides/tools).
/// - **Function calls (custom tools)**: Functions that are defined by you, enabling the model to call your own code. Learn more about [function calling](https://platform.openai.com/docs/guides/function-calling).
@Codable @CodedAt("type") @CodingKeys(.snake_case) public enum Tool: Equatable, Hashable, Sendable, Codable {
	public enum Choice: Equatable, Hashable, Sendable {
		case none
		case auto
		case required
		case fileSearch
		case webSearchPreview
		case computerUsePreview
		case function(name: String)
	}

	/// Defines a function in your own code the model can choose to call.
	/// - Learn more about [function calling](https://platform.openai.com/docs/guides/function-calling).
	public struct Function: Equatable, Hashable, Codable, Sendable {
		public struct Parameters: Codable, Hashable, Equatable, Sendable {
			public var type: JSONType
			public var properties: [String: Property]?
			public var required: [String]?
			public var pattern: String?
			public var const: String?
			public var `enum`: [String]?
			public var multipleOf: Int?
			public var minimum: Int?
			public var maximum: Int?
			public var additionalProperties: Bool?

			public init(
				type: JSONType,
				properties: [String: Property]? = nil,
				required: [String]? = nil,
				pattern: String? = nil,
				const: String? = nil,
				enum: [String]? = nil,
				multipleOf: Int? = nil,
				minimum: Int? = nil,
				maximum: Int? = nil,
				additionalProperties: Bool? = false
			) {
				self.type = type
				self.enum = `enum`
				self.const = const
				self.pattern = pattern
				self.minimum = minimum
				self.maximum = maximum
				self.required = required
				self.multipleOf = multipleOf
				self.properties = properties
				self.additionalProperties = additionalProperties
			}

			public struct Property: Codable, Hashable, Equatable, Sendable {
				public var type: JSONType
				public var description: String?
				public var format: String?
				public var items: Items?
				public var required: [String]?
				public var pattern: String?
				public var const: String?
				public var `enum`: [String]?
				public var multipleOf: Int?
				public var minimum: Double?
				public var maximum: Double?
				public var minItems: Int?
				public var maxItems: Int?
				public var uniqueItems: Bool?

				public init(
					type: JSONType,
					description: String? = nil,
					format: String? = nil,
					items: Self.Items? = nil,
					required: [String]? = nil,
					pattern: String? = nil,
					const: String? = nil,
					enum: [String]? = nil,
					multipleOf: Int? = nil,
					minimum: Double? = nil,
					maximum: Double? = nil,
					minItems: Int? = nil,
					maxItems: Int? = nil,
					uniqueItems: Bool? = nil
				) {
					self.type = type
					self.description = description
					self.format = format
					self.items = items
					self.required = required
					self.pattern = pattern
					self.const = const
					self.enum = `enum`
					self.multipleOf = multipleOf
					self.minimum = minimum
					self.maximum = maximum
					self.minItems = minItems
					self.maxItems = maxItems
					self.uniqueItems = uniqueItems
				}

				public struct Items: Codable, Equatable, Hashable, Sendable {
					public var type: JSONType
					public var properties: [String: Property]?
					public var pattern: String?
					public var const: String?
					public var `enum`: [String]?
					public var multipleOf: Int?
					public var minimum: Double?
					public var maximum: Double?
					public var minItems: Int?
					public var maxItems: Int?
					public var uniqueItems: Bool?
					public var required: [String]?
					public var additionalProperties: Bool?

					public init(
						type: JSONType,
						properties: [String: Property]? = nil,
						pattern: String? = nil,
						const: String? = nil,
						enum: [String]? = nil,
						multipleOf: Int? = nil,
						minimum: Double? = nil,
						maximum: Double? = nil,
						minItems: Int? = nil,
						maxItems: Int? = nil,
						uniqueItems: Bool? = nil,
						required: [String]? = nil,
						additionalProperties: Bool? = false
					) {
						self.type = type
						self.properties = properties
						self.pattern = pattern
						self.const = const
						self.enum = `enum`
						self.multipleOf = multipleOf
						self.minimum = minimum
						self.maximum = maximum
						self.minItems = minItems
						self.maxItems = maxItems
						self.uniqueItems = uniqueItems
						self.required = required
						self.additionalProperties = additionalProperties
					}
				}
			}

			public enum JSONType: String, Equatable, Hashable, Codable, Sendable {
				case integer
				case string
				case boolean
				case array
				case object
				case number
				case null
			}
		}

		/// The name of the function to call.
		public var name: String

		/// A description of the function. Used by the model to determine whether or not to call the function.
		public var description: String?

		/// A JSON schema object describing the parameters of the function.
		public var parameters: Parameters

		/// Whether to enforce strict parameter validation.
		public var strict: Bool

		/// Create a new `Function` instance.
		///
		/// - Parameter name: The name of the function to call.
		/// - Parameter description: A description of the function. Used by the model to determine whether or not to call the function.
		/// - Parameter parameters: A JSON schema object describing the parameters of the function.
		/// - Parameter strict: Whether to enforce strict parameter validation.
		public init(name: String, description: String? = nil, parameters: Parameters, strict: Bool = true) {
			self.name = name
			self.strict = strict
			self.parameters = parameters
			self.description = description
		}
	}

	/// A tool that searches for relevant content from uploaded files.
	///
	/// Learn more about the [file search tool](https://platform.openai.com/docs/guides/tools-file-search).
	@Codable @CodingKeys(.snake_case) public struct FileSearch: Equatable, Hashable, Sendable, Codable {
		/// A filter to apply based on file attributes.
		@Codable @UnTagged public enum Filters: Equatable, Hashable, Sendable, Codable {
			/// A filter used to compare a specified attribute key to a given value using a defined comparison operation.
			public struct Comparison: Equatable, Hashable, Codable, Sendable {
				/// The value to compare against the attribute key.
				@Codable @UnTagged public enum Value: Equatable, Hashable, Sendable, Codable {
					case bool(Bool)
					case number(Int)
					case string(String)
				}

				/// Specifies the comparison operator.
				public enum ComparisonType: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
					case equals = "eq"
					case NotEqual = "ne"
					case GreaterThan = "gt"
					case GreaterThanOrEqual = "gte"
					case LessThan = "lt"
					case LessThanOrEqual = "lte"
				}

				/// The key to compare against the value.
				public var key: String
				/// Specifies the comparison operator.
				public var type: ComparisonType
				/// The value to compare against the attribute key.
				public var value: Value

				/// Create a new comparison filter.
				///
				/// - Parameter key: The key to compare against the value.
				/// - Parameter type: Specifies the comparison operator.
				/// - Parameter value: The value to compare against the attribute key.
				public init(key: String, type: ComparisonType, value: Value) {
					self.key = key
					self.type = type
					self.value = value
				}
			}

			/// Combine multiple filters using and or or.
			public struct Compound: Equatable, Hashable, Codable, Sendable {
				/// Type of operation.
				public enum CompoundType: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
					case and
					case or
				}

				/// Array of filters to combine.
				public var filters: [Filters]

				/// Type of operation.
				public var type: CompoundType

				/// Create a new compound filter.
				///
				/// - Parameter filters: Array of filters to combine.
				/// - Parameter type: Type of operation.
				public init(filters: [Filters], type: CompoundType) {
					self.type = type
					self.filters = filters
				}
			}

			/// A filter used to compare a specified attribute key to a given value using a defined comparison operation.
			case single(Comparison)
			/// Combine multiple filters using and or or.
			case compound(Compound)
		}

		/// Ranking options for search.
		@Codable @CodingKeys(.snake_case) public struct RankingOptions: Equatable, Hashable, Sendable, Codable {
			/// The ranker to use for the file search.
			public var ranker: String?

			/// The score threshold for the file search, a number between 0 and 1. Numbers closer to 1 will attempt to return only the most relevant results, but may return fewer results.
			public var scoreThreshold: Int?

			/// Create a new `RankingOptions` instance.
			///
			/// - Parameter ranker: The ranker to use for the file search.
			/// - Parameter scoreThreshold: The score threshold for the file search, a number between 0 and 1. Numbers closer to 1 will attempt to return only the most relevant results, but may return fewer results.
			init(ranker: String? = nil, scoreThreshold: Int? = nil) {
				self.ranker = ranker
				self.scoreThreshold = scoreThreshold
			}
		}

		/// The IDs of the vector stores to search.
		public var vectorStoreIds: [String]

		/// A filter to apply based on file attributes.
		public var filters: Filters?

		/// The maximum number of results to return. This number should be between 1 and 50 inclusive.
		public var maxNumResults: UInt?

		/// Ranking options for search.
		public var rankingOptions: RankingOptions?

		/// Create a new `FileSearch` instance.
		///
		/// - Parameter vectorStoreIds: The IDs of the vector stores to search.
		/// - Parameter filters: A filter to apply based on file attributes.
		/// - Parameter maxNumResults: The maximum number of results to return. This number should be between 1 and 50 inclusive.
		/// - Parameter rankingOptions: Ranking options for search.
		public init(vectorStoreIds: [String], filters: Filters? = nil, maxNumResults: UInt? = nil, rankingOptions: RankingOptions? = nil) {
			self.vectorStoreIds = vectorStoreIds
			self.filters = filters
			self.maxNumResults = maxNumResults
			self.rankingOptions = rankingOptions
		}
	}

	/// A tool that controls a virtual computer.
	///
	/// Learn more about the [computer tool](https://platform.openai.com/docs/guides/tools-computer-use).
	@Codable @CodingKeys(.snake_case) public struct ComputerUse: Equatable, Hashable, Sendable {
		/// The type of computer environment to control.
		public enum Environment: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
			case mac
			case ubuntu
			case browser
			case windows
		}

		/// The height of the computer display.
		public var displayHeight: UInt

		/// The width of the computer display.
		public var displayWidth: UInt

		/// The type of computer environment to control.
		public var environment: Environment

		/// Create a new `ComputerUse` instance.
		///
		/// - Parameter displayHeight: The height of the computer display.
		/// - Parameter displayWidth: The width of the computer display.
		/// - Parameter environment: The type of computer environment to control.
		public init(displayHeight: UInt, displayWidth: UInt, environment: Environment) {
			self.environment = environment
			self.displayWidth = displayWidth
			self.displayHeight = displayHeight
		}
	}

	/// This tool searches the web for relevant results to use in a response.
	///
	/// Learn more about the [web search tool](https://platform.openai.com/docs/guides/tools-web-search?api-mode=responses).
	@Codable @CodingKeys(.snake_case) public struct WebSearch: Equatable, Hashable, Sendable, Codable {
		/// High level guidance for the amount of context window space to use for the search.
		public enum ContextSize: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
			case low
			case high
			case medium
		}

		/// Approximate location parameters for the search.
		public struct UserLocation: Equatable, Hashable, Codable, Sendable {
			/// The type of location approximation
			public enum LocationType: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
				case approximate
			}

			/// The type of location approximation
			public var type: LocationType

			/// Free text input for the city of the user, e.g. `San Francisco`.
			public var city: String?

			/// The two-letter [ISO country code](https://en.wikipedia.org/wiki/ISO_3166-1) of the user, e.g. `US`.
			public var country: String?

			/// Free text input for the region of the user, e.g. `California`.
			public var region: String?

			/// The [IANA timezone](https://timeapi.io/documentation/iana-timezones) of the user, e.g. `America/Los_Angeles`.
			public var timezone: String?

			/// Create a new `UserLocation` instance.
			///
			/// - Parameter type: The type of location approximation
			/// - Parameter city: Free text input for the city of the user, e.g. `San Francisco`.
			/// - Parameter country: The two-letter [ISO country code](https://en.wikipedia.org/wiki/ISO_3166-1) of the user, e.g. `US`.
			/// - Parameter region: Free text input for the region of the user, e.g. `California`.
			/// - Parameter timezone: The [IANA timezone](https://timeapi.io/documentation/iana-timezones) of the user, e.g. `America/Los_Angeles`.
			public init(type: LocationType = .approximate, city: String? = nil, country: String? = nil, region: String? = nil, timezone: String? = nil) {
				self.type = type
				self.city = city
				self.country = country
				self.region = region
				self.timezone = timezone
			}
		}

		/// High level guidance for the amount of context window space to use for the search.
		public var searchContextSize: ContextSize

		/// Approximate location parameters for the search.
		public var userLocation: UserLocation?

		/// Create a new `WebSearch` instance.
		///
		/// - Parameter searchContextSize: High level guidance for the amount of context window space to use for the search.
		/// - Parameter userLocation: Approximate location parameters for the search.
		public init(searchContextSize: ContextSize = .medium, userLocation: UserLocation? = nil) {
			self.userLocation = userLocation
			self.searchContextSize = searchContextSize
		}
	}

	/// Defines a function in your own code the model can choose to call.
	/// - Learn more about [function calling](https://platform.openai.com/docs/guides/function-calling).
	case function(Function)

	/// A tool that searches for relevant content from uploaded files.
	///
	/// Learn more about the [file search tool](https://platform.openai.com/docs/guides/tools-file-search).
	@CodedAs("file_search")
	case fileSearch(FileSearch)

	/// A tool that controls a virtual computer.
	///
	/// Learn more about the [computer tool](https://platform.openai.com/docs/guides/tools-computer-use).
	@CodedAs("computer_use_preview")
	case computerUse(ComputerUse)

	/// This tool searches the web for relevant results to use in a response.
	///
	/// Learn more about the [web search tool](https://platform.openai.com/docs/guides/tools-web-search?api-mode=responses).
	@CodedAs("web_search_preview")
	case webSearch(WebSearch)
}

public extension Tool {
	/// Defines a function in your own code the model can choose to call.
	/// - Learn more about [function calling](https://platform.openai.com/docs/guides/function-calling).
	/// - Parameter name: The name of the function to call.
	/// - Parameter description: A description of the function. Used by the model to determine whether or not to call the function.
	/// - Parameter parameters: A JSON schema object describing the parameters of the function.
	/// - Parameter strict: Whether to enforce strict parameter validation.
	static func function(name: String, description: String? = nil, parameters: Function.Parameters, strict: Bool = true) -> Self {
		.function(Function(name: name, description: description, parameters: parameters, strict: strict))
	}

	/// A tool that searches for relevant content from uploaded files.
	///
	/// Learn more about the [file search tool](https://platform.openai.com/docs/guides/tools-file-search).
	/// - Parameter vectorStoreIds: The IDs of the vector stores to search.
	/// - Parameter filters: A filter to apply based on file attributes.
	/// - Parameter maxNumResults: The maximum number of results to return. This number should be between 1 and 50 inclusive.
	/// - Parameter rankingOptions: Ranking options for search.
	static func fileSearch(vectorStoreIds: [String], filters: FileSearch.Filters, maxNumResults: UInt, rankingOptions: FileSearch.RankingOptions) -> Self {
		.fileSearch(FileSearch(vectorStoreIds: vectorStoreIds, filters: filters, maxNumResults: maxNumResults, rankingOptions: rankingOptions))
	}

	/// A tool that controls a virtual computer.
	///
	/// Learn more about the [computer tool](https://platform.openai.com/docs/guides/tools-computer-use).
	/// - Parameter displayHeight: The height of the computer display.
	/// - Parameter displayWidth: The width of the computer display.
	/// - Parameter environment: The type of computer environment to control.
	static func computerUse(displayHeight: UInt, displayWidth: UInt, environment: ComputerUse.Environment) -> Self {
		.computerUse(ComputerUse(displayHeight: displayHeight, displayWidth: displayWidth, environment: environment))
	}

	/// This tool searches the web for relevant results to use in a response.
	///
	/// Learn more about the [web search tool](https://platform.openai.com/docs/guides/tools-web-search?api-mode=responses).
	/// - Parameter contextSize: High level guidance for the amount of context window space to use for the search.
	/// - Parameter userLocation: Approximate location parameters for the search.
	static func webSearch(contextSize: WebSearch.ContextSize = .medium, userLocation: WebSearch.UserLocation? = nil) -> Self {
		.webSearch(WebSearch(searchContextSize: contextSize, userLocation: userLocation))
	}
}

public extension Tool.FileSearch.Filters {
	/// Create a new comparison filter.
	///
	/// - Parameter key: The key to compare against the value.
	/// - Parameter type: Specifies the comparison operator.
	/// - Parameter value: The value to compare against the attribute key.
	static func single(key: String, type: Comparison.ComparisonType, value: Comparison.Value) -> Self {
		.single(Comparison(key: key, type: type, value: value))
	}

	/// Create a new compound filter.
	///
	/// - Parameter filters: Array of filters to combine.
	/// - Parameter type: Type of operation.
	static func compound(filters: [Self], type: Compound.CompoundType) -> Self {
		.compound(Compound(filters: filters, type: type))
	}
}

extension Tool.Choice: Codable {
	enum CodingKeys: String, CodingKey {
		case type
		case name
	}

	public func encode(to encoder: any Encoder) throws {
		switch self {
			case .none: try "none".encode(to: encoder)
			case .auto: try "auto".encode(to: encoder)
			case .required: try "required".encode(to: encoder)
			case .fileSearch:
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("file_search", forKey: .type)
			case .webSearchPreview:
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("web_search_preview", forKey: .type)
			case .computerUsePreview:
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("computer_use_preview", forKey: .type)
			case let .function(name):
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("function", forKey: .type)
				try container.encode(name, forKey: .name)
		}
	}

	public init(from decoder: any Decoder) throws {
		if let string = try? String(from: decoder) {
			switch string {
				case "none": self = .none
				case "auto": self = .auto
				case "required": self = .required
				default: throw DecodingError.dataCorrupted(DecodingError.Context(
						codingPath: decoder.codingPath,
						debugDescription: "Invalid tool choice: \(string)"
					))
			}
			return
		}

		let container = try decoder.container(keyedBy: CodingKeys.self)
		let type = try container.decode(String.self, forKey: .type)

		switch type {
			case "file_search": self = .fileSearch
			case "web_search_preview": self = .webSearchPreview
			case "computer_use_preview": self = .computerUsePreview
			case "function":
				let name = try container.decode(String.self, forKey: .name)
				self = .function(name: name)
			default:
				throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid tool choice: \(type)")
		}
	}
}
