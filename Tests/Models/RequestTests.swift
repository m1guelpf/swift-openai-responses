import Foundation
import Nimble
import Testing
@testable import OpenAI

@Test
func codableRequest() throws {
	let request = Request(
		model: .gpt4o,
		input: .init("Hello, world!"),
		include: [.fileSearchResults, .inputImageURLs, .computerCallImageURLs],
		instructions: "You are a helpful assistant",
		maxOutputTokens: 1000,
		metadata: ["user_id": "123", "session_id": "abc"],
		parallelToolCalls: true,
		previousResponseId: "resp_123",
		reasoning: ReasoningConfig(
			effort: .medium,
			generateSummary: .detailed),
		store: true,
		stream: false,
		temperature: 0.7,
		text: TextConfig(format: .text),
		toolChoice: .auto,
		tools: [
			.webSearch(.init(searchContextSize: .medium)),
			.function(.init(
				name: "get_weather",
				description: "Get the current weather for a location",
				parameters: .init(
					type: .object,
					properties: [
						"location": .init(
							type: .string,
							description: "The city and state, e.g. San Francisco, CA"
						),
					],
					required: ["location"]))),
		],
		topP: 1,
		truncation: .auto,
		user: "user_123")
	try assertCodable(request, resource: "Request")
}
