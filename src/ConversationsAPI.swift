import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A Swift client for the OpenAI Conversations API.
public struct ConversationsAPI: Sendable {
	private let client: APIClient

	/// Creates a new `ConversationsAPI` instance using the provided `URLRequest`.
	///
	/// You can use this initializer to use a custom base URL or custom headers.
	///
	/// - Parameter request: The `URLRequest` to use for the API.
	public init(connectingTo request: URLRequest) throws(APIClient.Error) {
		client = try APIClient(connectingTo: request)
	}

	/// Creates a new `ConversationsAPI` instance using the provided `authToken`.
	///
	/// You can optionally provide an `organizationId` and/or `projectId` to use with the API.
	///
	/// - Parameter authToken: The OpenAI API key to use for authentication.
	/// - Parameter organizationId: The [organization](https://platform.openai.com/docs/guides/production-best-practices#setting-up-your-organization) associated with the request.
	/// - Parameter projectId: The project associated with the request.
	public init(authToken: String, organizationId: String? = nil, projectId: String? = nil) {
		client = APIClient(authToken: authToken, organizationId: organizationId, projectId: projectId)
	}

	/// Create a conversation.
	///
	/// - Parameter items: Initial items to include in the conversation context.
	/// - Parameter metadata: Set of 16 key-value pairs that can be attached to an object.
	public func create(items: [Input.ListItem]? = nil, metadata: [String: String]? = nil) async throws -> APIConversation {
		return try await client.send(expecting: APIConversation.self) { req, encoder in
			req.httpMethod = "POST"
			req.url!.append(path: "/v1/conversations")
			req.addValue("application/json", forHTTPHeaderField: "Content-Type")
			req.httpBody = try encoder.encode(CreateConversationRequest(items: items, metadata: metadata))
		}
	}

	/// Get a conversation with the given ID.
	///
	/// - Parameter id: The ID of the conversation to retrieve.
	public func get(id: String) async throws -> APIConversation {
		return try await client.send(expecting: APIConversation.self) { req, _ in
			req.httpMethod = "GET"
			req.url!.append(path: "/v1/conversations/\(id)")
		}
	}

	/// Update a conversation's metadata with the given ID.
	///
	/// - Parameter id: The ID of the conversation to update.
	/// - Parameter metadata: Set of 16 key-value pairs that can be attached to an object.
	public func update(id: String, metadata: [String: String]? = nil) async throws -> APIConversation {
		return try await client.send(expecting: APIConversation.self) { req, encoder in
			req.httpMethod = "POST"
			req.url!.append(path: "/v1/conversations/\(id)")
			req.addValue("application/json", forHTTPHeaderField: "Content-Type")
			req.httpBody = try encoder.encode(UpdateConversationRequest(metadata: metadata))
		}
	}

	/// Delete a conversation with the given ID.
	///
	/// - Parameter id: The ID of the conversation to delete.
	public func delete(id: String) async throws {
		_ = try await client.send { req, _ in
			req.httpMethod = "DELETE"
			req.url!.append(path: "/v1/conversations/\(id)")
		}
	}

	/// List all items for a conversation with the given ID.
	///
	/// - Parameter id: The ID of the conversation to list items for.
	/// - Parameter after: An item ID to list items after, used in pagination.
	/// - Parameter include: Specify additional output data to include in the model response.
	/// - Parameter limit: A limit on the number of objects to be returned.
	/// - Parameter order: The order to return the input items in.
	public func listItems(id: String, after: String? = nil, include: Request.Include? = nil, limit: Int? = nil, order: Order? = nil) async throws -> Input.ItemList {
		return try await client.send(expecting: Input.ItemList.self) { req, encoder in
			req.httpMethod = "GET"
			req.url!.append(path: "/v1/conversations/\(id)/items")
			req.addValue("application/json", forHTTPHeaderField: "Content-Type")
			try req.url!.append(queryItems: [
				after.map { URLQueryItem(name: "after", value: $0) },
				limit.map { URLQueryItem(name: "limit", value: "\($0)") },
				order.map { URLQueryItem(name: "order", value: $0.rawValue) },
				include.map { try URLQueryItem(name: "include", value: encoder.encodeToString($0)) },
			])
		}
	}

	/// Create items in a conversation with the given ID.
	///
	/// - Parameter id: The ID of the conversation to add the item to.
	/// - Parameter include: Additional fields to include in the response.
	/// - Parameter items: The items to add to the conversation.
	public func createItems(id: String, include: Request.Include? = nil, items: [Input.ListItem]) async throws -> Input.ItemList {
		return try await client.send(expecting: Input.ItemList.self) { req, encoder in
			req.httpMethod = "POST"
			req.url!.append(path: "/v1/conversations/\(id)/items")
			req.addValue("application/json", forHTTPHeaderField: "Content-Type")
			req.httpBody = try encoder.encode(CreateItemsRequest(include: include, items: items))
		}
	}

	/// Get a single item from a conversation with the given IDs.
	///
	/// - Parameter id: The ID of the conversation that contains the item.
	/// - Parameter itemId: The ID of the item to retrieve.
	/// - Parameter include: Additional fields to include in the response.
	public func getItem(id: String, itemId: String, include: [Request.Include]? = nil) async throws -> Item {
		return try await client.send(expecting: Item.self) { req, encoder in
			req.httpMethod = "GET"
			req.url!.append(path: "/v1/conversations/\(id)/items/\(itemId)")
			try req.url!.append(queryItems: [
				include.map { try URLQueryItem(name: "include", value: encoder.encodeToString($0)) },
			])
		}
	}

	/// Delete an item from a conversation with the given IDs.
	///
	/// - Parameter id: The ID of the conversation that contains the item.
	/// - Parameter itemId: The ID of the item to delete.
	public func deleteItem(id: String, itemId: String) async throws {
		_ = try await client.send { req, _ in
			req.httpMethod = "DELETE"
			req.url!.append(path: "/v1/conversations/\(id)/items/\(itemId)")
		}
	}
}

private extension ConversationsAPI {
	struct CreateConversationRequest: Encodable {
		let items: [Input.ListItem]?
		let metadata: [String: String]?
	}

	struct UpdateConversationRequest: Encodable {
		let metadata: [String: String]?
	}

	struct ListItemsRequest: Encodable {
		let after: String?
		let include: Request.Include?
		let limit: Int?
		let order: Order?
	}

	struct CreateItemsRequest: Encodable {
		let include: Request.Include?
		let items: [Input.ListItem]
	}
}
