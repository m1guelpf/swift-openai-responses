import Foundation
import MetaCodable

/// A streaming event emitted by the Responses API
@Codable @CodedAt("type") @CodingKeys(.snake_case) public enum Event: Equatable, Sendable {
	/// An event that is emitted when a response is created.
	///
	/// - Parameter response: The response that was created.
	@CodedAs("response.created")
	case responseCreated(response: Response)

	/// Emitted when the response is in progress.
	///
	/// - Parameter response: The response that is in progress.
	@CodedAs("response.in_progress")
	case responseInProgress(response: Response)

	/// Emitted when the model response is complete.
	///
	/// - Parameter response: The response that is completed.
	@CodedAs("response.completed")
	case responseCompleted(response: Response)

	/// An event that is emitted when a response fails.
	///
	/// - Parameter response: The response that failed.
	@CodedAs("response.failed")
	case responseFailed(response: Response)

	/// An event that is emitted when a response finishes as incomplete.
	///
	/// - Parameter response: The response that is incomplete.
	@CodedAs("response.incomplete")
	case responseIncomplete(response: Response)

	/// Emitted when a response is queued and waiting to be processed.
	///
	/// - Parameter response: The full response object that is queued.
	case responseQueued(response: Response)

	/// Emitted when a new output item is added.
	///
	/// - Parameter item: The output item that was added.
	/// - Parameter outputIndex: The index of the output item that was added.
	@CodedAs("response.output_item.added")
	case outputItemAdded(item: Item.Output, outputIndex: UInt)

	/// Emitted when an output item is marked done.
	///
	/// - Parameter item: The output item that was marked done.
	/// - Parameter outputIndex: The index of the output item that was marked done.
	@CodedAs("response.output_item.done")
	case outputItemDone(item: Item.Output, outputIndex: UInt)

	/// Emitted when a new content part is added.
	///
	/// - Parameter contentIndex: The index of the content part that was added.
	/// - Parameter itemId: The ID of the output item that the content part was added to.
	/// - Parameter outputIndex: The index of the output item that the content part was added to.
	/// - Parameter part: The content part that was added.
	@CodedAs("response.content_part.added")
	case contentPartAdded(
		contentIndex: UInt,
		itemId: String,
		outputIndex: UInt,
		part: Item.Output.Content
	)

	/// Emitted when a content part is done.
	///
	/// - Parameter contentIndex: The index of the content part that is done.
	/// - Parameter itemId: The ID of the output item that the content part was added to.
	/// - Parameter outputIndex: The index of the output item that the content part was added to.
	/// - Parameter part: The content part that is done.
	@CodedAs("response.content_part.done")
	case contentPartDone(
		contentIndex: UInt,
		itemId: String,
		outputIndex: UInt,
		part: Item.Output.Content
	)

	/// Emitted when there is an additional text delta.
	///
	/// - Parameter contentIndex: The index of the content part that the text delta was added to.
	/// - Parameter delta: The text delta that was added.
	/// - Parameter itemId: The ID of the output item that the text delta was added to.
	/// - Parameter outputIndex: The index of the output item that the text delta was added to.
	/// - Parameter logprobs: The log probabilities for the text delta that was added.
	@CodedAs("response.output_text.delta")
	case outputTextDelta(
		contentIndex: UInt,
		delta: String,
		itemId: String,
		outputIndex: UInt,
		logprobs: [Item.Output.Content.LogProb]
	)

	/// Emitted when a text annotation is added.
	///
	/// - Parameter annotation: The annotation that was added.
	/// - Parameter annotationIndex: The index of the annotation that was added.
	/// - Parameter contentIndex: The index of the content part that the text annotation was added to.
	/// - Parameter itemId: The ID of the output item that the text annotation was added to.
	/// - Parameter outputIndex: The index of the output item that the text annotation was added to.
	@CodedAs("response.output_text.annotation.added")
	case outputTextAnnotationAdded(
		annotation: Item.Output.Content.Annotation,
		annotationIndex: UInt,
		contentIndex: UInt,
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when text content is finalized.
	///
	/// - Parameter contentIndex: The index of the content part that the text content is finalized.
	/// - Parameter itemId: The ID of the output item that the text content is finalized.
	/// - Parameter outputIndex: The index of the output item that the text content is finalized.
	/// - Parameter text: The text content that is finalized.
	/// - Parameter logprobs: The log probabilities for the text content that is finalized.
	@CodedAs("response.output_text.done")
	case outputTextDone(
		contentIndex: UInt,
		itemId: String,
		outputIndex: UInt,
		text: String,
		logprobs: [Item.Output.Content.LogProb]
	)

	/// Emitted when there is a partial refusal text.
	///
	/// - Parameter contentIndex: The index of the content part that the refusal text is added to.
	/// - Parameter delta: The refusal text that is added.
	/// - Parameter itemId: The ID of the output item that the refusal text is added to.
	/// - Parameter outputIndex: The index of the output item that the refusal text is added to.
	@CodedAs("response.refusal.delta")
	case refusalDelta(
		contentIndex: UInt,
		delta: String,
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when refusal text is finalized.
	///
	/// - Parameter contentIndex: The index of the content part that the refusal text is finalized.
	/// - Parameter itemId: The ID of the output item that the refusal text is finalized.
	/// - Parameter outputIndex: The index of the output item that the refusal text is finalized.
	/// - Parameter refusal: The refusal text that is finalized.
	@CodedAs("response.refusal.done")
	case refusalDone(
		contentIndex: UInt,
		itemId: String,
		outputIndex: UInt,
		refusal: String
	)

	/// Emitted when there is a partial function-call arguments delta.
	///
	/// - Parameter delta: The function-call arguments delta that is added.
	/// - Parameter itemId: The ID of the output item that the function-call arguments delta is added to.
	/// - Parameter outputIndex: The index of the output item that the function-call arguments delta is added to.
	@CodedAs("response.function_call_arguments.delta")
	case functionCallArgumentsDelta(
		delta: String,
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when function-call arguments are finalized.
	///
	/// - Parameter arguments: The function-call arguments.
	/// - Parameter itemId: The ID of the item.
	/// - Parameter outputIndex: The index of the output item.
	@CodedAs("response.function_call_arguments.done")
	case functionCallArgumentsDone(
		arguments: String,
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when a file search call is initiated.
	///
	/// - Parameter itemId: The ID of the output item that the file search call is initiated.
	/// - Parameter outputIndex: The index of the output item that the file search call is initiated.
	@CodedAs("response.file_search_call.in_progress")
	case fileSearchCallInitiated(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when a file search is currently searching.
	///
	/// - Parameter itemId: The ID of the output item that the file search call is searching.
	/// - Parameter outputIndex: The index of the output item that the file search call is searching.
	@CodedAs("response.file_search_call.searching")
	case fileSearchCallSearching(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when a file search call is completed (results found).
	///
	/// - Parameter itemId: The ID of the output item that the file search call completed at.
	/// - Parameter outputIndex: The index of the output item that the file search call completed at.
	@CodedAs("response.file_search_call.completed")
	case fileSearchCallCompleted(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when a web search call is initiated.
	///
	/// - Parameter itemId: Unique ID for the output item associated with the web search call.
	/// - Parameter outputIndex: The index of the output item that the web search call is associated with.
	@CodedAs("response.web_search_call.in_progress")
	case webSearchCallInitiated(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when a web search call is executing.
	///
	/// - Parameter itemId: Unique ID for the output item associated with the web search call.
	/// - Parameter outputIndex: The index of the output item that the web search call is associated with.
	@CodedAs("response.web_search_call.searching")
	case webSearchCallSearching(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when a web search call is completed.
	///
	/// - Parameter itemId: Unique ID for the output item associated with the web search call.
	/// - Parameter outputIndex: The index of the output item that the web search call is associated with.
	@CodedAs("response.web_search_call.completed")
	case webSearchCallCompleted(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when a new reasoning summary part is added.
	///
	/// - Parameter itemId: The ID of the item this summary part is associated with.
	/// - Parameter outputIndex: The index of the output item this summary part is associated with.
	/// - Parameter part: The summary part that was added.
	/// - Parameter summaryIndex: The index of the summary part within the reasoning summary.
	@CodedAs("response.reasoning_summary_part.added")
	case reasoningSummaryPartAdded(
		itemId: String,
		outputIndex: UInt,
		part: Item.Reasoning.Summary,
		summaryIndex: UInt
	)

	/// Emitted when a new reasoning summary part is added.
	///
	/// - Parameter itemId: The ID of the item this summary part is associated with.
	/// - Parameter outputIndex: The index of the output item this summary part is associated with.
	/// - Parameter summaryIndex: The index of the summary part within the reasoning summary.
	/// - Parameter part: The completed summary part.
	@CodedAs("response.reasoning_summary_part.done")
	case reasoningSummaryPartDone(
		itemId: String,
		outputIndex: UInt,
		summaryIndex: UInt,
		part: Item.Reasoning.Summary
	)

	/// Emitted when there is a delta (partial update) to the reasoning summary content.
	///
	/// - Parameter itemId: The unique identifier of the item for which the reasoning summary is being updated.
	/// - Parameter outputIndex: The index of the output item in the response's output array.
	/// - Parameter summaryIndex: The index of the reasoning summary part within the output item.
	/// - Parameter delta: The partial update to the reasoning summary content.
	@CodedAs("response.reasoning_summary.delta")
	case reasoningSummaryDelta(
		itemId: String,
		outputIndex: UInt,
		summaryIndex: UInt,
		delta: Item.Reasoning.SummaryDelta
	)

	/// Emitted when the reasoning summary content is finalized for an item.
	///
	/// - Parameter itemId: The unique identifier of the item for which the reasoning summary is finalized.
	/// - Parameter outputIndex: The index of the output item in the response's output array.
	/// - Parameter summaryIndex: The index of the summary part within the output item.
	/// - Parameter text: The finalized reasoning summary text.
	@CodedAs("response.reasoning_summary.done")
	case reasoningSummaryDone(
		itemId: String,
		outputIndex: UInt,
		summaryIndex: UInt,
		text: String
	)

	/// Emitted when a delta is added to a reasoning summary text.
	///
	/// - Parameter itemId: The ID of the item this summary text delta is associated with.
	/// - Parameter outputIndex: The index of the output item this summary text delta is associated with.
	/// - Parameter summaryIndex: The index of the summary part within the reasoning summary.
	/// - Parameter delta: The text delta that was added to the summary.
	@CodedAs("response.reasoning_summary_text.delta")
	case reasoningSummaryTextDelta(
		itemId: String,
		outputIndex: UInt,
		summaryIndex: UInt,
		delta: String
	)

	/// Emitted when a delta is added to a reasoning summary text.
	///
	/// - Parameter itemId: The ID of the item this summary text delta is associated with.
	/// - Parameter outputIndex: The index of the output item this summary text delta is associated with.
	/// - Parameter summaryIndex: The index of the summary part within the reasoning summary.
	/// - Parameter text: The full text of the completed reasoning summary.
	@CodedAs("response.reasoning_summary_text.done")
	case reasoningSummaryTextDone(
		itemId: String,
		outputIndex: UInt,
		summaryIndex: UInt,
		text: String
	)

	/// Emitted when an image generation tool call is in progress.
	///
	/// - Parameter itemId: The unique identifier of the image generation item being processed.
	/// - Parameter outputIndex: The index of the output item in the response's output array.
	@CodedAs("response.image_generation_call.in_progress")
	case imageGenerationCallInProgress(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when an image generation tool call is actively generating an image (intermediate state).
	///
	/// - Parameter itemId: The unique identifier of the image generation item being processed.
	/// - Parameter outputIndex: The index of the output item in the response's output array.
	@CodedAs("response.image_generation_call.generating")
	case imageGenerationCallGenerating(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when a partial image is available during image generation streaming.
	///
	/// - Parameter itemId: The unique identifier of the image generation item being processed.
	/// - Parameter outputIndex: The index of the output item in the response's output array.
	/// - Parameter partialImage: Partial image data, suitable for rendering as an image.
	/// - Parameter partialImageIndex: Index for the partial image
	@CodedAs("response.image_generation_call.partial_image")
	case imageGenerationCallPartialImage(
		itemId: String,
		outputIndex: UInt,
		partialImageB64: String,
		partialImageIndex: UInt
	)

	/// Emitted when an image generation tool call has completed and the final image is available.
	///
	/// - Parameter itemId: The unique identifier of the image generation item being processed.
	/// - Parameter outputIndex: The index of the output item in the response's output array.
	@CodedAs("response.image_generation_call.completed")
	case imageGenerationCallCompleted(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when there is a delta (partial update) to the arguments of an MCP tool call.
	///
	/// - Parameter itemId: The unique identifier of the MCP tool call item being processed.
	/// - Parameter outputIndex: The index of the output item in the response's output array.
	/// - Parameter delta: The partial update to the arguments for the MCP tool call.
	@CodedAs("response.mcp_call_arguments.delta")
	case mcpCallArgumentsDelta(
		itemId: String,
		outputIndex: UInt,
		delta: String
	)

	/// Emitted when the arguments for an MCP tool call are finalized.
	///
	/// - Parameter itemId: The unique identifier of the MCP tool call item being processed.
	/// - Parameter outputIndex: The index of the output item in the response's output array.
	/// - Parameter arguments: The finalized arguments for the MCP tool call.
	@CodedAs("response.mcp_call_arguments.done")
	case mcpCallArgumentsDone(
		itemId: String,
		outputIndex: UInt,
		arguments: String
	)

	/// Emitted when an MCP tool call has completed successfully.
	///
	/// - Parameter itemId: The unique identifier of the MCP tool call item that completed.
	/// - Parameter outputIndex: The index of the output item in the response's output array.
	@CodedAs("response.mcp_call.completed")
	case mcpCallCompleted(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when an MCP tool call has failed.
	///
	/// - Parameter itemId: The unique identifier of the MCP tool call item that failed.
	/// - Parameter outputIndex: The index of the output item in the response's output array.
	@CodedAs("response.mcp_call.failed")
	case mcpCallFailed(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when an MCP tool call is in progress.
	///
	/// - Parameter itemId: The unique identifier of the MCP tool call item being processed.
	/// - Parameter outputIndex: The index of the output item in the response's output array.
	@CodedAs("response.mcp_call.in_progress")
	case mcpCallInProgress(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when the list of available MCP tools has been successfully retrieved.
	///
	/// - Parameter itemId: The unique identifier of the MCP tool list item that completed.
	/// - Parameter outputIndex: The index of the output item in the response for which the MCP tool list is being retrieved.
	@CodedAs("response.mcp_list_tools.completed")
	case mcpListToolsCompleted(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when the attempt to list available MCP tools has failed.
	///
	/// - Parameter itemId: The unique identifier of the MCP tool list item that failed.
	/// - Parameter outputIndex: The index of the output item in the response for which the MCP tool list is being retrieved.
	@CodedAs("response.mcp_list_tools.failed")
	case mcpListToolsFailed(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when the system is in the process of retrieving the list of available MCP tools.
	///
	/// - Parameter itemId: The unique identifier of the MCP tool list item in progress.
	/// - Parameter outputIndex: The index of the output item in the response for which the MCP tool list is being retrieved.
	@CodedAs("response.mcp_list_tools.in_progress")
	case mcpListToolsInProgress(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when a code interpreter call is in progress.
	///
	/// - Parameter itemId: The unique identifier of the code interpreter tool call item.
	/// - Parameter outputIndex: The index of the output item in the response for which the code interpreter call is in progress.
	@CodedAs("response.code_interpreter_call.in_progress")
	case codeInterpreterCallInProgress(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when the code interpreter is actively interpreting the code snippet.
	///
	/// - Parameter itemId: The unique identifier of the code interpreter tool call item.
	/// - Parameter outputIndex: The index of the output item in the response for which the code interpreter call is in progress.
	@CodedAs("response.code_interpreter_call.interpreting")
	case codeInterpreterCallInterpreting(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when the code interpreter call is completed.
	///
	/// - Parameter itemId: The unique identifier of the code interpreter tool call item.
	/// - Parameter outputIndex: The index of the output item in the response for which the code interpreter call is completed.
	@CodedAs("response.code_interpreter_call.completed")
	case codeInterpreterCallCompleted(
		itemId: String,
		outputIndex: UInt
	)

	/// Emitted when a partial code snippet is streamed by the code interpreter.
	///
	/// - Parameter itemId: The unique identifier of the code interpreter tool call item.
	/// - Parameter outputIndex: The index of the output item in the response for which the code is being streamed.
	/// - Parameter delta: The partial code snippet being streamed by the code interpreter.
	@CodedAs("response.code_interpreter_call_code.delta")
	case codeInterpreterCallCodeDelta(
		itemId: String,
		outputIndex: UInt,
		delta: String
	)

	/// Emitted when the code snippet is finalized by the code interpreter.
	///
	/// - Parameter itemId: The unique identifier of the code interpreter tool call item.
	/// - Parameter outputIndex: The index of the output item in the response for which the code is finalized.
	/// - Parameter code: The final code snippet output by the code interpreter.
	@CodedAs("response.code_interpreter_call_code.done")
	case codeInterpreterCallCodeDone(
		itemId: String,
		outputIndex: UInt,
		code: String
	)

	/// Event representing a delta (partial update) to the input of a custom tool call.
	///
	/// - Parameter itemId: Unique identifier for the API item associated with this event.
	/// - Parameter outputIndex: The index of the output this delta applies to.
	/// - Parameter delta: The incremental input data (delta) for the custom tool call.
	@CodedAs("response.custom_tool_call_input.delta")
	case customToolCallInputDelta(
		itemId: String,
		outputIndex: UInt,
		delta: String
	)

	/// Event representing a delta (partial update) to the input of a custom tool call.
	///
	/// - Parameter itemId: Unique identifier for the API item associated with this event.
	/// - Parameter outputIndex: The index of the output this delta applies to.
	/// - Parameter input: The complete input data for the custom tool call.
	@CodedAs("response.custom_tool_call_input.done")
	case customToolCallInputDone(
		itemId: String,
		outputIndex: UInt,
		input: String
	)

	/// Emitted when an error occurs.
	///
	/// - Parameter error: The error that occurred.
	@CodedAs("error")
	case error(error: Response.Error)
}
