import Foundation
import MetaCodable

/// A request to the OpenAI Response API.
@Codable @CodingKeys(.snake_case) public struct Request: Equatable, Hashable, Sendable {
	/// Additional output data to include in the model response.
	public enum Include: String, Equatable, Hashable, Codable, Sendable {
		/// Includes the outputs of python code execution in code interpreter tool call items.
		case codeInterpreterOutputs = "code_interpreter_call.outputs"

		/// Include image urls from the computer call output.
		case computerCallImageURLs = "computer_call_output.output.image_url"

		/// Include the search results of the file search tool call.
		case fileSearchResults = "file_search_call.results"

		/// Include image urls from the input message.
		case inputImageURLs = "message.input_image.image_url"

		/// Include logprobs with assistant messages.
		case outputLogprobs = "message.output_text.logprobs"

		/// Include the sources of the web search tool call.
		case webSearchSources = "web_search_call.action.sources"

		/// Includes an encrypted version of reasoning tokens in reasoning item outputs.
		///
		/// This enables reasoning items to be used in multi-turn conversations when using the Responses API statelessly (like when the store parameter is set to false, or when an organization is enrolled in the zero data retention program).
		case encryptedReasoning = "reasoning.encrypted_content"
	}

	@Codable @CodingKeys(.snake_case) public struct StreamOptions: Equatable, Hashable, Sendable {
		/// Enables stream obfuscation for the response.
		///
		/// Stream obfuscation adds random characters to an obfuscation field on streaming delta events to normalize payload sizes as a mitigation to certain side-channel attacks.
		///
		/// These obfuscation fields are included by default, but add a small amount of overhead to the data stream.
		///
		/// You can set `includeObfuscation` to false to optimize for bandwidth if you trust the network links between your application and the OpenAI API.
		public var includeObfuscation: Bool?

		/// Creates a new `StreamOptions` instance.
		///
		/// - Parameter includeObfuscation: Enables stream obfuscation for the response.
		public init(includeObfuscation: Bool? = nil) {
			self.includeObfuscation = includeObfuscation
		}
	}

	/// Whether to run the model response in the background.
	///
	/// - [Learn more](https://platform.openai.com/docs/guides/background)
	public var background: Bool?

	/// The unique ID of the conversation that this response belongs to.
	///
	/// Items from this conversation are prepended to `input_items` for this response request.
	///
	/// Input items and output items from this response are automatically added to this conversation after this response completes.
	public var conversation: String?

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

	/// The maximum number of total calls to built-in tools that can be processed in a response.
	///
	/// This maximum number applies across all built-in tool calls, not per individual tool.
	///
	/// Any further attempts to call a tool by the model will be ignored.
	public var maxToolCalls: UInt?

	/// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format, and querying for objects via API or the dashboard.
	///
	/// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of 512 characters.
	public var metadata: [String: String]?

	/// Whether to allow the model to run tool calls in parallel.
	public var parallelToolCalls: Bool?

	/// The unique ID of the previous response to the model. Use this to create multi-turn conversations.
	///
	/// Cannot be used in conjunction with `conversation`.
	///
	/// Learn more about [conversation state](https://platform.openai.com/docs/guides/conversation-state).
	public var previousResponseId: String?

	/// Reference to a prompt template and its variables. [Learn more](https://platform.openai.com/docs/guides/text?api-mode=responses#reusable-prompts).
	public var prompt: Prompt?

	/// Used by OpenAI to cache responses for similar requests to optimize your cache hit rates.
	///
	/// Replaces the `user` field. [Learn more](https://platform.openai.com/docs/guides/prompt-caching).
	public var promptCacheKey: String?

	/// The retention policy for the prompt cache.
	///
	/// Set to `oneDay` to enable extended prompt caching, which keeps cached prefixes active for longer, up to a maximum of 24 hours.
	public var promptCacheRetention: CacheRetention?

	/// Configuration options for [reasoning models](https://platform.openai.com/docs/guides/reasoning).
	public var reasoning: ReasoningConfig?

	/// A stable identifier used to help detect users of your application that may be violating OpenAI's usage policies.
	///
	/// The IDs should be a string that uniquely identifies each user. We recommend hashing their username or email address, in order to avoid sending us any identifying information.
	/// - [Safety Identifiers](https://platform.openai.com/docs/guides/safety-best-practices#safety-identifiers)
	public var safetyIdentifier: String?

	/// Specifies the latency tier to use for processing the request
	public var serviceTier: ServiceTier?

	/// Whether to store the generated model response for later retrieval via API.
	public var store: Bool?

	/// If set to true, the model response data will be streamed to the client as it is generated using[ server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#event_stream_format).
	public var stream: Bool?

	/// Options for streaming responses.
	///
	/// Only set this when you set `stream` to true.
	public var streamOptions: StreamOptions?

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

	/// An integer between 0 and 20 specifying the number of most likely tokens to return at each token position, each with an associated log probability.
	public var topLogprobs: UInt?

	/// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with `top_p` probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
	///
	/// We generally recommend altering this or `temperature` but not both.
	public var topP: Double?

	/// The truncation strategy to use for the model response.
	public var truncation: Truncation?

	/// Constrains the verbosity of the model's response.
	///
	/// Lower values will result in more concise responses, while higher values will result in more verbose responses.
	public var verbosity: Verbosity?

	/// Creates a new `Request` instance.
	///
	/// - Parameter model: Model ID used to generate the response.
	/// - Parameter input: Text, image, or file inputs to the model, used to generate a response.
	/// - Parameter background: Whether to run the model response in the background.
	/// - Parameter conversation: The unique ID of the conversation that this response belongs to.
	/// - Parameter include: Specify additional output data to include in the model response.
	/// - Parameter instructions: Inserts a system (or developer) message as the first item in the model's context.
	/// - Parameter maxOutputTokens: An upper bound for the number of tokens that can be generated for a response, including visible output tokens and reasoning tokens.
	/// - Parameter maxToolCalls: The maximum number of total calls to built-in tools that can be processed in a response.
	/// - Parameter metadata: Set of 16 key-value pairs that can be attached to an object.
	/// - Parameter parallelToolCalls: Whether to allow the model to run tool calls in parallel.
	/// - Parameter previousResponseId: The unique ID of the previous response to the model.
	/// - Parameter prompt: Reference to a prompt template and its variables.
	/// - Parameter promptCacheKey: Used by OpenAI to cache responses for similar requests to optimize your cache hit rates.
	/// - Parameter reasoning: Configuration options for reasoning models.
	/// - Parameter safetyIdentifier: A stable identifier used to help detect users of your application that may be violating OpenAI's usage policies.
	/// - Parameter serviceTier: Specifies the latency tier to use for processing the request.
	/// - Parameter store: Whether to store the generated model response for later retrieval via API.
	/// - Parameter stream: If set to true, the model response data will be streamed to the client as it is generated.
	/// - Parameter streamOptions: Options for streaming responses.
	/// - Parameter temperature: What sampling temperature to use, between 0 and 2.
	/// - Parameter text: Configuration options for a text response from the model.
	/// - Parameter toolChoice: How the model should select which tool (or tools) to use when generating a response.
	/// - Parameter tools: An array of tools the model may call while generating a response.
	/// - Parameter topLogprobs: An integer between 0 and 20 specifying the number of most likely tokens to return at each token position, each with an associated log probability.
	/// - Parameter topP: An alternative to sampling with temperature, called nucleus sampling.
	/// - Parameter truncation: The truncation strategy to use for the model response.
	/// - Parameter verbosity: Constrains the verbosity of the model's response.
	public init(
		model: Model,
		input: Input,
		background: Bool? = nil,
		conversation: String? = nil,
		include: [Include]? = nil,
		instructions: String? = nil,
		maxOutputTokens: UInt? = nil,
		maxToolCalls: UInt? = nil,
		metadata: [String: String]? = nil,
		parallelToolCalls: Bool? = nil,
		previousResponseId: String? = nil,
		prompt: Prompt? = nil,
		promptCacheKey: String? = nil,
		promptCacheRetention: CacheRetention? = nil,
		reasoning: ReasoningConfig? = nil,
		safetyIdentifier: String? = nil,
		serviceTier: ServiceTier? = nil,
		store: Bool? = nil,
		stream: Bool? = nil,
		streamOptions: StreamOptions? = nil,
		temperature: Double? = nil,
		text: TextConfig? = nil,
		toolChoice: Tool.Choice? = nil,
		tools: [Tool]? = nil,
		topLogprobs: UInt? = nil,
		topP: Double? = nil,
		truncation: Truncation? = nil,
		verbosity: Verbosity? = nil
	) {
		self.text = text
		self.topP = topP
		self.model = model
		self.input = input
		self.store = store
		self.tools = tools
		self.prompt = prompt
		self.stream = stream
		self.include = include
		self.metadata = metadata
		self.reasoning = reasoning
		self.verbosity = verbosity
		self.background = background
		self.toolChoice = toolChoice
		self.truncation = truncation
		self.serviceTier = serviceTier
		self.topLogprobs = topLogprobs
		self.temperature = temperature
		self.instructions = instructions
		self.maxToolCalls = maxToolCalls
		self.conversation = conversation
		self.streamOptions = streamOptions
		self.promptCacheKey = promptCacheKey
		self.maxOutputTokens = maxOutputTokens
		self.safetyIdentifier = safetyIdentifier
		self.parallelToolCalls = parallelToolCalls
		self.previousResponseId = previousResponseId
		self.promptCacheRetention = promptCacheRetention
	}
}
