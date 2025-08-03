import Foundation
import Testing

@testable import OpenAI

@Test
func codableRequest() throws {
    let request = Request(
        model: .gpt4o,
        input: .message(text: "Hello, world!"),
        background: true,
        include: [.fileSearchResults, .inputImageURLs, .computerCallImageURLs],
        instructions: "You are a helpful assistant",
        maxOutputTokens: 1000,
        maxToolCalls: 5,
        metadata: ["user_id": "123", "session_id": "abc"],
        parallelToolCalls: true,
        previousResponseId: "resp_123",
        prompt: .init(id: "prompt_456"),
        promptCacheKey: "cache_key_123",
        reasoning: ReasoningConfig(
            effort: .medium,
            summary: .detailed
        ),
        safetyIdentifier: "user_hash_123",
        serviceTier: .default,
        store: true,
        stream: false,
        temperature: 0.7,
        text: .init(format: .text),
        toolChoice: .auto,
        tools: [
            .webSearch(.init(searchContextSize: .medium)),
            .function(.init(
                name: "get_weather",
                description: "Get the current weather for a location",
                parameters: .object(
                    properties: [
                        "location": .string(description: "The city and state, e.g. San Francisco, CA"),
                    ],
                ),
            )),
        ],
        topLogprobs: 5,
        topP: 1,
        truncation: .auto
    )
    try assertCodable(request, resource: "Request")
}
