import Foundation
import MetaCodable
import HelperCoders

@Codable @CodingKeys(.snake_case) public struct APIConversation: Equatable, Hashable, Sendable {
	/// The time at which the conversation was created, measured in seconds since the Unix epoch.
	@CodedBy(Since1970DateCoder())
	public var createdAt: Date

	/// The unique ID of the conversation.
	public var id: String

	/// Set of 16 key-value pairs that can be attached to an object.
	///
	/// This can be useful for storing additional information about the object in a structured format, and querying for objects via API or the dashboard.
	///
	/// Keys are strings with a maximum length of 64 characters, and values are strings with a maximum length of 512 characters.
	public var metadata: [String: String]?

	public init(id: String, createdAt: Date, metadata: [String: String]? = nil) {
		self.createdAt = createdAt
		self.id = id
		self.metadata = metadata
	}
}
