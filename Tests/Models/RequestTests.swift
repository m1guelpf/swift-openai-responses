import Foundation
import Testing

@testable import OpenAI

@Test
func codableRequest() throws {
    let request = Request(
        model: .gpt4o,
        input: .message(text: "Hello, world!"),
        include: [.fileSearchResults, .inputImageURLs, .computerCallImageURLs],
        instructions: "You are a helpful assistant",
        maxOutputTokens: 1000,
        metadata: ["user_id": "123", "session_id": "abc"],
        parallelToolCalls: true,
        previousResponseId: "resp_123",
        prompt: .init(id: "prompt_456"),
        promptCacheKey: nil,
        reasoning: ReasoningConfig(
            effort: .medium,
            summary: .detailed
        ),
        safetyIdentifier: nil,
        store: true,
        stream: false,
        temperature: 0.7,
        text: nil,
        toolChoice: .auto,
        tools: [
            .webSearch(.init(searchContextSize: .medium)),
            .function(.init(
                name: "get_weather",
                description: "Get the current weather for a location",
                parameters: .object(
                    properties: [
                        "location": .string(description: "The city and state, e.g. San Francisco, CA")
                    ],
                ),
            )),
        ],
        topP: 1,
        truncation: .auto
    )
    try assertCodable(request, resource: "Request")
}
