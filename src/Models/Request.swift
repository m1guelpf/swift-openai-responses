import Foundation
import MetaCodable

/// A request to the OpenAI Response API.
@Codable @CodingKeys(.snake_case) public struct Request: Equatable, Hashable, Sendable {
	/// Additional output data to include in the model response.
	public enum Include: String, Equatable, Hashable, Codable, Sendable {
		/// Include the search results of the file search tool call.
		case fileSearchResults = "file_search_call.results"
		/// Include image urls from the input message.
		case inputImageURLs = "message.input_image.image_url"
		/// Include image urls from the computer call output.
		case computerCallImageURLs = "computer_call_output.output.image_url"
	}

	/// Model ID used to generate the response.
	///
	/// OpenAI offers a wide range of models with different capabilities, performance characteristics, and price points. Refer to the [model guide](https://platform.openai.com/docs/models) to browse and compare available models.
	public var model: Model

	/// Text, image, or file inputs to the model, used to generate a response.
	public var input: Input

	/// Specify additional output data to include in the model response.
	public var include: [Include]?

	/// Inserts a system (or developer) message as the first item in the model's context.
	///
	/// When using along with `previous_response_id`, the instructions from a previous response will be not be carried over to the next response. This makes it simple to swap out system (or developer) messages in new responses.
	public var instructions: String?

	/// An upper bound for the number of tokens that can be generated for a response, including visible output tokens and [reasoning tokens](https://platform.openai.com/docs/guides/reasoning).
	public var maxOutputTokens: UInt?

	/// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format, and querying for objects via API or the dashboard.
	///
	/// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of 512 characters.
	public var metadata: [String: String]?

	/// Whether to allow the model to run tool calls in parallel.
	public var parallelToolCalls: Bool?

	/// The unique ID of the previous response to the model. Use this to create multi-turn conversations.
	///
	/// Learn more about [conversation state](https://platform.openai.com/docs/guides/conversation-state).
	public var previousResponseId: String?

	/// Configuration options for [reasoning models](https://platform.openai.com/docs/guides/reasoning).
	public var reasoning: ReasoningConfig?

	/// Whether to store the generated model response for later retrieval via API.
	public var store: Bool?

	/// If set to true, the model response data will be streamed to the client as it is generated using[ server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#event_stream_format).
	public var stream: Bool?

	/// What sampling temperature to use, between 0 and 2.
	///
	/// Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
	///
	/// We generally recommend altering this or `top_p` but not both.
	public var temperature: Double?

	/// Configuration options for a text response from the model. Can be plain text or structured JSON data.
	/// - [Text inputs and outputs](https://platform.openai.com/docs/guides/text)
	/// - [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs)
	public var text: TextConfig?

	/// How the model should select which tool (or tools) to use when generating a response.
	///
	/// See the `tools` parameter to see how to specify which tools the model can call.
	public var toolChoice: Tool.Choice?

	/// An array of tools the model may call while generating a response. You can specify which tool to use by setting the `tool_choice` parameter.
	///
	/// The two categories of tools you can provide the model are:
	/// - **Built-in tools**: Tools that are provided by OpenAI that extend the model's capabilities, like [web search](https://platform.openai.com/docs/guides/tools-web-search) or [file search](https://platform.openai.com/docs/guides/tools-file-search). Learn more about [built-in tools](https://platform.openai.com/docs/guides/tools).
	/// - **Function calls (custom tools)**: Functions that are defined by you, enabling the model to call your own code. Learn more about [function calling](https://platform.openai.com/docs/guides/function-calling).
	public var tools: [Tool]?

	/// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with `top_p` probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
	///
	/// We generally recommend altering this or `temperature` but not both.
	public var topP: Double?

	/// The truncation strategy to use for the model response.
	public var truncation: Truncation?

	/// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
	/// - [End User IDs](https://platform.openai.com/docs/guides/safety-best-practices#end-user-ids)
	public var user: String?

	/// Creates a new `Request` instance.
	///
	/// - Parameter model: Model ID used to generate the response.
	/// - Parameter input: Text, image, or file inputs to the model, used to generate a response.
	/// - Parameter include: Specify additional output data to include in the model response.
	/// - Parameter instructions: Inserts a system (or developer) message as the first item in the model's context.
	/// - Parameter maxOutputTokens: An upper bound for the number of tokens that can be generated for a response, including visible output tokens and reasoning tokens.
	/// - Parameter metadata: Set of 16 key-value pairs that can be attached to an object.
	/// - Parameter parallelToolCalls: Whether to allow the model to run tool calls in parallel.
	/// - Parameter previousResponseId: The unique ID of the previous response to the model.
	/// - Parameter reasoning: Configuration options for reasoning models.
	/// - Parameter store: Whether to store the generated model response for later retrieval via API.
	/// - Parameter stream: If set to true, the model response data will be streamed to the client as it is generated.
	/// - Parameter temperature: What sampling temperature to use, between 0 and 2.
	/// - Parameter text: Configuration options for a text response from the model.
	/// - Parameter toolChoice: How the model should select which tool (or tools) to use when generating a response.
	/// - Parameter tools: An array of tools the model may call while generating a response.
	/// - Parameter topP: An alternative to sampling with temperature, called nucleus sampling.
	/// - Parameter truncation: The truncation strategy to use for the model response.
	/// - Parameter user: A unique identifier representing your end-user.
	public init(
		model: Model,
		input: Input,
		include: [Include]? = nil,
		instructions: String? = nil,
		maxOutputTokens: UInt? = nil,
		metadata: [String: String]? = nil,
		parallelToolCalls: Bool? = nil,
		previousResponseId: String? = nil,
		reasoning: ReasoningConfig? = nil,
		store: Bool? = nil,
		stream: Bool? = nil,
		temperature: Double? = nil,
		text: TextConfig? = nil,
		toolChoice: Tool.Choice? = nil,
		tools: [Tool]? = nil,
		topP: Double? = nil,
		truncation: Truncation? = nil,
		user: String? = nil
	) {
		self.user = user
		self.text = text
		self.topP = topP
		self.model = model
		self.input = input
		self.store = store
		self.tools = tools
		self.stream = stream
		self.include = include
		self.metadata = metadata
		self.reasoning = reasoning
		self.toolChoice = toolChoice
		self.truncation = truncation
		self.temperature = temperature
		self.instructions = instructions
		self.maxOutputTokens = maxOutputTokens
		self.parallelToolCalls = parallelToolCalls
		self.previousResponseId = previousResponseId
	}
}
