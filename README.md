# OpenAI Responses API

[![Swift Version](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fm1guelpf%2Fswift-openai-responses%2Fbadge%3Ftype%3Dswift-versions&color=brightgreen)](https://swiftpackageindex.com/m1guelpf/swift-openai-responses)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/m1guelpf/swift-openai-responses/main/LICENSE)

An unofficial Swift SDK for the [OpenAI Responses API](https://platform.openai.com/docs/api-reference/responses).

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

## Architecture

### `ResponsesAPI`

#### Creating a new instance

To interact with the Responses API, create a new instance of `ResponsesAPI` with your API key:

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

For more advanced use cases, you can customize the `URLRequest` used to connect to the API:

``` swift
let urlRequest = URLRequest(url: MY_CUSTOM_ENDPOINT)
urlRequest.addValue("Bearer \(YOUR_API_KEY)", forHTTPHeaderField: "Authorization")

let client = ResponsesAPI(connectingTo: urlRequest)
```

#### Creating Responses

To create a new response, call the `create` method with a `Request` instance:

```swift
let response = try await client.create(Request(
    model: "gpt-4o",
    input: .text("Are semicolons optional in JavaScript?"),
    instructions: "You are a coding assistant that talks like a pirate"
))
```

There are plenty of helper methods to make creating your `Request` easier. Look around the [package docs](https://swiftpackageindex.com/m1guelpf/swift-openai-responses/documentation/openai) for more.

#### Streaming

To stream back the response as it is generated, use the `stream` method:

```swift
let stream = try await client.stream(Request(
    model: "gpt-4o",
    input: .text("Are semicolons optional in JavaScript?"),
    instructions: "You are a coding assistant that talks like a pirate"
))

for try await event in stream {
    switch event {
        // ...
    }
}
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

## Roadmap

-   [x] A simple interface for directly interacting with the API
-   [x] Support for streaming responses
-   [ ] Wrap the API in an interface that manages the conversation for you

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
