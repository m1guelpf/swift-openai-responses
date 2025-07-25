import Foundation
import Nimble
import Testing
@testable import OpenAI

@Test
func codableItems() throws {
	let items: [Item.Input] = [
		.inputMessage(Message.Input(
			role: .user,
			content: .text("Hello, world!"))),
		// .outputMessage(Message.Output(
		// 	content: [.text(text: "Hello, world!")],
		// 	id: "msg_123",
		// 	status: .completed)),
		.fileSearch(Item.FileSearchCall(
			id: "fs_123",
			status: .completed)),
		.computerToolCall(Item.ComputerToolCall(
			action: .click(button: .left, x: 10, y: 20),
			callId: "call_123",
			status: .completed)),
		.computerToolCallOutput(Item.ComputerToolCallOutput(
			callId: "call_123",
			output: .screenshot(fileId: "file_abc", imageUrl: "http://example.com/image.png"))),
		.webSearchCall(Item.WebSearchCall(
			id: "ws_123",
			status: .completed)),
		.functionCall(Item.FunctionCall(
			arguments: "{\"query\":\"test\"}",
			callId: "call_456",
			id: "func_123",
			name: "search",
			status: .completed)),
		.functionCallOutput(Item.FunctionCallOutput(
			callId: "call_456",
			output: "{\"result\":\"success\"}")),
		.reasoning(Item.Reasoning(
			id: "reason_123",
			summary: [.text("This is a test summary.")],
			status: .completed))
	]
	try assertCodable(items, resource: "Items")
}