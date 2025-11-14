import Foundation
import MetaCodable
import HelperCoders

/// A response from the OpenAI Responses API
@Codable @CodingKeys(.snake_case) public struct Response: Identifiable, Equatable, Hashable, Sendable {
	/// An error object returned when the model fails to generate a Response.
	public struct Error: Equatable, Hashable, Codable {
		/// The type of error.
		public var type: String

		/// A human-readable description of the error.
		public var message: String

		/// The error code for the response.
		public var code: String?

		/// The parameter that caused the error.
		public var param: String?

		/// Create a new `Error` instance.
		///
		/// - Parameter type: The type of error
		/// - Parameter message: A human-readable description of the error
		/// - Parameter code: The error code for the response
		/// - Parameter param: The parameter that caused the error
		public init(type: String, message: String, code: String? = nil, param: String? = nil) {
			self.type = type
			self.code = code
			self.param = param
			self.message = message
		}
	}

	/// Details about why a response is incomplete.
	public struct IncompleteDetails: Equatable, Codable, Hashable, Sendable {
		/// The reason why the response is incomplete.
		public var reason: String

		/// Create a new `IncompleteDetails` instance.
		///
		/// - Parameter reason: The reason why the response is incomplete
		public init(reason: String) {
			self.reason = reason
		}
	}

	/// The status of the response generation.
	public enum Status: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
		case failed
		case queued
		case completed
		case cancelled
		case incomplete
		case inProgress = "in_progress"
	}

	/// Represents token usage details including input tokens, output tokens, a breakdown of output tokens, and the total tokens used.
	@Codable @CodingKeys(.snake_case) public struct Usage: Equatable, Hashable, Sendable {
		/// A detailed breakdown of the input tokens.
		@Codable @CodingKeys(.snake_case) public struct InputTokensDetails: Equatable, Hashable, Sendable {
			/// The number of cached tokens.
			public var cachedTokens: UInt

			/// Create a new `InputTokensDetails` instance.
			///
			/// - Parameter cachedTokens: The number of cached tokens
			public init(cachedTokens: UInt) {
				self.cachedTokens = cachedTokens
			}
		}

		/// A detailed breakdown of the output tokens.
		@Codable @CodingKeys(.snake_case) public struct OutputTokensDetails: Equatable, Hashable, Sendable {
			/// The number of reasoning tokens.
			public var reasoningTokens: UInt

			/// Create a new `OutputTokensDetails` instance.
			///
			/// - Parameter reasoningTokens: The number of reasoning tokens
			public init(reasoningTokens: UInt) {
				self.reasoningTokens = reasoningTokens
			}
		}

		/// The number of input tokens.
		public var inputTokens: UInt

		/// A detailed breakdown of the input tokens.
		public var inputTokensDetails: InputTokensDetails

		/// The number of output tokens.
		public var outputTokens: UInt

		/// A detailed breakdown of the output tokens.
		public var outputTokensDetails: OutputTokensDetails

		/// The total number of tokens used.
		public var totalTokens: UInt

		/// Create a new `Usage` instance.
		///
		/// - Parameter inputTokens: The number of input tokens
		/// - Parameter inputTokensDetails: A detailed breakdown of the input tokens
		/// - Parameter outputTokens: The number of output tokens
		/// - Parameter outputTokensDetails: A detailed breakdown of the output tokens
		/// - Parameter totalTokens: The total number of tokens used
		public init(inputTokens: UInt, inputTokensDetails: InputTokensDetails, outputTokens: UInt, outputTokensDetails: OutputTokensDetails, totalTokens: UInt) {
			self.inputTokens = inputTokens
			self.totalTokens = totalTokens
			self.outputTokens = outputTokens
			self.inputTokensDetails = inputTokensDetails
			self.outputTokensDetails = outputTokensDetails
		}
	}

	/// Whether to run the model response in the background. [Learn more](https://platform.openai.com/docs/guides/background-responses).
	public var background: Bool?

	/// The conversation that this response belongs to.
	///
	/// Input items and output items from this response are automatically added to this conversation.
	@CodedBy(ConversationIDCoder())
	public var conversation: String?

	/// When this Response was created.
	@CodedBy(Since1970DateCoder())
	public var createdAt: Date

	/// Unique identifier for this Response.
	public var id: String

	/// Details about why the response is incomplete.
	public var incompleteDetails: IncompleteDetails?

	/// Inserts a system (or developer) message as the first item in the model's context.
	///
	/// When using along with `previousResponseId`, the instructions from a previous response will be not be carried over to the next response. This makes it simple to swap out system (or developer) messages in new responses.
	public var instructions: String?

	/// An upper bound for the number of tokens that can be generated for a response, including visible output tokens and [reasoning tokens](https://platform.openai.com/docs/guides/reasoning).
	public var maxOutputTokens: UInt?

	/// The maximum number of total calls to built-in tools that can be processed in a response.
	///
	/// This maximum number applies across all built-in tool calls, not per individual tool.
	///
	/// Any further attempts to call a tool by the model will be ignored.
	public var maxToolCalls: UInt?

	/// Set of 16 key-value pairs that can be attached to an object.
	///
	/// This can be useful for storing additional information about the object in a structured format, and querying for objects via API or the dashboard.
	///
	/// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of 512 characters.
	public var metadata: [String: String]

	/// Model ID used to generate the response, like gpt-4o or o1. OpenAI offers a wide range of models with different capabilities, performance characteristics, and price points.
	///
	/// Refer to the [model guide](https://platform.openai.com/docs/models) to browse and compare available models.
	public var model: String

	/// An array of content items generated by the model.
	/// - The length and order of items in the `output` array is dependent on the model's response.
	/// - Rather than accessing the first item in the `output` array and assuming it's an assistant message with the content generated by the model, you might consider using the `output_text` function.
	public var output: [Item.Output]

	/// Whether to allow the model to run tool calls in parallel.
	public var parallelToolCalls: Bool

	/// The unique ID of the previous response to the model. Use this to create multi-turn conversations.
	/// - Learn more about [conversation state](https://platform.openai.com/docs/guides/conversation-state).
	public var previousResponseId: String?

	/// Reference to a prompt template and its variables.
	/// - [Learn more](https://platform.openai.com/docs/guides/prompt-templates)
	public var prompt: Prompt?

	/// Used by OpenAI to cache responses for similar requests to optimize your cache hit rates.
	///
	/// Replaces the user field. [Learn more](https://platform.openai.com/docs/guides/prompt-caching)
	public var promptCacheKey: String?

	/// The retention policy for the prompt cache.
	///
	/// Set to `oneDay` to enable extended prompt caching, which keeps cached prefixes active for longer, up to a maximum of 24 hours.
	public var promptCacheRetention: CacheRetention?

	/// Configuration options for [reasoning models](https://platform.openai.com/docs/guides/reasoning).
	/// Only available for o-series models.
	public var reasoning: ReasoningConfig?

	/// A stable identifier used to help detect users of your application that may be violating OpenAI's usage policies.
	///
	/// The IDs should be a string that uniquely identifies each user.
	///
	/// We recommend hashing their username or email address, in order to avoid sending us any identifying information.
	/// - [Safety Identifiers](https://platform.openai.com/docs/guides/safety-best-practices#safety-identifiers)
	public var safetyIdentifier: String?

	/// The service tier used for processing the request.
	public var serviceTier: ServiceTier?

	/// The status of the response generation.
	public var status: Status

	/// What sampling temperature to use, between 0 and 2.
	///
	/// Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
	///
	/// We generally recommend altering this or `topP` but not both.
	public var temperature: Double

	/// Configuration options for a text response from the model. Can be plain text or structured JSON data.
	/// - [Text inputs and outputs](https://platform.openai.com/docs/guides/text)
	/// - [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs)
	public var text: TextConfig

	/// How the model should select which tool (or tools) to use when generating a response.
	///
	/// See the `tools` parameter to see how to specify which tools the model can call.
	public var toolChoice: Tool.Choice

	/// An array of tools the model may call while generating a response. You can specify which tool to use by setting the `toolChoice` parameter.
	///
	/// The two categories of tools you can provide the model are:
	/// - **Built-in tools**: Tools that are provided by OpenAI that extend the model's capabilities, like [web search](https://platform.openai.com/docs/guides/tools-web-search) or [file search](https://platform.openai.com/docs/guides/tools-file-search). Learn more about [built-in tools](https://platform.openai.com/docs/guides/tools).
	/// - **Function calls (custom tools)**: Functions that are defined by you, enabling the model to call your own code. Learn more about [function calling](https://platform.openai.com/docs/guides/function-calling).
	public var tools: [Tool]

	/// An integer between 0 and 20 specifying the number of most likely tokens to return at each token position, each with an associated log probability.
	public var topLogprobs: UInt?

	/// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with `topP` probability mass.
	///
	/// So 0.1 means only the tokens comprising the top 10% probability mass are considered.
	///
	/// We generally recommend altering this or `temperature` but not both.
	public var topP: Double

	/// The truncation strategy to use for the model response.
	public var truncation: Truncation

	/// Represents token usage details including input tokens, output tokens, a breakdown of output tokens, and the total tokens used.
	public var usage: Usage?

	/// Whether the response was stored on OpenAI's server for later retrieval.
	public var store: Bool

	/// Constrains the verbosity of the model's response.
	///
	/// Lower values will result in more concise responses, while higher values will result in more verbose responses.
	public var verbosity: Verbosity?

	/// Aggregated text output from all `outputText` items in the output array, if any are present.
	public var outputText: String {
		output.compactMap { output -> Message.Output? in
			guard case let .message(message) = output else { return nil }
			return message
		}
		.flatMap { message in message.content }
		.map { content in
			switch content {
				case let .text(text, _, _): return text
				case let .refusal(refusal): return refusal
			}
		}
		.joined()
	}

	/// Create a new `Response` instance.
	///
	/// - Parameter createdAt: When this Response was created
	/// - Parameter id: Unique identifier for this Response
	/// - Parameter incompleteDetails: Details about why the response is incomplete
	/// - Parameter instructions: System (or developer) message as the in the model's context
	/// - Parameter maxOutputTokens: An upper bound for the number of tokens that can be generated for a response, including visible output tokens and reasoning tokens
	/// - Parameter metadata: Set of 16 key-value pairs that can be attached to an object
	/// - Parameter model: Model ID used to generate the response
	/// - Parameter output: An array of content items generated by the model
	/// - Parameter parallelToolCalls: Whether the model is allowed to run tool calls in parallel
	/// - Parameter previousResponseId: The unique ID of the previous response to the model
	/// - Parameter prompt: Reference to a prompt template and its variables
	/// - Parameter promptCacheKey: Used by OpenAI to cache responses for similar requests to optimize your cache hit rates
	/// - Parameter reasoning: Configuration options for reasoning models
	/// - Parameter safetyIdentifier: A stable identifier used to help detect users of your application that may be violating OpenAI's usage policies
	/// - Parameter status: The status of the response generation
	/// - Parameter temperature: What sampling temperature the model used, from 0 to 2
	/// - Parameter text: Configuration options for a text response from the model
	/// - Parameter toolChoice: How the model selected which tool (or tools) to use when generating a response
	/// - Parameter tools: An array of tools the model may call while generating a response
	/// - Parameter topP: An alternative to sampling with temperature, called nucleus sampling
	/// - Parameter truncation: The truncation strategy used for the model response
	/// - Parameter usage: Token usage details including input tokens, output tokens, a breakdown of output tokens, and the total tokens used by the model
	/// - Parameter store: Whether the response was stored on OpenAI's server for later retrieval
	/// - Parameter verbosity: Constrains the verbosity of the model's response.
	public init(
		createdAt: Date,
		id: String,
		incompleteDetails: IncompleteDetails? = nil,
		instructions: String? = nil,
		maxOutputTokens: UInt? = nil,
		metadata: [String: String] = [:],
		model: String,
		output: [Item.Output] = [],
		parallelToolCalls: Bool,
		previousResponseId: String? = nil,
		prompt: Prompt? = nil,
		promptCacheKey: String? = nil,
		promptCacheRetention: CacheRetention? = nil,
		reasoning: ReasoningConfig? = nil,
		safetyIdentifier: String? = nil,
		status: Status,
		temperature: Double,
		text: TextConfig,
		toolChoice: Tool.Choice,
		tools: [Tool] = [],
		topP: Double,
		truncation: Truncation,
		usage: Usage? = nil,
		store: Bool = true,
		verbosity: Verbosity? = nil
	) {
		self.id = id
		self.topP = topP
		self.text = text
		self.tools = tools
		self.model = model
		self.usage = usage
		self.store = store
		self.status = status
		self.prompt = prompt
		self.output = output
		self.metadata = metadata
		self.verbosity = verbosity
		self.reasoning = reasoning
		self.createdAt = createdAt
		self.toolChoice = toolChoice
		self.truncation = truncation
		self.temperature = temperature
		self.instructions = instructions
		self.promptCacheKey = promptCacheKey
		self.maxOutputTokens = maxOutputTokens
		self.safetyIdentifier = safetyIdentifier
		self.incompleteDetails = incompleteDetails
		self.parallelToolCalls = parallelToolCalls
		self.previousResponseId = previousResponseId
		self.promptCacheRetention = promptCacheRetention
	}
}

extension Response.Error: Swift.Error, LocalizedError {
	public var errorDescription: String? { message }
}

extension Response {
	struct ErrorResponse: Decodable {
		var error: Error
	}

	enum ResultResponse: Decodable {
		case success(Response)
		case error(Error)

		enum CodingKeys: String, CodingKey {
			case error
		}

		init(from decoder: Decoder) throws {
			if let container = try? decoder.container(keyedBy: CodingKeys.self), let error = try? container.decode(Error.self, forKey: .error) {
				self = .error(error)
				return
			}

			self = try .success(Response(from: decoder))
		}

		func into() -> Result<Response, Response.Error> {
			switch self {
				case let .success(response): return .success(response)
				case let .error(error): return .failure(error)
			}
		}
	}
}

struct ConversationIDCoder: HelperCoder {
	typealias Coded = String

	private enum CodingKeys: String, CodingKey {
		case id
	}

	func decode(from decoder: any Decoder) throws -> String {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		return try container.decode(String.self, forKey: .id)
	}
}
