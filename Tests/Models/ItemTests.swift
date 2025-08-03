import Foundation
import Testing

@testable import OpenAI

@Test
func codableItems() throws {
    let items: [Item.Input] = [
        .inputMessage(Message.Input(
            role: .user,
            content: .text("Hello, world!")
        )),
        // .outputMessage(Message.Output(
        // 	content: [.text(text: "Hello, world!")],
        // 	id: "msg_123",
        // 	status: .completed)),
        .fileSearch(Item.FileSearchCall(
            id: "fs_123",
            status: .completed,
            results: [
                Item.FileSearchCall.Result(
                    attributes: ["type": "document"],
                    file_id: "file_123",
                    filename: "test.txt",
                    score: 95,
                    text: "Found relevant content"
                ),
            ]
        )),
        .computerToolCall(Item.ComputerToolCall(
            action: .click(button: .left, x: 10, y: 20),
            callId: "call_123",
            pendingSafetyChecks: [
                Item.ComputerToolCall.SafetyCheck(
                    code: "safety_check",
                    id: "check_123",
                    message: "Safety check required"
                ),
            ],
            status: .completed
        )),
        .computerToolCallOutput(Item.ComputerToolCallOutput(
            id: "output_123",
            status: .completed,
            callId: "call_123",
            output: .screenshot(fileId: "file_abc", imageUrl: "http://example.com/image.png"),
            acknowledgedSafetyChecks: [
                Item.ComputerToolCall.SafetyCheck(
                    code: "safety_check",
                    id: "check_123",
                    message: "Safety check acknowledged"
                ),
            ]
        )),
        .webSearchCall(Item.WebSearchCall(
            id: "ws_123",
            status: .completed,
            action: .search(query: "test query")
        )),
        .functionCall(Item.FunctionCall(
            arguments: "{\"query\":\"test\"}",
            callId: "call_456",
            id: "func_123",
            name: "search",
            status: .completed
        )),
        .functionCallOutput(Item.FunctionCallOutput(
            id: "output_123",
            status: .completed,
            callId: "call_456",
            output: "{\"result\":\"success\"}"
        )),
        .reasoning(Item.Reasoning(
            id: "reason_123",
            summary: [.text("This is a test summary.")],
            status: .completed,
            encryptedContent: "encrypted_content_here"
        )),
    ]
    try assertCodable(items, resource: "Items")
}
