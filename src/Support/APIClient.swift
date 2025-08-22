import Foundation
import EventSource
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct APIClient: Sendable {
	public enum Error: Swift.Error {
		/// The provided request is invalid.
		case invalidRequest(URLRequest)

		/// The response was not a 200 or 400 status
		case invalidResponse(URLResponse)
	}

	private let request: URLRequest
	private let eventSource = EventSource(mode: .dataOnly)
	private let encoder = tap(JSONEncoder()) { $0.dateEncodingStrategy = .iso8601 }
	private let decoder = tap(JSONDecoder()) { $0.dateDecodingStrategy = .iso8601 }

	/// Creates a new `APIClient` instance using the provided `URLRequest`.
	///
	/// - Parameter request: The `URLRequest` to use for the API.
	init(connectingTo request: URLRequest) throws(Error) {
		guard let url = request.url else { throw Error.invalidRequest(request) }

		var request = request
		if url.lastPathComponent != "/" {
			request.url = url.appendingPathComponent("/")
		}

		self.request = request
	}

	/// Creates a new `ResponsesAPI` instance using OpenAI API credentials.
	///
	/// - Parameter authToken: The OpenAI API key to use for authentication.
	/// - Parameter organizationId: The [organization](https://platform.openai.com/docs/guides/production-best-practices#setting-up-your-organization) associated with the request.
	/// - Parameter projectId: The project associated with the request.
	init(authToken: String, organizationId: String? = nil, projectId: String? = nil) {
		var request = URLRequest(url: URL(string: "https://api.openai.com/")!)

		request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
		if let projectId { request.addValue(projectId, forHTTPHeaderField: "OpenAI-Project") }
		if let organizationId { request.addValue(organizationId, forHTTPHeaderField: "OpenAI-Organization") }

		self.request = request
	}

	func send<R: Decodable>(expecting _: R.Type, configuring requestBuilder: (inout URLRequest, JSONEncoder) throws -> Void) async throws -> R {
		return try decoder.decode(R.self, from: await send(configuring: requestBuilder))
	}

	func send(configuring requestBuilder: (inout URLRequest, JSONEncoder) throws -> Void) async throws -> Data {
		var req = request
		try requestBuilder(&req, encoder)

		return try await send(request: req)
	}

	func stream<T: Decodable & Sendable>(expecting _: T.Type, configuring requestBuilder: (inout URLRequest, JSONEncoder) throws -> Void) async throws -> AsyncThrowingStream<T, Swift.Error> {
		var req = request
		try requestBuilder(&req, encoder)

		return try await sseStream(of: T.self, request: req)
	}

	/// Sends an URLRequest and returns the response data.
	///
	/// - Throws: If the request fails to send or has a non-200 status code.
	private func send(request: URLRequest) async throws -> Data {
		let (data, res) = try await URLSession.shared.data(for: request)

		guard let res = res as? HTTPURLResponse else { throw Error.invalidResponse(res) }
		guard res.statusCode != 200 else { return data }

		if let response = try? decoder.decode(Response.ErrorResponse.self, from: data) {
			throw response.error
		}

		throw Error.invalidResponse(res)
	}

	private func sseStream<T: Decodable & Sendable>(of _: T.Type, request: URLRequest) async throws -> AsyncThrowingStream<T, Swift.Error> {
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

	/// A hacky parser for Server-Sent Events lines.
	///
	/// It looks for a line that starts with `data:`, then tries to decode the message as the given type.
	private func parseSSELine<T: Decodable>(_ line: String, as _: T.Type = T.self) -> Result<T, Swift.Error>? {
		let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
		guard components.count == 2, components[0] == "data" else { return nil }

		let message = components[1].trimmingCharacters(in: .whitespacesAndNewlines)

		return Result { try decoder.decode(T.self, from: Data(message.utf8)) }
	}
}
