# OpenAI Responses API
> Hand-crafted Swift SDK for the [OpenAI Responses API](https://platform.openai.com/docs/api-reference/responses).

[![Swift Version](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fm1guelpf%2Fswift-openai-responses%2Fbadge%3Ftype%3Dswift-versions&color=brightgreen)](https://swiftpackageindex.com/m1guelpf/swift-openai-responses)
[![Swift Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fm1guelpf%2Fswift-openai-responses%2Fbadge%3Ftype%3Dplatforms&color=brightgreen)](https://swiftpackageindex.com/m1guelpf/swift-openai-responses)
[![CI](https://github.com/m1guelpf/swift-openai-responses/actions/workflows/test.yml/badge.svg)](https://github.com/m1guelpf/swift-openai-responses/actions/workflows/test.yml)

This package contains:
- A fully typed client for the Responses API that _feels_ Swifty
- `Schemable` and `Tool` macros, providing elegant ways to define tools and structured responses.
- A `Conversation` class, handling everything you need for multi-turn streaming conversations in your views.


## Installation

<details>

<summary>
Swift Package Manager
</summary>

Add the following to your `Package.swift`:

```swift
dependencies: [
	.package(url: "https://github.com/m1guelpf/swift-openai-responses.git", .branch("main"))
]
```

</details>
<details>

<summary>Installing through XCode</summary>

-   File > Swift Packages > Add Package Dependency
-   Add https://github.com/m1guelpf/swift-openai-responses.git
-   Select "Branch" with "main"

</details>

<details>

<summary>CocoaPods</summary>

Ask ChatGPT to help you migrate away from CocoaPods.

</details>

## Getting started 🚀

You can build an iMessage-like app with built-in AI chat in 50 lines of code (UI included!):

```swift
import OpenAI
import SwiftUI

struct ContentView: View {
	@State private var newMessage: String = ""
	@State private var conversation = Conversation(authToken: OPENAI_KEY, using: .gpt5)

	var body: some View {
		VStack(spacing: 0) {
			ScrollView {
				VStack(spacing: 12) {
					ForEach(conversation.messages, id: \.self) { message in
						MessageBubble(message: message)
					}
				}
				.padding()
			}

			HStack(spacing: 12) {
				HStack {
					TextField("Chat", text: $newMessage, onCommit: sendMessage)
						.frame(height: 40)
						.submitLabel(.send)

					if newMessage != "" {
						Button(action: sendMessage) {
							Image(systemName: "arrow.up.circle.fill")
								.resizable()
								.aspectRatio(contentMode: .fill)
								.frame(width: 28, height: 28)
								.foregroundStyle(.white, .blue)
						}
					}
				}
				.padding(.leading)
				.padding(.trailing, 6)
				.overlay(RoundedRectangle(cornerRadius: 20).stroke(.quaternary, lineWidth: 1))
			}
			.padding()
		}
		.navigationTitle("Chat")
		.navigationBarTitleDisplayMode(.inline)
	}

	func sendMessage() {
		guard newMessage != "" else { return }

		conversation.send(text: newMessage)
		newMessage = ""
	}
}
```

## Architecture

### `Conversation`

The Conversation class provides a high-level interface for managing a conversation with the model. It wraps the `ResponsesAPI` class and handles the details of sending and receiving messages, as well as managing the conversation history.

#### Configuring the conversation

To create a `Conversation` instance, all you need is an OpenAI API key, and the model you will be talking to:

```swift
@State private var conversation = Conversation(authToken: OPENAI_API_KEY, using: .gpt5)
```

You can optionally provide a closure to configure the conversation, adding a system prompt or tools for the model to use:

```swift
@State private var conversation = Conversation(authToken: OPENAI_API_KEY, using: .gpt5) { config in
	// configure the model's behaviour
	config.instructions = "You are a coding assistant that talks like a pirate"

	// allow the model to browse the web
	config.tools = [.webSearch()]
}
```

Your configuration will be reused for all subsequent messages, but you can always change any of the properties (including which model you're talking to!) mid-conversation:

```swift
// update a bunch of properties at once
conversation.updateConfig { config in
	config.model = .o3Mini
}

// or update them directly
conversation.truncation = .auto
```

#### Sending messages

Your `Conversation` instance contains various helpers to make communicating with the model easier. For example, you can send a simple text message like this:

```swift
conversation.send(text: "Hey!")
```

There are also helpers for providing the output of a tool call or computer use call:

```swift
conversation.send(functionCallOutput: .init(callId: callId, output: "{ ... }"))
conversation.send(computerCallOutput: .init(callId: callId, output: .screenshot(fileId: "...")))
```

For more complex use cases, you can construct the `Input` yourself:

```swift
conversation.send([
	.message(content: [
		.image(fileId: "..."),
		.text("Take a look at this image and tell me what you see"),
	]),
])
```

#### Reading messages

You can access the messages in the conversation through the messages property. Note that this won't include function calls and its responses, only the messages between the user and the model. To access the full conversation history, use the `entries` property. For example:

```swift
ScrollView {
	ScrollViewReader { scrollView in
		VStack(spacing: 12) {
			ForEach(conversation.messages, id: \.self) { message in
				MessageBubble(message: message)
					.id(message.hashValue)
			}
		}
		.onReceive(conversation.messages.publisher) { _ in
			withAnimation { scrollView.scrollTo(conversation.messages.last?.hashValue, anchor: .center) }
		}
	}
}
```

### `ResponsesAPI`

#### Creating a new instance

To interact with the Responses API directly, create a new instance of `ResponsesAPI` with your API key:

```swift
let client = ResponsesAPI(authToken: YOUR_OPENAI_API_TOKEN)
```

Optionally, you can provide an Organization ID and/or project ID:

```swift
let client = ResponsesAPI(
	authToken: YOUR_OPENAI_API_KEY,
	organizationId: YOUR_ORGANIZATION_ID,
	projectId: YOUR_PROJECT_ID
)
```

For more advanced use cases like connecting to a custom server, you can customize the `URLRequest` used to connect to the API:

```swift
let urlRequest = URLRequest(url: MY_CUSTOM_ENDPOINT)
urlRequest.addValue("Bearer \(YOUR_API_KEY)", forHTTPHeaderField: "Authorization")

let client = ResponsesAPI(connectingTo: urlRequest)
```

#### Creating Responses

To create a new response, call the `create` method with a `Request` instance:

```swift
let response = try await client.create(Request(
	model: .gpt5,
	input: .text("Are semicolons optional in JavaScript?"),
	instructions: "You are a coding assistant that talks like a pirate"
))
```

There are plenty of helper methods to make creating your `Request` easier. Look around the [package docs](https://swiftpackageindex.com/m1guelpf/swift-openai-responses/documentation/openai) for more.

#### Streaming

To stream back the response as it is generated, use the `stream` method:

```swift
let stream = try await client.stream(Request(
	model: .gpt5,
	input: .text("Are semicolons optional in JavaScript?"),
	instructions: "You are a coding assistant that talks like a pirate"
))

for try await event in stream {
	switch event {
		// ...
	}
}
```

#### Uploading files

While uploading files is not part of the Responses API, you'll need it for sending content to the model (like images, PDFs, etc.). You can upload a file to the model like so:

```swift
let file = try await client.upload(file: .file(name: "image.png", contents: imageData, contentType: "image/png"))

// then, use it on a message
try await client.create(Request(
	model: .gpt5,
	input: .message(content: [
		.image(fileId: file.id),
		.text("Take a look at this image and tell me what you see"),
	]),
))
```

You can also load files directly from the user's filesystem or the web:

```swift
let file = try await client.upload(file: .url(URL(string: "https://example.com/file.pdf")!, contentType: "application/pdf"))
```

#### Other Stuff

You can retrieve a previously-created response by calling the `get` method with the response ID:

```swift
let response = try await client.get("resp_...")
```

You can delete a previously-created response from OpenAI's servers by calling the `delete` method with the response ID:

```swift
try await client.delete("resp_...")
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
