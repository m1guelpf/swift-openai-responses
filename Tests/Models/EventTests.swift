import Foundation
import Nimble
import Testing
@testable import OpenAI

@Test
func codableEvents() throws {
	let response = createResponse()
	let events: [Event] = [
		// Response events
		.responseCreated(response: response),

		// Output item events
		.outputItemAdded(
			item: Item.Output.message(Message.Output(
				content: [
					.text(text: "Hello! How can I help you today?", annotations: []),
				],
				id: "msg_123",
				role: .assistant,
				status: .completed)),
			outputIndex: 0),

		// Content part events
		.contentPartAdded(
			contentIndex: 0,
			itemId: "msg_123",
			outputIndex: 0,
			part: Item.Output.Content.text(text: "Hello! How can I help you today?", annotations: [])),

		// Text delta events
		.outputTextDelta(
			contentIndex: 0,
			delta: "Hello",
			itemId: "msg_123",
			outputIndex: 0),

		// Text done events
		.outputTextDone(
			contentIndex: 0,
			itemId: "msg_123",
			outputIndex: 0,
			text: "Hello! How can I help you today?"),

		// Refusal events
		.refusalDelta(
			contentIndex: 0,
			delta: "I cannot",
			itemId: "msg_123",
			outputIndex: 0),
		.refusalDone(
			contentIndex: 0,
			itemId: "msg_123",
			outputIndex: 0,
			refusal: "I cannot help with that request."),

		// Function call events
		.functionCallArgumentsDelta(
			delta: "{\"location\": \"San Francisco\"}",
			itemId: "msg_123",
			outputIndex: 0),
		.functionCallArgumentsDone(
			arguments: "{\"location\": \"San Francisco\"}",
			itemId: "msg_123",
			outputIndex: 0),

		// File search events
		.fileSearchCallInitiated(
			itemId: "msg_123",
			outputIndex: 0),
		.fileSearchCallSearching(
			itemId: "msg_123",
			outputIndex: 0),
		.fileSearchCallCompleted(
			itemId: "msg_123",
			outputIndex: 0),

		// Web search events
		.webSearchCallInitiated(
			itemId: "msg_123",
			outputIndex: 0),
		.webSearchCallSearching(
			itemId: "msg_123",
			outputIndex: 0),
		.webSearchCallCompleted(
			itemId: "msg_123",
			outputIndex: 0),

		// Error event
		.error(error: Response.Error(
			type: "invalid_request",
			message: "Invalid request",
			code: "invalid_request",
			param: "model")),
	]

	try assertCodable(events, resource: "Events")
}
