import Foundation
import Nimble
import Testing
@testable import OpenAI

func createResponse() -> Response {
	let dateFormatter = ISO8601DateFormatter()
	let fixedDate = dateFormatter.date(from: "2024-03-21T00:00:00Z")!

	return Response(
		createdAt: fixedDate,
		id: "resp_123456789",
		incompleteDetails: nil,
		instructions: "You are a helpful assistant",
		maxOutputTokens: 1000,
		metadata: [
			"conversation_id": "conv_123",
			"user_id": "user_456",
		],
		model: "gpt-4o",
		output: [
			.message(Message.Output(
				content: [
					.text(text: "Hello! How can I help you today?", annotations: [
						.fileCitation(fileId: "file_123", index: 0),
						.urlCitation(
							endIndex: 15,
							startIndex: 0,
							title: "OpenAI Documentation",
							url: "https://platform.openai.com/docs"),
						.filePath(fileId: "file_123", index: 0),
					]),
				],
				id: "msg_123",
				role: .assistant,
				status: .completed)),
		],
		parallelToolCalls: false,
		previousResponseId: "resp_123456788",
		reasoning: ReasoningConfig(
			effort: .medium,
			generateSummary: .concise),
		status: .completed,
		temperature: 0.7,
		text: TextConfig(format: .text),
		toolChoice: .none,
		tools: [
			.function(Tool.Function(
				name: "get_weather",
				description: "Get the current weather for a location",
				parameters: Tool.Function.Parameters(
					type: .object,
					properties: [
						"location": Tool.Function.Parameters.Property(
							type: .string,
							description: "The city and state, e.g. San Francisco, CA"
						),
					],
					required: ["location"]),
				strict: true)),
			.fileSearch(Tool.FileSearch(
				vectorStoreIds: ["vs_123"],
				maxNumResults: 5)),
			.webSearch(Tool.WebSearch(
				searchContextSize: .medium,
				userLocation: Tool.WebSearch.UserLocation(
					city: "San Francisco",
					country: "US"))),
		],
		topP: 1,
		truncation: .auto,
		usage: Response.Usage(
			inputTokens: 50,
			inputTokensDetails: Response.Usage.InputTokensDetails(cachedTokens: 10),
			outputTokens: 30,
			outputTokensDetails: Response.Usage.OutputTokensDetails(reasoningTokens: 5),
			totalTokens: 80),
		store: true,
		user: "user_456")
}

@Test
func codableResponse() throws {
	let response = createResponse()
	try assertCodable(response, resource: "Response")
}
