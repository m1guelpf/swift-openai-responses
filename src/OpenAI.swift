import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A Swift client for the OpenAI Responses API.
public final class ResponsesAPI: Sendable {
	public enum Error: Swift.Error {
		/// The response was not a 200 or 400 status
		case invalidResponse(URLResponse)
	}

	private let request: URLRequest
	private let encoder = JSONEncoder()
	private let decoder = JSONDecoder()

	/// Creates a new `ResponsesAPI` instance using the provided `URLRequest`.
	///
	/// You can use this initializer to use a custom base URL or custom headers.
	///
	/// - Parameter request: The `URLRequest` to use for the API.
	public init(connectingTo request: URLRequest) {
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
		var request = URLRequest(url: URL(string: "https://api.openai.com/v1/responses")!)

		request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
		if let projectId { request.addValue(projectId, forHTTPHeaderField: "OpenAI-Project") }
		if let organizationId { request.addValue(organizationId, forHTTPHeaderField: "OpenAI-Organization") }

		self.init(connectingTo: request)
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
		req.httpBody = try encoder.encode(request)
		req.addValue("application/json", forHTTPHeaderField: "Content-Type")

		let (data, res) = try await URLSession.shared.data(for: req)
		guard let res = res as? HTTPURLResponse, res.statusCode == 200 || res.statusCode == 400 else {
			throw Error.invalidResponse(res)
		}

		return try decoder.decode(Response.ResultResponse.self, from: data).into()
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
		req.httpBody = try encoder.encode(request)
		req.addValue("application/json", forHTTPHeaderField: "Content-Type")

		let (bytes, res) = try await URLSession.shared.bytes(for: req)
		guard let res = res as? HTTPURLResponse, res.statusCode == 200 else {
			throw Error.invalidResponse(res)
		}

		let (stream, continuation) = AsyncThrowingStream.makeStream(of: Event.self)

		let task = Task {
			defer { continuation.finish() }

			for try await line in bytes.lines {
				guard let event = try parseSSELine(line, as: Event.self) else { continue }

				continuation.yield(event)
				try Task.checkCancellation()
			}
		}

		continuation.onTermination = { _ in
			task.cancel()
		}

		return stream
	}

	/// Retrieves a model response with the given ID.
	///
	/// - Throws: If the request fails to send or has a non-200 status code (except for 400, which will return an OpenAI error instead).
	public func get(_ id: String) async throws -> Result<Response, Response.Error> {
		var req = request
		req.httpMethod = "GET"
		req.url!.append(path: "/\(id)")

		let (data, res) = try await URLSession.shared.data(for: req)
		guard let res = res as? HTTPURLResponse, res.statusCode == 200 || res.statusCode == 400 else {
			throw Error.invalidResponse(res)
		}

		return try decoder.decode(Response.ResultResponse.self, from: data).into()
	}

	/// Deletes a model response with the given ID.
	///
	/// - Throws: `Error.invalidResponse` if the request fails to send or has a non-200 status code.
	public func delete(_ id: String) async throws {
		var req = request
		req.httpMethod = "DELETE"
		req.url!.append(path: "/\(id)")

		let (_, res) = try await URLSession.shared.data(for: req)
		guard let res = res as? HTTPURLResponse, res.statusCode == 200 else {
			throw Error.invalidResponse(res)
		}
	}

	/// Returns a list of input items for a given response.
	///
	/// - Throws: If the request fails to send or has a non-200 status code.
	public func listInputs(_ id: String) async throws -> Input.ItemList {
		var req = request
		req.httpMethod = "GET"
		req.url!.append(path: "/\(id)/inputs")

		let (data, res) = try await URLSession.shared.data(for: req)
		guard let res = res as? HTTPURLResponse, res.statusCode == 200 else {
			throw Error.invalidResponse(res)
		}

		return try decoder.decode(Input.ItemList.self, from: data)
	}

	/// A hacky parser for Server-Sent Events lines.
	///
	/// It looks for a line that starts with `data:`, then tries to decode the message as the given type.
	private func parseSSELine<T: Decodable>(_ line: String, as _: T.Type = T.self) throws -> T? {
		let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
		guard components.count == 2, components[0] == "data" else { return nil }

		let message = components[1].trimmingCharacters(in: .whitespacesAndNewlines)

		return try decoder.decode(T.self, from: Data(message.utf8))
	}
}
