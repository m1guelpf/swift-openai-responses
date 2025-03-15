import Foundation
import MetaCodable
import HelperCoders

@Codable @CodingKeys(.snake_case) public struct Response: Identifiable, Sendable {
	public struct Error: Codable, Equatable {
		/// The type of error.
		public let type: String
		/// A human-readable description of the error.
		public let message: String
		/// The error code for the response.
		public let code: String?
		/// The parameter that caused the error.
		public let param: String?

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
	public struct IncompleteDetails: Equatable, Codable, Sendable {
		/// The reason why the response is incomplete.
		public let reason: String

		/// Create a new `IncompleteDetails` instance.
		///
		/// - Parameter reason: The reason why the response is incomplete
		public init(reason: String) {
			self.reason = reason
		}
	}

	/// The status of the response generation.
	public enum Status: String, CaseIterable, Equatable, Codable, Sendable {
		case failed
		case completed
		case incomplete
		case inProgress = "in_progress"
	}

	/// Represents token usage details including input tokens, output tokens, a breakdown of output tokens, and the total tokens used.
	@Codable @CodingKeys(.snake_case) public struct Usage: Equatable, Sendable {
		/// A detailed breakdown of the input tokens.
		@Codable @CodingKeys(.snake_case) public struct InputTokensDetails: Equatable, Sendable {
			/// The number of cached tokens.
			public let cachedTokens: UInt

			/// Create a new `InputTokensDetails` instance.
			///
			/// - Parameter cachedTokens: The number of cached tokens
			public init(cachedTokens: UInt) {
				self.cachedTokens = cachedTokens
			}
		}

		/// A detailed breakdown of the output tokens.
		@Codable @CodingKeys(.snake_case) public struct OutputTokensDetails: Equatable, Sendable {
			/// The number of reasoning tokens.
			public let reasoningTokens: UInt

			/// Create a new `OutputTokensDetails` instance.
			///
			/// - Parameter reasoningTokens: The number of reasoning tokens
			public init(reasoningTokens: UInt) {
				self.reasoningTokens = reasoningTokens
			}
		}

		/// The number of input tokens.
		public let inputTokens: UInt

		/// A detailed breakdown of the input tokens.
		public let inputTokensDetails: InputTokensDetails

		/// The number of output tokens.
		public let outputTokens: UInt

		/// A detailed breakdown of the output tokens.
		public let outputTokensDetails: OutputTokensDetails

		/// The total number of tokens used.
		public let totalTokens: UInt

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

	/// When this Response was created.
	@CodedBy(Since1970DateCoder())
	public let createdAt: Date

	/// Unique identifier for this Response.
	public let id: String

	/// Details about why the response is incomplete.
	public let incompleteDetails: IncompleteDetails?

	/// Inserts a system (or developer) message as the first item in the model's context.
	///
	/// When using along with `previousResponseId`, the instructions from a previous response will be not be carried over to the next response. This makes it simple to swap out system (or developer) messages in new responses.
	public let instructions: String?

	/// An upper bound for the number of tokens that can be generated for a response, including visible output tokens and [reasoning tokens](https://platform.openai.com/docs/guides/reasoning).
	public let maxOutputTokens: UInt?

	/// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format, and querying for objects via API or the dashboard.
	/// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of 512 characters.
	public let metadata: [String: String]

	/// Model ID used to generate the response, like gpt-4o or o1. OpenAI offers a wide range of models with different capabilities, performance characteristics, and price points.
	///
	/// Refer to the [model guide](https://platform.openai.com/docs/models) to browse and compare available models.
	public let model: String

	/// An array of content items generated by the model.
	/// - The length and order of items in the `output` array is dependent on the model's response.
	/// - Rather than accessing the first item in the `output` array and assuming it's an assistant message with the content generated by the model, you might consider using the `output_text` function.
	public let output: [Item.Output]

	/// Whether to allow the model to run tool calls in parallel.
	public let parallelToolCalls: Bool

	/// The unique ID of the previous response to the model. Use this to create multi-turn conversations.
	/// - Learn more about [conversation state](https://platform.openai.com/docs/guides/conversation-state).
	public let previousResponseId: String?

	/// Configuration options for [reasoning models](https://platform.openai.com/docs/guides/reasoning).
	/// Only available for o-series models.
	public let reasoning: ReasoningConfig

	/// The status of the response generation.
	public let status: Status

	/// What sampling temperature to use, between 0 and 2.
	///
	/// Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
	///
	/// We generally recommend altering this or `topP` but not both.
	public let temperature: Int

	/// Configuration options for a text response from the model. Can be plain text or structured JSON data. Learn more:
	/// - [Text inputs and outputs](https://platform.openai.com/docs/guides/text)
	/// - [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs)
	public let text: TextConfig

	/// How the model should select which tool (or tools) to use when generating a response.
	///
	/// See the `tools` parameter to see how to specify which tools the model can call.
	public let toolChoice: Tool.Choice

	/// An array of tools the model may call while generating a response. You can specify which tool to use by setting the `tool_choice` parameter.
	///
	/// The two categories of tools you can provide the model are:
	/// - **Built-in tools**: Tools that are provided by OpenAI that extend the model's capabilities, like [web search](https://platform.openai.com/docs/guides/tools-web-search) or [file search](https://platform.openai.com/docs/guides/tools-file-search). Learn more about [built-in tools](https://platform.openai.com/docs/guides/tools).
	/// - **Function calls (custom tools)**: Functions that are defined by you, enabling the model to call your own code. Learn more about [function calling](https://platform.openai.com/docs/guides/function-calling).
	public let tools: [Tool]

	/// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
	///
	/// We generally recommend altering this or `temperature` but not both.
	public let topP: Int

	/// The truncation strategy to use for the model response.
	public let truncation: Truncation

	/// Represents token usage details including input tokens, output tokens, a breakdown of output tokens, and the total tokens used.
	public let usage: Usage?

	/// Whether the response was stored on OpenAI's server for later retrieval.
	public let store: Bool

	/// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more](https://platform.openai.com/docs/guides/safety-best-practices#end-user-ids).
	public let user: String?

	/// Aggregated text output from all `output_text` items in the output array, if any are present.
	public var outputText: String {
		output.compactMap { output -> Item.Output.Message? in
			guard case let .message(message) = output else { return nil }
			return message
		}
		.flatMap { message in message.content }
		.map { content in
			switch content {
				case let .text(text, _): return text
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
	/// - Parameter reasoning: Configuration options for reasoning models
	/// - Parameter status: The status of the response generation
	/// - Parameter temperature: What sampling temperature the model used, from 0 to 2
	/// - Parameter text: Configuration options for a text response from the model
	/// - Parameter toolChoice: How the model selected which tool (or tools) to use when generating a response
	/// - Parameter tools: An array of tools the model may call while generating a response
	/// - Parameter topP: An alternative to sampling with temperature, called nucleus sampling
	/// - Parameter truncation: The truncation strategy used for the model response
	/// - Parameter usage: Token usage details including input tokens, output tokens, a breakdown of output tokens, and the total tokens used by the model
	/// - Parameter store: Whether the response was stored on OpenAI's server for later retrieval
	/// - Parameter user: A unique identifier representing your end-user
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
		reasoning: ReasoningConfig,
		status: Status,
		temperature: Int,
		text: TextConfig,
		toolChoice: Tool.Choice,
		tools: [Tool] = [],
		topP: Int,
		truncation: Truncation,
		usage: Usage? = nil,
		store: Bool,
		user: String? = nil
	) {
		self.createdAt = createdAt
		self.id = id
		self.incompleteDetails = incompleteDetails
		self.instructions = instructions
		self.maxOutputTokens = maxOutputTokens
		self.metadata = metadata
		self.model = model
		self.output = output
		self.parallelToolCalls = parallelToolCalls
		self.previousResponseId = previousResponseId
		self.reasoning = reasoning
		self.status = status
		self.temperature = temperature
		self.text = text
		self.toolChoice = toolChoice
		self.tools = tools
		self.topP = topP
		self.truncation = truncation
		self.usage = usage
		self.store = store
		self.user = user
	}
}

extension Response.Error: Swift.Error, LocalizedError {
	public var errorDescription: String? { message }
}

extension Response {
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
