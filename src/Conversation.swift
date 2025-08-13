import Foundation
import Observation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A wrapper around the Responses API for managing a conversation.
@MainActor @Observable public final class Conversation {
	/// An entry in the conversation.
	public enum Entry: Equatable, Sendable {
		/// A request to the model.
		case request(Request)

		/// A response from the model.
		case response(Response)
	}

	/// The entries in the conversation.
	public private(set) var entries: [Entry] = []

	/// The messages in the conversation.
	///
	/// Note that this doesn't include function calls or other non-message outputs. Use `entries` to access all outputs.
	public var messages: [Message] {
		entries.flatMap { entry -> [Message] in
			switch entry {
				case let .request(request): request.input.messages
				case let .response(response): response.output.compactMap { item in
						if case let .message(message) = item { .output(message) } else { nil }
					}
			}
		}
	}

	public var lastResponse: Response? {
		guard let entry = entries.last(where: { entry in
			if case .response = entry { return true }
			return false
		}), case let .response(response) = entry else { return nil }

		return response
	}

	/// The last response ID in the conversation.
	public var previousResponseId: String? {
		lastResponse?.id
	}

	/// Whether there is a response in progress.
	public var isResponding: Bool {
		entries.contains { entry in
			if case let .response(response) = entry, response.status == .inProgress { return true }
			return false
		}
	}

	/// Whether a web search is in progress.
	public var isWebSearchInProgress: Bool {
		entries.contains { entry in
			guard case let .response(response) = entry, response.status == .inProgress else { return false }

			return response.output.contains { item in
				guard case let .webSearchCall(webSearch) = item else { return false }

				return webSearch.status == .inProgress || webSearch.status == .searching
			}
		}
	}

	/// Whether a file search is in progress.
	public var isFileSearchInProgress: Bool {
		entries.contains { entry in
			guard case let .response(response) = entry, response.status == .inProgress else { return false }

			return response.output.contains { item in
				guard case let .fileSearch(fileSearch) = item else { return false }

				return fileSearch.status == .inProgress || fileSearch.status == .searching
			}
		}
	}

	/// Whether an image generation is in progress.
	public var isImageGenerationInProgress: Bool {
		entries.contains { entry in
			guard case let .response(response) = entry, response.status == .inProgress else { return false }

			return response.output.contains { item in
				guard case let .imageGenerationCall(imageGenerationCall) = item else { return false }

				return imageGenerationCall.status == .inProgress || imageGenerationCall.status == .generating
			}
		}
	}

	/// Whether a code interpreter call is in progress.
	public var isCodeInterpreterCallInProgress: Bool {
		entries.contains { entry in
			guard case let .response(response) = entry, response.status == .inProgress else { return false }

			return response.output.contains { item in
				guard case let .codeInterpreterCall(codeInterpreterCall) = item else { return false }

				return codeInterpreterCall.status == .inProgress || codeInterpreterCall.status == .interpreting
			}
		}
	}

	private var config: Config
	private nonisolated let client: ResponsesAPI
	private nonisolated let decoder = JSONDecoder()
	private nonisolated let encoder = JSONEncoder()

	/// Creates a new conversation.
	///
	/// - Parameter client: A `ResponsesAPI` instance to use for the conversation.
	/// - Parameter model: The model to use for the conversation. Can be changed later using the `model` property.
	///	- Parameter configuring: A closure to further configure the conversation.
	init(client: ResponsesAPI, using model: Model = .gpt5, configuring closure: (inout Config) -> Void = { _ in }) {
		self.client = client
		config = Config(model: model)
		closure(&config)
	}

	/// Creates a new conversation.
	///
	/// - Parameter authToken: The OpenAI API key to use for authentication.
	/// - Parameter organizationId: The [organization](https://platform.openai.com/docs/guides/production-best-practices#setting-up-your-organization) associated with the request.
	/// - Parameter projectId: The project associated with the request.
	/// - Parameter model: The model to use for the conversation. Can be changed later using the `model` property.
	///	- Parameter configuring: A closure to further configure the conversation.
	public convenience init(
		authToken: String,
		organizationId: String? = nil,
		projectId: String? = nil,
		using model: Model = .gpt5,
		configuring closure: (inout Config) -> Void = { _ in }
	) {
		self.init(client: ResponsesAPI(authToken: authToken, organizationId: organizationId, projectId: projectId), using: model, configuring: closure)
	}

	/// Creates a new conversation.
	///
	/// - Parameter request: The `URLRequest` to use for the API.
	/// - Parameter model: The model to use for the conversation. Can be changed later using the `model` property.
	///	- Parameter configuring: A closure to further configure the conversation.
	public convenience init(connectingTo request: URLRequest, using model: Model = .gpt5, configuring closure: (inout Config) -> Void = { _ in }) throws {
		try self.init(client: ResponsesAPI(connectingTo: request), using: model, configuring: closure)
	}

	/// Restarts the conversation, clearing all entries.
	public func restart() {
		entries.removeAll()
	}

	/// Sends a text message to the model and starts listening for a response in the background.
	///
	/// - Parameter text: The text message to send.
	@discardableResult public func send(text: String) -> Task<Void, Error> {
		send(.text(text))
	}

	/// Sends the output of a function call to the model and starts listening for a response in the background.
	///
	/// - Parameter functionCallOutput: The output of a function call.
	@discardableResult public func send(functionCallOutput: Item.FunctionCallOutput) -> Task<Void, Error> {
		send(.list([.item(.functionCallOutput(functionCallOutput))]))
	}

	/// Sends the output of a computer tool call to the model and starts listening for a response in the background.
	///
	/// - Parameter computerCallOutput: The output of a computer tool call.
	@discardableResult public func send(computerCallOutput: Item.ComputerToolCallOutput) -> Task<Void, Error> {
		send(.list([.item(.computerToolCallOutput(computerCallOutput))]))
	}

	/// Responds to an MCP approval request and starts listening for a response in the background.
	///
	/// - Parameter mcpApprovalResponse: The MCP approval response to send.
	@discardableResult public func send(mcpApprovalResponse: Item.MCPApprovalResponse) -> Task<Void, Error> {
		send(.list([.item(.mcpApprovalResponse(mcpApprovalResponse))]))
	}

	/// Informs the model of the output of a local shell call and starts listening for a response in the background.
	///
	/// - Parameter localShellCallOutput: The output of a local shell call.
	@discardableResult public func send(localShellCallOutput: Item.LocalShellCallOutput) -> Task<Void, Error> {
		send(.list([.item(.localShellCallOutput(localShellCallOutput))]))
	}

	/// Sends a message to the model and starts listening for a response in the background.
	///
	/// - Parameter input: Text, image, or file inputs to the model, used to generate a response.
	@discardableResult public func send(_ input: [Item.Input]) -> Task<Void, Error> {
		send(.list(input.map { .item($0) }))
	}

	/// Sends a message to the model and starts listening for a response in the background.
	///
	/// - Parameter input: Text, image, or file inputs to the model, used to generate a response.
	@discardableResult public func send(_ input: Input) -> Task<Void, Error> {
		return Task.detached(priority: .userInitiated) {
			do { try await self.sendAndWaitForResponses(input) }
			catch {
				print(error)
				throw error
			}
		}
	}

	/// Sends a message to the model and waits for the response.
	///
	/// - Parameter input: Text, image, or file inputs to the model, used to generate a response.
	@concurrent public nonisolated func sendAndWaitForResponses(_ input: Input) async throws {
		let request = await Request(
			model: config.model,
			input: input,
			include: config.include,
			instructions: config.instructions,
			maxOutputTokens: config.maxOutputTokens,
			maxToolCalls: config.maxToolCalls,
			metadata: config.metadata,
			parallelToolCalls: config.parallelToolCalls,
			previousResponseId: previousResponseId,
			prompt: config.prompt,
			promptCacheKey: config.promptCacheKey,
			reasoning: config.reasoning,
			safetyIdentifier: config.safetyIdentifier,
			serviceTier: config.serviceTier,
			temperature: config.temperature,
			text: config.text,
			toolChoice: config.toolChoice,
			tools: config.toolsWithFunctions,
			topLogprobs: config.topLogprobs,
			topP: config.topP,
			truncation: config.truncation,
		)

		await MainActor.run { self.entries.append(.request(request)) }
		let stream = switch await Result(catching: { try await client.stream(request) }) {
			case let .success(stream): stream
			case let .failure(error):
				await MainActor.run { _ = self.entries.popLast() }
				throw error
		}

		for try await event in stream {
			try await handleEvent(event)
			try Task.checkCancellation()
		}

		try await runFunctionsIfNeeded()
	}

	/// Uploads a file for later use in the API.
	///
	/// - Parameter file: The file to upload.
	/// - Parameter purpose: The intended purpose of the file.
	@concurrent public nonisolated func upload(file: File.Upload) async throws -> File {
		try await client.upload(file: file, purpose: .userData)
	}
}

// MARK: - Function handling

private extension Conversation {
	nonisolated func runFunctionsIfNeeded() async throws {
		let functions = await functions
		guard let lastResponse = await lastResponse, !functions.isEmpty else { return }

		let results = try await withThrowingTaskGroup(of: Item.FunctionCallOutput.self) { taskGroup in
			lastResponse.output.compactMap { item in
				if case let .functionCall(fnCall) = item { return fnCall }
				return nil
			}.forEach { fnCall in
				guard let function = functions.first(where: { $0.name == fnCall.name }) else { return }

				taskGroup.addTask { try await function.respond(to: fnCall) }
			}

			var results = [Item.FunctionCallOutput]()
			while let fnCallOutput = try await taskGroup.next() {
				results.append(fnCallOutput)
			}
			return results
		}

		guard !results.isEmpty else { return }

		try await sendAndWaitForResponses(.list(results.map { .item(.functionCallOutput($0)) }))
	}
}

// MARK: - Conversation stream handling

private extension Conversation {
	/// Handles an event from the conversation stream.
	func handleEvent(_ event: Event) throws {
		if config.debug == true { print(event) }

		switch event {
			case let .responseCreated(response):
				entries.append(.response(response))
			case let .responseInProgress(response):
				updateResponse(id: response.id) { $0 = response }
			case let .responseCompleted(response):
				updateResponse(id: response.id) { $0 = response }
			case let .responseFailed(response: response):
				updateResponse(id: response.id) { $0 = response }
			case let .responseIncomplete(response: response):
				updateResponse(id: response.id) { $0 = response }
			case let .responseQueued(response: response):
				updateResponse(id: response.id) { $0 = response }
			case let .outputItemAdded(item, outputIndex):
				updateResponse { $0.output.insert(item, at: Int(outputIndex)) }
			case let .outputItemDone(item, outputIndex):
				updateItem(index: outputIndex, id: item.id) { $0 = item }
			case let .contentPartAdded(contentIndex, itemId, outputIndex, part):
				updateMessage(index: outputIndex, id: itemId) { message in
					message.content.insert(part, at: Int(contentIndex))
				}
			case let .contentPartDone(contentIndex, itemId, outputIndex, part):
				updateMessage(index: outputIndex, id: itemId) { message in
					message.content[Int(contentIndex)] = part
				}
			case let .outputTextDelta(contentIndex, delta, itemId, outputIndex, logprobs):
				updateMessage(index: outputIndex, id: itemId) { message in
					guard case let .text(text, annotations, existingLogprobs) = message.content[Int(contentIndex)] else { return }

					message.content[Int(contentIndex)] = .text(text: text + delta, annotations: annotations, logprobs: existingLogprobs + logprobs)
				}
			case let .outputTextDone(contentIndex, itemId, outputIndex, text, logprobs):
				updateMessage(index: outputIndex, id: itemId) { message in
					guard case let .text(_, annotations, _) = message.content[Int(contentIndex)] else { return }

					message.content[Int(contentIndex)] = .text(text: text, annotations: annotations, logprobs: logprobs)
				}
			case let .outputTextAnnotationAdded(annotation, annotationIndex, contentIndex, itemId, outputIndex):
				updateMessage(index: outputIndex, id: itemId) { message in
					guard case .text(let text, var annotations, _) = message.content[Int(contentIndex)] else { return }

					annotations.insert(annotation, at: Int(annotationIndex))
					message.content[Int(contentIndex)] = .text(text: text, annotations: annotations)
				}
			case let .refusalDelta(contentIndex, delta, itemId, outputIndex):
				updateMessage(index: outputIndex, id: itemId) { message in
					guard case let .refusal(refusal) = message.content[Int(contentIndex)] else { return }

					message.content[Int(contentIndex)] = .refusal(refusal + delta)
				}
			case let .refusalDone(contentIndex, itemId, outputIndex, refusal):
				updateMessage(index: outputIndex, id: itemId) { message in
					guard case .refusal = message.content[Int(contentIndex)] else { return }

					message.content[Int(contentIndex)] = .refusal(refusal)
				}
			case let .functionCallArgumentsDelta(delta, itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .functionCall(functionCall) = item else { return }

					functionCall.arguments += delta

					item = .functionCall(functionCall)
				}
			case let .functionCallArgumentsDone(arguments, itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .functionCall(functionCall) = item else { return }

					functionCall.arguments = arguments

					item = .functionCall(functionCall)
				}
			case let .webSearchCallInitiated(itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .webSearchCall(webSearch) = item else { return }

					webSearch.status = .inProgress
					item = .webSearchCall(webSearch)
				}
			case let .webSearchCallSearching(itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .webSearchCall(webSearch) = item else { return }

					webSearch.status = .searching
					item = .webSearchCall(webSearch)
				}
			case let .webSearchCallCompleted(itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .webSearchCall(webSearch) = item else { return }

					webSearch.status = .completed
					item = .webSearchCall(webSearch)
				}
			case let .error(error):
				throw error
			case let .fileSearchCallInitiated(itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .fileSearch(fileSearch) = item else { return }

					fileSearch.status = .inProgress
					item = .fileSearch(fileSearch)
				}
			case let .fileSearchCallSearching(itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .fileSearch(fileSearch) = item else { return }

					fileSearch.status = .searching
					item = .fileSearch(fileSearch)
				}
			case let .fileSearchCallCompleted(itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .fileSearch(fileSearch) = item else { return }

					fileSearch.status = .completed
					item = .fileSearch(fileSearch)
				}
			case let .reasoningSummaryPartAdded(itemId, outputIndex: outputIndex, part, summaryIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .reasoning(reasoning) = item else { return }

					reasoning.summary[Int(summaryIndex)] = part

					item = .reasoning(reasoning)
				}
			case let .reasoningSummaryPartDone(itemId, outputIndex, summaryIndex, part):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .reasoning(reasoning) = item else { return }

					reasoning.summary[Int(summaryIndex)] = part

					item = .reasoning(reasoning)
				}
			case let .reasoningSummaryDelta(itemId, outputIndex, summaryIndex, delta):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .reasoning(reasoning) = item else { return }

					// figure out where to put the reasoning
				}
			case let .reasoningSummaryDone(itemId, outputIndex, summaryIndex, text):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .reasoning(reasoning) = item else { return }

					// figure out where to put the reasoning
				}
			case let .reasoningSummaryTextDelta(itemId, outputIndex, summaryIndex, delta):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .reasoning(reasoning) = item, var summary = reasoning.summary[safe: Int(summaryIndex)] else { return }

					summary.text += delta

					reasoning.summary[Int(summaryIndex)] = summary
					item = .reasoning(reasoning)
				}
			case let .reasoningSummaryTextDone(itemId, outputIndex, summaryIndex, text):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .reasoning(reasoning) = item, var summary = reasoning.summary[safe: Int(summaryIndex)] else { return }

					summary.text = text

					reasoning.summary[Int(summaryIndex)] = summary
					item = .reasoning(reasoning)
				}
			case let .imageGenerationCallInProgress(itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .imageGenerationCall(imageGenerationCall) = item else { return }

					imageGenerationCall.status = .inProgress

					item = .imageGenerationCall(imageGenerationCall)
				}
			case let .imageGenerationCallGenerating(itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .imageGenerationCall(imageGenerationCall) = item else { return }

					imageGenerationCall.status = .generating

					item = .imageGenerationCall(imageGenerationCall)
				}
			case let .imageGenerationCallPartialImage(itemId, outputIndex, partialImageB64, partialImageIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .imageGenerationCall(imageGenerationCall) = item,
					      let partialImage = Data(base64Encoded: partialImageB64) else { return }

					if imageGenerationCall.partialImages == nil { imageGenerationCall.partialImages = [] }
					imageGenerationCall.partialImages![Int(partialImageIndex)] = partialImage

					item = .imageGenerationCall(imageGenerationCall)
				}
			case let .imageGenerationCallCompleted(itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .imageGenerationCall(imageGenerationCall) = item else { return }

					imageGenerationCall.status = .completed

					item = .imageGenerationCall(imageGenerationCall)
				}
			case let .mcpCallArgumentsDelta(itemId, outputIndex, delta):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .mcpToolCall(mcpToolCall) = item else { return }

					mcpToolCall.arguments += delta

					item = .mcpToolCall(mcpToolCall)
				}
			case let .mcpCallArgumentsDone(itemId, outputIndex, arguments):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .mcpToolCall(mcpToolCall) = item else { return }

					mcpToolCall.arguments = arguments

					item = .mcpToolCall(mcpToolCall)
				}
			case .mcpCallCompleted:
				break // mcpToolCall does not have a status field we can track
			case .mcpCallFailed:
				break // mcpToolCall does not have a status field we can track
			case let .mcpCallInProgress(itemId, outputIndex):
				break // mcpToolCall does not have a status field we can track
			case let .mcpListToolsCompleted(itemId, outputIndex):
				break // mcpListTools does not have a status field we can track
			case .mcpListToolsFailed:
				break // mcpListTools does not have a status field we can track
			case let .mcpListToolsInProgress(itemId, outputIndex):
				break // mcpListTools does not have a status field we can track
			case let .codeInterpreterCallInProgress(itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .codeInterpreterCall(codeInterpreterCall) = item else { return }

					codeInterpreterCall.status = .inProgress

					item = .codeInterpreterCall(codeInterpreterCall)
				}
			case let .codeInterpreterCallInterpreting(itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .codeInterpreterCall(codeInterpreterCall) = item else { return }

					codeInterpreterCall.status = .interpreting

					item = .codeInterpreterCall(codeInterpreterCall)
				}
			case let .codeInterpreterCallCompleted(itemId, outputIndex):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .codeInterpreterCall(codeInterpreterCall) = item else { return }

					codeInterpreterCall.status = .completed

					item = .codeInterpreterCall(codeInterpreterCall)
				}
			case let .codeInterpreterCallCodeDelta(itemId, outputIndex, delta):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .codeInterpreterCall(codeInterpreterCall) = item else { return }

					if codeInterpreterCall.code == nil { codeInterpreterCall.code = delta }
					else { codeInterpreterCall.code! += delta }

					item = .codeInterpreterCall(codeInterpreterCall)
				}
			case let .codeInterpreterCallCodeDone(itemId, outputIndex, code):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .codeInterpreterCall(codeInterpreterCall) = item else { return }

					codeInterpreterCall.code = code

					item = .codeInterpreterCall(codeInterpreterCall)
				}
			case let .customToolCallInputDelta(itemId, outputIndex, delta):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .customToolCall(customToolCall) = item else { return }

					customToolCall.input += delta

					item = .customToolCall(customToolCall)
				}
			case let .customToolCallInputDone(itemId, outputIndex, input):
				updateItem(index: outputIndex, id: itemId) { item in
					guard case var .customToolCall(customToolCall) = item else { return }

					customToolCall.input = input

					item = .customToolCall(customToolCall)
				}
		}
	}

	/// Helper function to update a response in the conversation.
	///
	/// - Parameter id: The ID of the response to update.
	/// - Parameter closure: A closure that takes the response and updates it.
	func updateResponse(id: String, modifying closure: (inout Response) -> Void) {
		guard let index = entries.firstIndex(where: { entry in
			guard case let .response(response) = entry else { return false }
			return response.id == id
		}), case var .response(response) = entries[index] else { return }

		closure(&response)

		entries[index] = .response(response)
	}

	/// Helper function to update the most recent response in the conversation.
	///
	/// - Parameter closure: A closure that takes the current response and updates it.
	func updateResponse(modifying closure: (inout Response) -> Void) {
		if let previousResponseId {
			updateResponse(id: previousResponseId, modifying: closure)
		}
	}

	/// Helper function to update an item in the most recent response in the conversation.
	///
	/// - Parameter index: The index of the item to update.
	/// - Parameter itemId: The ID of the item to update.
	/// - Parameter closure: A closure that takes the item and updates it.
	func updateItem(index: UInt, id itemId: String, modifying closure: (inout Item.Output) -> Void) {
		guard let previousResponseId else { return }

		updateResponse(id: previousResponseId) { response in
			guard index < response.output.count else { return }

			var item = response.output[Int(index)]
			guard item.id == itemId else { return }

			closure(&item)

			response.output[Int(index)] = item
		}
	}

	/// Helper function to update a message in the most recent response in the conversation.
	///
	/// - Parameter index: The index of the item that contains the message.
	/// - Parameter itemId: The ID of the item that contains the message.
	/// - Parameter closure: A closure that takes the message and updates it.
	func updateMessage(index outputIndex: UInt, id itemId: String, modifying closure: (inout Message.Output) -> Void) {
		updateItem(index: outputIndex, id: itemId) { item in
			guard case var .message(message) = item else { return }

			closure(&message)

			item = .message(message)
		}
	}
}

// MARK: - Conversation.Config

public extension Conversation {
	/// Configuration options for a conversation.
	struct Config: Sendable {
		/// Model ID used to generate the response.
		///
		/// OpenAI offers a wide range of models with different capabilities, performance characteristics, and price points. Refer to the [model guide](https://platform.openai.com/docs/models) to browse and compare available models.
		public var model: Model

		/// Specify additional output data to include in the model response.
		public var include: [Request.Include]?

		/// Inserts a system (or developer) message as the first item in the model's context.
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

		/// Reference to a prompt template and its variables. [Learn more](https://platform.openai.com/docs/guides/text?api-mode=responses#reusable-prompts).
		public var prompt: Prompt?

		/// Used by OpenAI to cache responses for similar requests to optimize your cache hit rates.
		///
		/// Replaces the `user` field. [Learn more](https://platform.openai.com/docs/guides/prompt-caching).
		public var promptCacheKey: String?

		/// Configuration options for [reasoning models](https://platform.openai.com/docs/guides/reasoning).
		public var reasoning: ReasoningConfig?

		/// A stable identifier used to help detect users of your application that may be violating OpenAI's usage policies.
		///
		/// The IDs should be a string that uniquely identifies each user. We recommend hashing their username or email address, in order to avoid sending us any identifying information.
		/// - [Safety Identifiers](https://platform.openai.com/docs/guides/safety-best-practices#safety-identifiers)
		public var safetyIdentifier: String?

		/// Specifies the latency tier to use for processing the request
		public var serviceTier: ServiceTier?

		/// What sampling temperature to use, between 0 and 2.
		///
		/// Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
		///
		/// We generally recommend altering this or `topP` but not both.
		public var temperature: Double?

		/// Configuration options for a text response from the model. Can be plain text or structured JSON data.
		///
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
		///
		/// > Warning: Function calls defined here will not be executed automatically.
		/// > Use the `functions` parameter to have those handled for you.
		public var tools: [Tool]?

		/// An array of local functions the model may call while generating a response.
		public var functions: [any Toolable]?

		/// An integer between 0 and 20 specifying the number of most likely tokens to return at each token position, each with an associated log probability.
		public var topLogprobs: UInt?

		/// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with `top_p` probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
		///
		/// We generally recommend altering this or `temperature` but not both.
		public var topP: Double?

		/// The truncation strategy to use for the model response.
		public var truncation: Truncation?

		/// Enables debug mode for the conversation.
		///
		/// When enabled, the conversation will log additional information to the console, such as the event stream received from the API.
		public var debug: Bool?

		/// A list of tools the model can call while generating a response, including automatically executed functions.
		var toolsWithFunctions: [Tool] {
			var tools = [Tool]()

			tools.append(contentsOf: self.tools ?? [])
			tools.append(contentsOf: functions?.map { .function($0) } ?? [])

			return tools
		}
	}

	/// Model ID used to generate the response.
	///
	/// OpenAI offers a wide range of models with different capabilities, performance characteristics, and price points. Refer to the [model guide](https://platform.openai.com/docs/models) to browse and compare available models.
	var model: Model {
		get { config.model }
		set { config.model = newValue }
	}

	/// Specify additional output data to include in the model response.
	var include: [Request.Include]? {
		get { config.include }
		set { config.include = newValue }
	}

	/// Inserts a system (or developer) message as the first item in the model's context.
	var instructions: String? {
		get { config.instructions }
		set { config.instructions = newValue }
	}

	/// An upper bound for the number of tokens that can be generated for a response, including visible output tokens and [reasoning tokens](https://platform.openai.com/docs/guides/reasoning).
	var maxOutputTokens: UInt? {
		get { config.maxOutputTokens }
		set { config.maxOutputTokens = newValue }
	}

	/// The maximum number of total calls to built-in tools that can be processed in a response.
	///
	/// This maximum number applies across all built-in tool calls, not per individual tool.
	///
	/// Any further attempts to call a tool by the model will be ignored.
	var maxToolCalls: UInt? {
		get { config.maxToolCalls }
		set { config.maxToolCalls = newValue }
	}

	/// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format, and querying for objects via API or the dashboard.
	///
	/// Keys are strings with a maximum length of 64 characters. Values are strings with a maximum length of 512 characters.
	var metadata: [String: String]? {
		get { config.metadata }
		set { config.metadata = newValue }
	}

	/// Whether to allow the model to run tool calls in parallel.
	var parallelToolCalls: Bool? {
		get { config.parallelToolCalls }
		set { config.parallelToolCalls = newValue }
	}

	/// Reference to a prompt template and its variables. [Learn more](https://platform.openai.com/docs/guides/text?api-mode=responses#reusable-prompts).
	var prompt: Prompt? {
		get { config.prompt }
		set { config.prompt = newValue }
	}

	/// Used by OpenAI to cache responses for similar requests to optimize your cache hit rates.
	///
	/// Replaces the `user` field. [Learn more](https://platform.openai.com/docs/guides/prompt-caching).
	var promptCacheKey: String? {
		get { config.promptCacheKey }
		set { config.promptCacheKey = newValue }
	}

	/// Configuration options for [reasoning models](https://platform.openai.com/docs/guides/reasoning).
	var reasoning: ReasoningConfig? {
		get { config.reasoning }
		set { config.reasoning = newValue }
	}

	/// A stable identifier used to help detect users of your application that may be violating OpenAI's usage policies.
	///
	/// The IDs should be a string that uniquely identifies each user. We recommend hashing their username or email address, in order to avoid sending us any identifying information.
	/// - [Safety Identifiers](https://platform.openai.com/docs/guides/safety-best-practices#safety-identifiers)
	var safetyIdentifier: String? {
		get { config.safetyIdentifier }
		set { config.safetyIdentifier = newValue }
	}

	/// Specifies the latency tier to use for processing the request
	var serviceTier: ServiceTier? {
		get { config.serviceTier }
		set { config.serviceTier = newValue }
	}

	/// What sampling temperature to use, between 0 and 2.
	///
	/// Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
	///
	/// We generally recommend altering this or `topP` but not both.
	var temperature: Double? {
		get { config.temperature }
		set { config.temperature = newValue }
	}

	/// Configuration options for a text response from the model. Can be plain text or structured JSON data.
	///
	/// - [Text inputs and outputs](https://platform.openai.com/docs/guides/text)
	/// - [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs)
	var text: TextConfig? {
		get { config.text }
		set { config.text = newValue }
	}

	/// How the model should select which tool (or tools) to use when generating a response.
	///
	/// See the `tools` parameter to see how to specify which tools the model can call.
	var toolChoice: Tool.Choice? {
		get { config.toolChoice }
		set { config.toolChoice = newValue }
	}

	/// An array of tools the model may call while generating a response. You can specify which tool to use by setting the `tool_choice` parameter.
	///
	/// The two categories of tools you can provide the model are:
	/// - **Built-in tools**: Tools that are provided by OpenAI that extend the model's capabilities, like [web search](https://platform.openai.com/docs/guides/tools-web-search) or [file search](https://platform.openai.com/docs/guides/tools-file-search). Learn more about [built-in tools](https://platform.openai.com/docs/guides/tools).
	/// - **Function calls (custom tools)**: Functions that are defined by you, enabling the model to call your own code. Learn more about [function calling](https://platform.openai.com/docs/guides/function-calling).
	///
	/// > Warning: Function calls defined here will not be executed automatically.
	/// > Use the `functions` parameter to have those handled for you.
	var tools: [Tool]? {
		get { config.tools }
		set { config.tools = newValue }
	}

	/// An array of local functions the model may call while generating a response.
	var functions: [any Toolable] {
		get { config.functions ?? [] }
		set { config.functions = newValue }
	}

	/// An integer between 0 and 20 specifying the number of most likely tokens to return at each token position, each with an associated log probability.
	var topLogprobs: UInt? {
		get { config.topLogprobs }
		set { config.topLogprobs = newValue }
	}

	/// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with `top_p` probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
	///
	/// We generally recommend altering this or `temperature` but not both.
	var topP: Double? {
		get { config.topP }
		set { config.topP = newValue }
	}

	/// The truncation strategy to use for the model response.
	var truncation: Truncation? {
		get { config.truncation }
		set { config.truncation = newValue }
	}

	/// Enables debug mode for the conversation.
	///
	/// When enabled, the conversation will log additional information to the console, such as the event stream received from the API.
	var debug: Bool? {
		get { config.debug }
		set { config.debug = newValue }
	}

	/// Updates the conversation configuration.
	///
	/// - Parameter closure: A function that takes the current configuration and updates it.
	func updateConfig(_ closure: (inout Config) -> Void) {
		closure(&config)
	}
}
