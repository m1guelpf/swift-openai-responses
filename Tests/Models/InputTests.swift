import Foundation
import Nimble
import Testing
@testable import OpenAI

@Test
func codableInput() throws {
	let items: [Input.ListItem] = [
		.message(
			role: .user,
			content: .text("Hello, world!")),
		// .inputMessage(
		//     role: .user,
		//     content: .text("Hello, world!"),
		//     status: .completed),
		// .outputMessage(
		//     content: [.text(text: "Hello, world!")],
		//     id: "msg_123",
		//     role: .assistant,
		//     status: .completed),
		// .fileSearch(
		//     id: "search_123",
		//     queries: ["test query"],
		//     status: .completed,
		//     results: [
		//         .init(
		//             file_id: "file_123",
		//             filename: "test.txt",
		//             score: 1,
		//             text: "Found text"),
		//     ]),
		// .computerToolCall(
		//     action: .click(
		//         button: .left,
		//         x: 100,
		//         y: 100),
		//     callId: "call_123",
		//     pendingSafetyChecks: [],
		//     status: .completed),
		// .computerToolCallOutput(
		//     id: "output_123",
		//     status: .completed,
		//     callId: "call_123",
		//     output: .screenshot(
		//         fileId: "file_123",
		//         imageUrl: "https://example.com/screenshot.png"),
		//     acknowledgedSafetyChecks: []),
		// .webSearchCall(
		//     id: "search_123",
		//     status: .completed),
		// .functionCall(
		//     arguments: "{\"key\": \"value\"}",
		//     callId: "call_123",
		//     id: "func_123",
		//     name: "test_function",
		//     status: .completed),
		// .functionCallOutput(
		//     id: "output_123",
		//     status: .completed,
		//     callId: "call_123",
		//     output: "{\"result\": \"success\"}"),
		// .reasoning(
		//     id: "reason_123",
		//     summary: [.text("This is a reasoning summary")],
		//     status: .completed),
	]

	try assertCodable(items, resource: "Input")
}
