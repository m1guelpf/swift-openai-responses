import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A Swift client for the OpenAI Responses API.
public final class ResponsesAPI: Sendable {
	enum Error: Swift.Error {
		/// Make sure to use the `stream` function when you want to stream back the response.
		case willNotStreamResponse

		/// The response was not a 200 or 400 status
		case invalidResponse(URLResponse)
	}

	private let request: URLRequest
	private let encoder = JSONEncoder()
	private let decoder = JSONDecoder()

	/// Creates a new `ResponsesAPI` instance using the provided `URLRequest`.
	public init(connectingTo request: URLRequest) {
		self.request = request
	}

	/// Creates a new `ResponsesAPI` instance using the provided `authToken`.
	/// You can optionally provide an `organizationId` and/or `projectId` to use with the API.
	public convenience init(authToken: String, organizationId: String? = nil, projectId: String? = nil) {
		var request = URLRequest(url: URL(string: "https://api.openai.com/v1/responses")!)

		request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
		if let projectId { request.addValue(projectId, forHTTPHeaderField: "OpenAI-Project") }
		if let organizationId { request.addValue(organizationId, forHTTPHeaderField: "OpenAI-Organization") }

		self.init(connectingTo: request)
	}

	/// Creates a model response.
	///
	/// Provide [text](https://platform.openai.com/docs/guides/text) or [image](https://platform.openai.com/docs/guides/images) inputs to generate [text](https://platform.openai.com/docs/guides/text) or [JSON](https://platform.openai.com/docs/guides/structured-outputs) outputs.
	/// Have the model call your own [custom code](https://platform.openai.com/docs/guides/function-calling) or use built-in [tools](https://platform.openai.com/docs/guides/tools) like [web search](https://platform.openai.com/docs/guides/tools-web-search) or [file search](https://platform.openai.com/docs/guides/tools-file-search) to use your own data as input for the model's response.
	/// To receive a stream of tokens as they are generated, use the `stream` function instead.
	///
	/// ## Errors
	///
	/// Errors if the request fails to send or has a non-200 status code (except for 400, which will return an OpenAI error instead).
	public func create(_ request: Request) async throws -> Result<Response, Response.Error> {
		if request.stream == true {
			throw Error.willNotStreamResponse
		}

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

	/// Retrieves a model response with the given ID.
	///
	/// ## Errors
	///
	/// Errors if the request fails to send or has a non-200 status code (except for 400, which will return an OpenAI error instead).
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
	/// ## Errors
	///
	/// Errors if the request fails to send or has a non-200 status code.
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
	/// ## Errors
	///
	/// Errors if the request fails to send or has a non-200 status code.
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
}
