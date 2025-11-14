import Foundation
import MetaCodable

/// A tool the model may call while generating a response.
///
/// The two categories of tools you can provide the model are:
/// - **Built-in tools**: Tools that are provided by OpenAI that extend the model's capabilities, like [web search](https://platform.openai.com/docs/guides/tools-web-search) or [file search](https://platform.openai.com/docs/guides/tools-file-search). Learn more about [built-in tools](https://platform.openai.com/docs/guides/tools).
/// - **Function calls (custom tools)**: Functions that are defined by you, enabling the model to call your own code. Learn more about [function calling](https://platform.openai.com/docs/guides/function-calling).
@Codable @CodedAt("type") @CodingKeys(.snake_case) public enum Tool: Equatable, Hashable, Sendable {
	public enum Choice: Equatable, Hashable, Sendable {
		public enum MultiToolMode: String, Equatable, Hashable, Codable, Sendable {
			/// Allows the model to pick from among the allowed tools and generate a message.
			case auto

			/// Requires the model to call one or more of the allowed tools.
			case required
		}

		/// The model will not call any tool and instead generates a message.
		case none

		/// The model can pick between generating a message or calling one or more tools.
		case auto

		/// The model must call one or more tools.
		case required

		/// Constrains the tools available to the model to a pre-defined set.
		///
		/// - Parameter tools: A list of tool definitions that the model should be allowed to call.
		/// - Parameter mode: How the model should use the tools.
		case some(tools: [Choice], mode: MultiToolMode)

		case shell
		case fileSearch
		case applyPatch
		case imageGeneration
		case codeInterpreter
		case webSearchPreview
		case computerUsePreview

		/// Force the model to call a specific function.
		///
		/// - Parameter name: The name of the function to call.
		case function(name: String)

		/// Force the model to call a specific tool on a remote MCP server.
		///
		/// - Parameter server: The label of the MCP server to use.
		/// - Parameter name: The name of the tool to call on the server.
		case mcp(server: String, name: String? = nil)

		/// Force the model to call a specific custom tool.
		///
		/// - Parameter name: The name of the custom tool to call.
		case custom(name: String)
	}

	/// Defines a function in your own code the model can choose to call.
	/// - Learn more about [function calling](https://platform.openai.com/docs/guides/function-calling).
	public struct Function: Equatable, Hashable, Codable, Sendable {
		/// The name of the function to call.
		public var name: String

		/// A description of the function. Used by the model to determine whether or not to call the function.
		public var description: String?

		/// A JSON schema object describing the parameters of the function.
		public var parameters: JSONSchema

		/// Whether to enforce strict parameter validation.
		public var strict: Bool

		/// Create a new `Function` instance.
		///
		/// - Parameter name: The name of the function to call.
		/// - Parameter description: A description of the function. Used by the model to determine whether or not to call the function.
		/// - Parameter parameters: A JSON schema object describing the parameters of the function.
		/// - Parameter strict: Whether to enforce strict parameter validation.
		public init(name: String, description: String? = nil, parameters: JSONSchema, strict: Bool = true) {
			self.name = name
			self.strict = strict
			self.parameters = parameters
			self.description = description
		}
	}

	/// A tool that searches for relevant content from uploaded files.
	///
	/// Learn more about the [file search tool](https://platform.openai.com/docs/guides/tools-file-search).
	@Codable @CodingKeys(.snake_case) public struct FileSearch: Equatable, Hashable, Sendable {
		/// A filter to apply based on file attributes.
		@Codable @UnTagged public enum Filters: Equatable, Hashable, Sendable {
			/// A filter used to compare a specified attribute key to a given value using a defined comparison operation.
			public struct Comparison: Equatable, Hashable, Codable, Sendable {
				/// The value to compare against the attribute key.
				@Codable @UnTagged public enum Value: Equatable, Hashable, Sendable {
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
		@Codable @CodingKeys(.snake_case) public struct RankingOptions: Equatable, Hashable, Sendable {
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
	@Codable @CodingKeys(.snake_case) public struct WebSearch: Equatable, Hashable, Sendable {
		/// High level guidance for the amount of context window space to use for the search.
		public enum ContextSize: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
			case low
			case high
			case medium
		}

		@Codable @CodingKeys(.snake_case) public struct Filters: Equatable, Hashable, Sendable {
			/// Allowed domains for the search.
			///
			/// Subdomains of the provided domains are allowed as well.
			public var allowedDomains: [String]

			/// Create a new `Filters` instance.
			///
			/// - Parameter allowedDomains: Allowed domains for the search.
			public init(allowedDomains: [String]) {
				self.allowedDomains = allowedDomains
			}

			public static func allowedDomains(_ domains: [String]) -> Filters {
				return Filters(allowedDomains: domains)
			}
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

		/// A filter defining allowed domains for the search.
		///
		/// If not provided, all domains are allowed.
		public var filters: Filters?

		/// Create a new `WebSearch` instance.
		///
		/// - Parameter searchContextSize: High level guidance for the amount of context window space to use for the search.
		/// - Parameter userLocation: Approximate location parameters for the search.
		/// - Parameter filters: A filter defining allowed domains for the search.
		public init(searchContextSize: ContextSize = .medium, userLocation: UserLocation? = nil, filters: Filters? = nil) {
			self.filters = filters
			self.userLocation = userLocation
			self.searchContextSize = searchContextSize
		}
	}

	@Codable @CodingKeys(.snake_case) public struct MCP: Equatable, Hashable, Sendable {
		public enum Connector: String, Equatable, Hashable, Codable, Sendable {
			case gmail = "connector_gmail"
			case dropbox = "connector_dropbox"
			case sharepoint = "connector_sharepoint"
			case googleDrive = "connector_googledrive"
			case outlookEmail = "connector_outlookemail"
			case googleCalendar = "connector_googlecalendar"
			case microsoftTeams = "connector_microsoftteams"
			case outlookCalendar = "connector_outlookcalendar"
		}

		public enum RequireApproval: Equatable, Hashable, Sendable {
			/// Approval policies for MCP tools.
			public enum Approval: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
				case always
				case never
			}

			/// Specify a single approval policy for all tools
			case all(Approval)

			/// Set approval requirements for specific tools on this MCP server.
			///
			/// - Parameter always: Tools that always require approval.
			/// - Parameter never: Tools that never require approval.
			case granular(always: [String]? = nil, never: [String]? = nil)
		}

		/// A label for this MCP server, used to identify it in tool calls.
		@CodedAt("server_label") public var label: String

		/// The URL for the MCP server.
		@CodedAt("server_url") public var url: URL?

		/// Identifier for service connectors, like those available in ChatGPT.
		///
		/// Learn more about service connectors [here](https://platform.openai.com/docs/guides/tools-remote-mcp#connectors).
		@CodedAt("connector_id") public var connector: Connector?

		/// An OAuth access token that can be used with a remote MCP server, either with a custom MCP server URL or a service connector.
		///
		/// Your application must handle the OAuth authorization flow and provide the token here.
		public var authorization: String?

		/// List of allowed tool names.
		public var allowedTools: [String]?

		/// Optional HTTP headers to send to the MCP server.
		///
		/// Use for authentication or other purposes.
		public var headers: [String: String]?

		/// Specify which of the MCP server's tools require approval.
		public var requireApproval: RequireApproval?

		/// Optional description of the MCP server, used to provide more context.
		@CodedAt("server_description") public var description: String?

		/// Create a new `MCP` instance for a remote MCP server.
		///
		/// - Parameter label: A label for this MCP server, used to identify it in tool calls.
		/// - Parameter url: The URL for the MCP server.
		/// - Parameter authorization: An OAuth access token that can be used with a remote MCP server.
		/// - Parameter allowedTools: List of allowed tool names.
		/// - Parameter headers: Optional HTTP headers to send to the MCP server.
		/// - Parameter requireApproval: Specify which of the MCP server's tools require approval.
		/// - Parameter description: Optional description of the MCP server, used to provide more context.
		public init(label: String, url: URL, authorization: String? = nil, allowedTools: [String]? = nil, headers: [String: String]? = nil, requireApproval: RequireApproval? = nil, description: String? = nil) {
			self.url = url
			self.label = label
			self.headers = headers
			self.description = description
			self.allowedTools = allowedTools
			self.authorization = authorization
			self.requireApproval = requireApproval
		}

		/// Create a new `MCP` instance for a service connector.
		///
		/// - Parameter label: A label for this MCP server, used to identify it in tool calls.
		/// - Parameter connector: Identifier for service connectors, like those available in ChatGPT.
		/// - Parameter authorization: An OAuth access token that can be used with the connector.
		/// - Parameter allowedTools: List of allowed tool names.
		/// - Parameter headers: Optional HTTP headers to send to the MCP server.
		/// - Parameter requireApproval: Specify which of the MCP server's tools require approval.
		/// - Parameter description: Optional description of the MCP server, used to provide more context.
		public init(label: String, connector: Connector, authorization: String, allowedTools: [String]? = nil, headers: [String: String]? = nil, requireApproval: RequireApproval? = nil, description: String? = nil) {
			self.label = label
			self.headers = headers
			self.connector = connector
			self.description = description
			self.allowedTools = allowedTools
			self.authorization = authorization
			self.requireApproval = requireApproval
		}
	}

	public struct CodeInterpreter: Equatable, Hashable, Codable, Sendable {
		public enum Container: Equatable, Hashable, Sendable {
			/// The container ID.
			case id(String)

			/// Configuration for a code interpreter container.
			///
			/// - Parameter fileIds: An optional list of uploaded files to make available to your code.
			case auto(fileIds: [String]? = nil)

			public static let auto = Container.auto(fileIds: nil)
		}

		/// The code interpreter container.
		public var container: Container

		public init(container: Container = .auto) {
			self.container = container
		}
	}

	/// A tool that generates images.
	@Codable @CodingKeys(.snake_case) public struct ImageGeneration: Equatable, Hashable, Sendable {
		/// Background type for the generated image.
		public enum Background: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
			case transparent, opaque, auto
		}

		/// Control how much effort the model will exert to match the style and features, especially facial features, of input images.
		public enum InputFidelity: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
			case low, high
		}

		/// Optional mask for inpainting.
		public enum ImageMask: Equatable, Hashable, Sendable {
			case image(Data)
			case file(id: String)
		}

		/// The output format of the generated image.
		public enum Format: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
			case png, webp, jpeg
		}

		/// The quality of the generated image.
		public enum Quality: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
			case low, medium, high, auto
		}

		/// The aspect ratio of the generated image.
		public enum AspectRatio: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
			case auto
			case square = "1024x1024"
			case landscape = "1024x1536"
			case portrait = "1536x1024"
		}

		/// Background type for the generated image.
		public var background: Background?

		/// Control how much effort the model will exert to match the style and features, especially facial features, of input images.
		///
		/// Unsupported for `gptImageMini`.
		public var inputFidelity: InputFidelity?

		/// Optional mask for inpainting.
		@CodedAt("input_image_mask") public var imageMask: ImageMask?

		/// The image generation model to use.
		public var model: Model.Image?

		/// Moderation level for the generated image.
		public var moderation: String?

		/// Compression level for the output image.
		///
		/// Defaults to `100` (no compression).
		@CodedAt("output_compression") public var compression: UInt?

		/// The output format of the generated image.
		///
		/// Defaults to `png`.
		@CodedAt("output_format") public var format: Format?

		/// Number of partial images to generate in streaming mode, from 0 (default value) to 3.
		public var partialImages: UInt?

		/// The quality of the generated image.
		public var quality: Quality?

		/// The aspect ratio of the generated image.
		@CodedAt("size") public var aspectRatio: AspectRatio?

		/// Create a new `ImageGeneration` instance.
		///
		/// - Parameter background: Background type for the generated image.
		/// - Parameter inputFidelity: Control how much effort the model will exert to match the style and features, especially facial features, of input images.
		/// - Parameter imageMask: Optional mask for inpainting.
		/// - Parameter model: The image generation model to use.
		/// - Parameter moderation: Moderation level for the generated image.
		/// - Parameter compression: Compression level for the output image.
		/// - Parameter format: The output format of the generated image.
		/// - Parameter partialImages: Number of partial images to generate in streaming mode, from 0 (default value) to 3.
		/// - Parameter quality: The quality of the generated image.
		/// - Parameter aspectRatio: The aspect ratio of the generated image.
		public init(
			background: Background? = nil,
			inputFidelity: InputFidelity? = nil,
			imageMask: ImageMask? = nil,
			model: Model.Image? = nil,
			moderation: String? = nil,
			compression: UInt? = nil,
			format: Format? = nil,
			partialImages: UInt? = nil,
			quality: Quality? = nil,
			aspectRatio: AspectRatio? = nil
		) {
			self.model = model
			self.format = format
			self.quality = quality
			self.imageMask = imageMask
			self.moderation = moderation
			self.background = background
			self.aspectRatio = aspectRatio
			self.compression = compression
			self.partialImages = partialImages
			self.inputFidelity = inputFidelity
		}
	}

	/// A custom tool that processes input using a specified format.
	///
	/// - Learn more about [custom tools](https://platform.openai.com/docs/guides/function-calling#custom-tools).
	@Codable @CodingKeys(.snake_case) public struct Custom: Equatable, Hashable, Sendable {
		/// A grammar defined by the user.
		@Codable @CodedAt("type") public enum Format: Equatable, Hashable, Sendable {
			/// The syntax of the grammar definition.
			public enum Syntax: String, Equatable, Hashable, Codable, Sendable {
				case lark, regex
			}

			/// Unconstrained free-form text.
			case text

			/// A grammar defined by the user.
			///
			/// - Parameter definition: The grammar definition.
			/// - Parameter syntax: The syntax of the grammar definition.
			case grammar(
				definition: String,
				syntax: Syntax
			)
		}

		/// The name of the custom tool, used to identify it in tool calls.
		public var name: String

		/// Optional description of the custom tool, used to provide more context.
		public var description: String?

		/// The input format for the custom tool.
		public var format: Format?

		/// Create a new custom tool.
		///
		/// - Parameter name: The name of the custom tool, used to identify it in tool calls.
		/// - Parameter description: Optional description of the custom tool, used to provide more context.
		/// - Parameter format: The input format for the custom tool.
		public init(name: String, description: String? = nil, format: Format? = nil) {
			self.name = name
			self.format = format
			self.description = description
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
	@CodedAs("web_search")
	case webSearch(WebSearch)

	/// Give the model access to additional tools via remote Model Context Protocol (MCP) servers.
	///
	/// Learn more about [MCP](https://platform.openai.com/docs/guides/tools-remote-mcp).
	case mcp(MCP)

	/// A tool that runs Python code to help generate a response to a prompt.
	///
	/// Learn more about the [code interpreter tool](https://platform.openai.com/docs/guides/tools-code-interpreter).
	@CodedAs("code_interpreter")
	case codeInterpreter(CodeInterpreter)

	/// A tool that generates images
	///
	/// Learn more about the [image generation tool](https://platform.openai.com/docs/guides/tools-image-generation).
	@CodedAs("image_generation")
	case imageGeneration(ImageGeneration)

	/// A tool that allows the model to execute shell commands in a local environment.
	///
	/// Learn more about the [local shell tool](https://platform.openai.com/docs/guides/tools-local-shell).
	@CodedAs("local_shell")
	case localShell

	/// A tool that allows the model to execute shell commands.
	case shell

	/// Allows the assistant to create, delete, or update files using unified diffs.
	@CodedAs("apply_patch")
	case applyPatch

	/// A custom tool that processes input using a specified format.
	///
	/// Learn more about [custom tools](https://platform.openai.com/docs/guides/function-calling#custom-tools).
	case custom(Custom)
}

public extension Tool {
	/// Defines a function in your own code the model can choose to call.
	/// - Learn more about [function calling](https://platform.openai.com/docs/guides/function-calling).
	/// - Parameter name: The name of the function to call.
	/// - Parameter description: A description of the function. Used by the model to determine whether or not to call the function.
	/// - Parameter parameters: A JSON schema object describing the parameters of the function.
	/// - Parameter strict: Whether to enforce strict parameter validation.
	static func function(name: String, description: String? = nil, parameters: JSONSchema, strict: Bool = true) -> Self {
		.function(Function(name: name, description: description, parameters: parameters, strict: strict))
	}

	/// Defines a function in your own code the model can choose to call.
	/// - Learn more about [function calling](https://platform.openai.com/docs/guides/function-calling).
	/// - Parameter name: The name of the function to call.
	/// - Parameter description: A description of the function. Used by the model to determine whether or not to call the function.
	/// - Parameter parameters: A JSON schema object describing the parameters of the function.
	/// - Parameter strict: Whether to enforce strict parameter validation.
	static func function<T: Schemable>(name: String, description: String? = nil, parameters _: T.Type, strict: Bool = true) -> Self {
		.function(Function(name: name, description: description, parameters: T.schema, strict: strict))
	}

	/// Defines a function in your own code the model can choose to call.
	/// - Learn more about [function calling](https://platform.openai.com/docs/guides/function-calling).
	/// - Parameter tool: A description of a tool to use, implementing the `Toolable` protocol.
	///
	/// > Note: When using the `ResponsesAPI` client, you are still responsible for calling the code and returning a response.
	/// > If you want this to be handled for you, use the `Conversation` class instead.
	static func function<Tool: Toolable>(_ tool: Tool) -> Self {
		return .function(tool.intoFunction())
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
	/// - Parameter filters: A filter defining allowed domains for the search.
	static func webSearch(contextSize: WebSearch.ContextSize = .medium, userLocation: WebSearch.UserLocation? = nil, filters: WebSearch.Filters? = nil) -> Self {
		.webSearch(WebSearch(searchContextSize: contextSize, userLocation: userLocation, filters: filters))
	}

	// Give the model access to additional tools via remote Model Context Protocol (MCP) servers.
	///
	/// Learn more about [MCP](https://platform.openai.com/docs/guides/tools-remote-mcp).
	/// - Parameter label: A label for this MCP server, used to identify it in tool calls.
	/// - Parameter url: The URL for the MCP server.
	/// - Parameter authorization: An OAuth access token that can be used with a remote MCP server.
	/// - Parameter allowedTools: List of allowed tool names.
	/// - Parameter headers: Optional HTTP headers to send to the MCP server.
	/// - Parameter requireApproval: Specify which of the MCP server's tools require approval.
	/// - Parameter description: Optional description of the MCP server, used to provide more context.
	static func mcp(label: String, url: URL, authorization: String? = nil, allowedTools: [String]? = nil, headers: [String: String]? = nil, requireApproval: MCP.RequireApproval? = nil, description: String? = nil) -> Self {
		.mcp(MCP(label: label, url: url, authorization: authorization, allowedTools: allowedTools, headers: headers, requireApproval: requireApproval, description: description))
	}

	// Give the model access to additional tools using MCP-powered connectors.
	///
	/// Learn more about [MCP](https://platform.openai.com/docs/guides/tools-remote-mcp).
	/// - Parameter label: A label for this MCP server, used to identify it in tool calls.
	/// - Parameter connector: Identifier for service connectors, like those available in ChatGPT.
	/// - Parameter authorization: An OAuth access token that can be used with the connector.
	/// - Parameter allowedTools: List of allowed tool names.
	/// - Parameter headers: Optional HTTP headers to send to the MCP server.
	/// - Parameter requireApproval: Specify which of the MCP server's tools require approval.
	/// - Parameter description: Optional description of the MCP server, used to provide more context.
	static func mcp(label: String, connector: MCP.Connector, authorization: String, allowedTools: [String]? = nil, headers: [String: String]? = nil, requireApproval: MCP.RequireApproval? = nil, description: String? = nil) -> Self {
		.mcp(MCP(label: label, connector: connector, authorization: authorization, allowedTools: allowedTools, headers: headers, requireApproval: requireApproval, description: description))
	}

	/// A tool that runs Python code to help generate a response to a prompt.
	///
	/// Learn more about the [code interpreter tool](https://platform.openai.com/docs/guides/tools-code-interpreter).
	/// - Parameter container: The code interpreter container.
	static func codeInterpreter(container: CodeInterpreter.Container) -> Self {
		.codeInterpreter(CodeInterpreter(container: container))
	}

	/// A tool that generates images
	///
	/// Learn more about the [image generation tool](https://platform.openai.com/docs/guides/tools-image-generation).
	/// - Parameter background: Background type for the generated image.
	/// - Parameter inputFidelity: Control how much effort the model will exert to match the style and features, especially facial features, of input images.
	/// - Parameter imageMask: Optional mask for inpainting.
	/// - Parameter model: The image generation model to use.
	/// - Parameter moderation: Moderation level for the generated image.
	/// - Parameter compression: Compression level for the output image.
	/// - Parameter format: The output format of the generated image.
	/// - Parameter partialImages: Number of partial images to generate in streaming mode, from 0 (default value) to 3.
	/// - Parameter quality: The quality of the generated image.
	/// - Parameter aspectRatio: The aspect ratio of the generated image.
	static func imageGeneration(
		background: ImageGeneration.Background? = nil,
		inputFidelity: ImageGeneration.InputFidelity? = nil,
		imageMask: ImageGeneration.ImageMask? = nil,
		model: Model.Image? = nil,
		moderation: String? = nil,
		compression: UInt? = nil,
		format: ImageGeneration.Format? = nil,
		partialImages: UInt? = nil,
		quality: ImageGeneration.Quality? = nil,
		aspectRatio: ImageGeneration.AspectRatio? = nil
	) -> Self {
		.imageGeneration(ImageGeneration(background: background, inputFidelity: inputFidelity, imageMask: imageMask, model: model, moderation: moderation, compression: compression, format: format, partialImages: partialImages, quality: quality, aspectRatio: aspectRatio))
	}

	/// A custom tool that processes input using a specified format.
	///
	/// Learn more about [custom tools](https://platform.openai.com/docs/guides/function-calling#custom-tools).
	/// - Parameter name: The name of the custom tool, used to identify it in tool calls.
	/// - Parameter description: Optional description of the custom tool, used to provide more context.
	/// - Parameter format: The input format for the custom tool.
	static func custom(name: String, description: String? = nil, format: Custom.Format? = nil) -> Self {
		.custom(Custom(name: name, description: description, format: format))
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
		case mode
		case tools
		case serverLabel = "server_label"
	}

	public func encode(to encoder: any Encoder) throws {
		switch self {
			case .none: try "none".encode(to: encoder)
			case .auto: try "auto".encode(to: encoder)
			case .required: try "required".encode(to: encoder)
			case let .some(tools, mode):
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("allowed_tools", forKey: .type)
				try container.encode(tools, forKey: .tools)
				try container.encode(mode, forKey: .mode)
			case .fileSearch:
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("file_search", forKey: .type)
			case .webSearchPreview:
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("web_search_preview", forKey: .type)
			case .computerUsePreview:
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("computer_use_preview", forKey: .type)
			case .imageGeneration:
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("image_generation", forKey: .type)
			case .codeInterpreter:
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("code_interpreter", forKey: .type)
			case let .function(name):
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("function", forKey: .type)
				try container.encode(name, forKey: .name)
			case let .custom(name):
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("custom", forKey: .type)
				try container.encode(name, forKey: .name)
			case let .mcp(server, name):
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("mcp", forKey: .type)
				try container.encode(server, forKey: .serverLabel)
				if let name { try container.encode(name, forKey: .name) }
			case .shell:
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("shell", forKey: .type)
			case .applyPatch:
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("apply_patch", forKey: .type)
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
			case "shell": self = .shell
			case "file_search": self = .fileSearch
			case "apply_patch": self = .applyPatch
			case "code_interpreter": self = .codeInterpreter
			case "image_generation": self = .imageGeneration
			case "web_search_preview": self = .webSearchPreview
			case "computer_use_preview": self = .computerUsePreview
			case "function":
				let name = try container.decode(String.self, forKey: .name)
				self = .function(name: name)
			case "mcp":
				let server = try container.decode(String.self, forKey: .serverLabel)
				let tool = try container.decodeIfPresent(String.self, forKey: .name)
				self = .mcp(server: server, name: tool)
			case "custom":
				let name = try container.decode(String.self, forKey: .name)
				self = .custom(name: name)
			case "allowed_tools":
				let tools = try container.decode([Tool.Choice].self, forKey: .tools)
				let mode = try container.decode(Tool.Choice.MultiToolMode.self, forKey: .mode)
				self = .some(tools: tools, mode: mode)
			default:
				throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid tool choice: \(type)")
		}
	}
}

extension Tool.MCP.RequireApproval: Codable {
	static let never = Self.all(.never)
	static let always = Self.all(.always)

	private enum CodingKeys: String, CodingKey {
		case always, never
	}

	private struct ToolList: Codable {
		var tool_names: [String]
	}

	public func encode(to encoder: any Encoder) throws {
		switch self {
			case let .all(approval):
				var container = encoder.singleValueContainer()
				try container.encode(approval.rawValue)
			case let .granular(always, never):
				var container = encoder.container(keyedBy: CodingKeys.self)
				if let always {
					try container.encode(ToolList(tool_names: always), forKey: .always)
				}
				if let never {
					try container.encode(ToolList(tool_names: never), forKey: .never)
				}
		}
	}

	public init(from decoder: any Decoder) throws {
		if let approval = try? Approval(from: decoder) {
			self = .all(approval)
			return
		}

		let container = try decoder.container(keyedBy: CodingKeys.self)
		self = try .granular(
			always: container.decode(ToolList?.self, forKey: .always)?.tool_names,
			never: container.decode(ToolList?.self, forKey: .never)?.tool_names
		)
	}
}

extension Tool.CodeInterpreter.Container: Codable {
	private enum CodingKeys: String, CodingKey {
		case type
		case fileIds = "file_ids"
	}

	public func encode(to encoder: any Encoder) throws {
		switch self {
			case let .id(id):
				var container = encoder.singleValueContainer()
				try container.encode(id)
			case let .auto(fileIds):
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("auto", forKey: .type)
				try container.encode(fileIds, forKey: .fileIds)
		}
	}

	public init(from decoder: any Decoder) throws {
		if let id = try? String(from: decoder) {
			self = .id(id)
			return
		}

		let container = try decoder.container(keyedBy: CodingKeys.self)

		let type = try container.decode(String.self, forKey: .type)

		guard type == "auto" else {
			throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid code interpreter container type: \(type)")
		}

		self = try .auto(fileIds: container.decodeIfPresent([String].self, forKey: .fileIds))
	}
}

extension Tool.ImageGeneration.ImageMask: Codable {
	private enum CodingKeys: String, CodingKey {
		case fileId = "file_id"
		case imageUrl = "image_url"
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		switch self {
			case let .file(id: fileId):
				try container.encode(fileId, forKey: .fileId)
			case let .image(data):
				try container.encode(data.base64EncodedString(), forKey: .imageUrl)
		}
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		if let fileId = try? container.decode(String.self, forKey: .fileId) {
			self = .file(id: fileId)
			return
		}

		if let imageUrl = try? container.decode(String.self, forKey: .imageUrl), let data = Data(base64Encoded: imageUrl) {
			self = .image(data)
			return
		}

		throw DecodingError.dataCorruptedError(forKey: .fileId, in: container, debugDescription: "Invalid image mask format")
	}
}
