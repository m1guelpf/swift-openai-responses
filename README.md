# OpenAI Responses API

[![Swift Version](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fm1guelpf%2Fswift-openai-responses%2Fbadge%3Ftype%3Dswift-versions&color=brightgreen)](https://swiftpackageindex.com/m1guelpf/swift-openai-responses)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/m1guelpf/swift-openai-responses/main/LICENSE)

An unofficial Swift SDK for the [OpenAI Responses API](https://platform.openai.com/docs/api-reference/responses).

## Installation

### Swift Package Manager

The Swift Package Manager allows for developers to easily integrate packages into their Xcode projects and packages; and is also fully integrated into the swift compiler.

### SPM Through XCode Project

-   File > Swift Packages > Add Package Dependency
-   Add https://github.com/m1guelpf/swift-openai-responses.git
-   Select "Branch" with "main"

### SPM Through Xcode Package

Once you have your Swift package set up, add the Git link within the dependencies value of your Package.swift file.

```swift
dependencies: [
    .package(url: "https://github.com/m1guelpf/swift-openai-responses.git", .branch("main"))
]
```

## Features

-   [x] A simple interface for directly interacting with the API
-   [ ] Wrap the API in an interface that manages the conversation for you

## Usage

To interact with the Responses API, create a new instance of `ResponsesAPI`, providing your API key and, optionally, an organization ID and/or project ID:

```swift
let client = ResponsesAPI(
    authToken: YOUR_OPENAI_API_KEY,
    organizationId: YOUR_ORGANIZATION_ID, // optional
    projectId: YOUR_PROJECT_ID // optional
)
```

For advanced use cases, you can customize the `URLRequest` used to connect to the API:

``` swift
let urlRequest = URLRequest(url: MY_CUSTOM_ENDPOINT)
urlRequest.addValue("Bearer \(YOUR_API_KEY)", forHTTPHeaderField: "Authorization")

let client = ResponsesAPI(connectingTo: urlRequest)
```

To create a new response, call the `create` method with a `Request` instance:

```swift
let response = try await client.create(Request(
    model: "gpt-4o",
    input: .text("Are semicolons optional in JavaScript?"),
    instructions: "You are a coding assistant that talks like a pirate"
))
```

To stream back the response as it is generated, use the `stream` method:

```swift
let stream = try await client.stream(Request(
    model: "gpt-4o",
    input: .text("Are semicolons optional in JavaScript?"),
    instructions: "You are a coding assistant that talks like a pirate",
    stream: true
))

for try await event in stream {
    switch event {
        // ...
    }
}
```

You can retrieve a previously-created response by calling the `get` method with the response ID:

```swift
let response = try await client.get("resp_...")
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
