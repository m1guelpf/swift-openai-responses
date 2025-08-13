import Foundation
import EventSource
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A Swift client for the OpenAI Responses API.
public final class ResponsesAPI: Sendable {
	public enum Error: Swift.Error {
		/// The provided request is invalid.
		case invalidRequest(URLRequest)

		/// The response was not a 200 or 400 status
		case invalidResponse(URLResponse)
	}

	private let request: URLRequest

	private let eventSource = EventSource(mode: .dataOnly)
	private let encoder = tap(JSONEncoder()) { encoder in
		encoder.dateEncodingStrategy = .iso8601
	}

	private let decoder = tap(JSONDecoder()) { decoder in
		decoder.dateDecodingStrategy = .iso8601
	}

	/// Creates a new `ResponsesAPI` instance using the provided `URLRequest`.
	///
	/// You can use this initializer to use a custom base URL or custom headers.
	///
	/// - Parameter request: The `URLRequest` to use for the API.
	public init(connectingTo request: URLRequest) throws {
		guard let url = request.url else { throw Error.invalidRequest(request) }

		var request = request
		if url.lastPathComponent != "/" {
			request.url = url.appendingPathComponent("/")
		}

		self.request = request
	}

	/// Creates a new `ResponsesAPI` instance using the provided `authToken`.
	///
	/// You can optionally provide an `organizationId` and/or `projectId` to use with the API.
	///
	/// - Parameter authToken: The OpenAI API key to use for authentication.
	/// - Parameter organizationId: The [organization](https://platform.openai.com/docs/guides/production-best-practices#setting-up-your-organization) associated with the request.
	/// - Parameter projectId: The project associated with the request.
	public convenience init(authToken: String, organizationId: String? = nil, projectId: String? = nil) {
		var request = URLRequest(url: URL(string: "https://api.openai.com/")!)

		request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
		if let projectId { request.addValue(projectId, forHTTPHeaderField: "OpenAI-Project") }
		if let organizationId { request.addValue(organizationId, forHTTPHeaderField: "OpenAI-Organization") }

		try! self.init(connectingTo: request)
	}

	/// Creates a model response.
	///
	/// > Note: To receive a stream of tokens as they are generated, use the `stream` function instead.
	///
	/// Provide [text](https://platform.openai.com/docs/guides/text) or [image](https://platform.openai.com/docs/guides/images) inputs to generate [text](https://platform.openai.com/docs/guides/text) or [JSON](https://platform.openai.com/docs/guides/structured-outputs) outputs.
	/// Have the model call your own [custom code](https://platform.openai.com/docs/guides/function-calling) or use built-in [tools](https://platform.openai.com/docs/guides/tools) like [web search](https://platform.openai.com/docs/guides/tools-web-search) or [file search](https://platform.openai.com/docs/guides/tools-file-search) to use your own data as input for the model's response.
	///
	/// - Throws: If the request fails to send or has a non-200 status code (except for 400, which will return an OpenAI error instead).
	public func create(_ request: Request) async throws -> Result<Response, Response.Error> {
		var request = request
		request.stream = false

		var req = self.request
		req.httpMethod = "POST"
		req.url!.append(path: "v1/responses")
		req.httpBody = try encoder.encode(request)
		req.addValue("application/json", forHTTPHeaderField: "Content-Type")

		return try decoder.decode(Response.ResultResponse.self, from: await send(request: req)).into()
	}

	/// Creates a model response and streams the tokens as they are generated.
	///
	/// > Note: To receive a single response, use the `create` function instead.
	///
	/// Provide [text](https://platform.openai.com/docs/guides/text) or [image](https://platform.openai.com/docs/guides/images) inputs to generate [text](https://platform.openai.com/docs/guides/text) or [JSON](https://platform.openai.com/docs/guides/structured-outputs) outputs.
	/// Have the model call your own [custom code](https://platform.openai.com/docs/guides/function-calling) or use built-in [tools](https://platform.openai.com/docs/guides/tools) like [web search](https://platform.openai.com/docs/guides/tools-web-search) or [file search](https://platform.openai.com/docs/guides/tools-file-search) to use your own data as input for the model's response.
	///
	/// - Throws: If the request fails to send or has a non-200 status code.
	public func stream(_ request: Request) async throws -> AsyncThrowingStream<Event, any Swift.Error> {
		var request = request
		request.stream = true

		var req = self.request
		req.httpMethod = "POST"
		req.url!.append(path: "v1/responses")
		req.httpBody = try encoder.encode(request)
		req.addValue("application/json", forHTTPHeaderField: "Content-Type")

		return try await sseStream(of: Event.self, request: req)
	}

	/// Retrieves a model response with the given ID.
	///
	/// - Parameter id: The ID of the response to retrieve.
	/// - Parameter include: Additional fields to include in the response. See `Request.Include` for available options.
	///
	/// - Throws: If the request fails to send or has a non-200 status code (except for 400, which will return an OpenAI error instead).
	public func get(_ id: String, include: [Request.Include]? = nil) async throws -> Result<Response, Response.Error> {
		var req = request
		req.httpMethod = "GET"
		req.url!.append(path: "v1/responses/\(id)")
		try req.url!.append(queryItems: [
			include.map { try URLQueryItem(name: "include", value: encoder.encodeToString($0)) },
		])

		return try decoder.decode(Response.ResultResponse.self, from: await send(request: req)).into()
	}

	/// Continues streaming a model response with the given ID.
	///
	/// - Parameter id: The ID of the response to stream.
	/// - Parameter startingAfter: The sequence number of the event after which to start streaming.
	/// - Parameter include: Additional fields to include in the response. See `Request.Include` for available options.
	///
	/// - Throws: If the request fails to send or has a non-200 status code.
	public func stream(id: String, startingAfter: Int? = nil, include: [Request.Include]? = nil) async throws -> AsyncThrowingStream<Event, any Swift.Error> {
		var req = request
		req.httpMethod = "GET"
		req.url!.append(path: "v1/responses/\(id)")
		try req.url!.append(queryItems: [
			URLQueryItem(name: "stream", value: "true"),
			startingAfter.map { URLQueryItem(name: "starting_after", value: "\($0)") },
			include.map { try URLQueryItem(name: "include", value: encoder.encodeToString($0)) },
		])

		return try await sseStream(of: Event.self, request: req)
	}

	/// Cancels a model response with the given ID.
	///
	/// - Parameter id: The ID of the response to cancel.
	///
	/// Only responses created with the background parameter set to true can be cancelled. [Learn more](https://platform.openai.com/docs/guides/background).
	public func cancel(_ id: String) async throws {
		var req = request
		req.httpMethod = "POST"
		req.url!.append(path: "v1/responses/\(id)/cancel")

		_ = try await send(request: req)
	}

	/// Deletes a model response with the given ID.
	///
	/// - Throws: `Error.invalidResponse` if the request fails to send or has a non-200 status code.
	public func delete(_ id: String) async throws {
		var req = request
		req.httpMethod = "DELETE"
		req.url!.append(path: "v1/responses/\(id)")

		_ = try await send(request: req)
	}

	/// Returns a list of input items for a given response.
	///
	/// - Throws: If the request fails to send or has a non-200 status code.
	public func listInputs(_ id: String) async throws -> Input.ItemList {
		var req = request
		req.httpMethod = "GET"
		req.url!.append(path: "/\(id)/inputs")

		return try decoder.decode(Input.ItemList.self, from: await send(request: req))
	}

	/// Uploads a file for later use in the API.
	///
	/// - Parameter file: The file to upload.
	/// - Parameter purpose: The intended purpose of the file.
	public func upload(file: File.Upload, purpose: File.Purpose = .userData) async throws -> File {
		let form = FormData(
			boundary: UUID().uuidString,
			entries: [file.toFormEntry(), .string(paramName: "purpose", value: purpose.rawValue)]
		)

		var req = request
		req.httpMethod = "POST"
		req.attach(formData: form)
		req.url!.append(path: "v1/files")

		return try decoder.decode(File.self, from: await send(request: req))
	}
}

// MARK: - Private helpers

private extension ResponsesAPI {
	/// A hacky parser for Server-Sent Events lines.
	///
	/// It looks for a line that starts with `data:`, then tries to decode the message as the given type.
	func parseSSELine<T: Decodable>(_ line: String, as _: T.Type = T.self) -> Result<T, Swift.Error>? {
		let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
		guard components.count == 2, components[0] == "data" else { return nil }

		let message = components[1].trimmingCharacters(in: .whitespacesAndNewlines)

		return Result { try decoder.decode(T.self, from: Data(message.utf8)) }
	}

	/// Sends an URLRequest and returns the response data.
	///
	/// - Throws: If the request fails to send or has a non-200 status code.
	func send(request: URLRequest) async throws -> Data {
		let (data, res) = try await URLSession.shared.data(for: request)

		guard let res = res as? HTTPURLResponse else { throw Error.invalidResponse(res) }
		guard res.statusCode != 200 else { return data }

		if let response = try? decoder.decode(Response.ErrorResponse.self, from: data) {
			throw response.error
		}

		throw Error.invalidResponse(res)
	}

	func sseStream<T: Decodable & Sendable>(of _: T.Type, request: URLRequest) async throws -> AsyncThrowingStream<T, Swift.Error> {
		let (stream, continuation) = AsyncThrowingStream.makeStream(of: T.self)

		let task = Task {
			defer { continuation.finish() }

			let dataTask = eventSource.dataTask(for: request)
			defer { dataTask.cancel(urlSession: URLSession.shared) }

			for await event in dataTask.events() {
				guard case let .event(event) = event, let data = event.data?.data(using: .utf8) else { continue }

				continuation.yield(with: Result { try decoder.decode(T.self, from: data) })

				try Task.checkCancellation()
			}
		}

		continuation.onTermination = { _ in
			task.cancel()
		}

		return stream
	}
}
