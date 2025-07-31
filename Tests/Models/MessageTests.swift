import Foundation
import Nimble
import Testing
@testable import OpenAI

@Test
func codableMessageOutput() throws {
	let message = Message.Output(
		content: [.text(text: "Hello, world!")],
		id: "msg_123",
		role: .assistant,
		status: .completed)

	try assertCodable(message, resource: "MessageOutput")
}

@Test
func codableMessageInput() throws {
	let message = Message.Input(
		role: .user,
		content: .text("Hello, world!"))

	try assertCodable(message, resource: "MessageInput")
}
