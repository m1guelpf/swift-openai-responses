import Foundation
import MetaCodable

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
		item_id: String,
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
	@CodedAs("response.output_text.delta")
	case outputTextDelta(
		contentIndex: UInt,
		delta: String,
		itemId: String,
		outputIndex: UInt
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
	@CodedAs("response.output_text.done")
	case outputTextDone(
		contentIndex: UInt,
		itemId: String,
		outputIndex: UInt,
		text: String
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

	/// Emitted when an error occurs.
	///
	/// - Parameter code: The error code.
	/// - Parameter message: The error message.
	/// - Parameter param: The error parameter.
	@CodedAs("error")
	case error(
		code: String?,
		message: String,
		param: String?
	)
}
