import Foundation
import MetaCodable
import HelperCoders

/// A webhook event corresponding to an update from the Responses API.
@Codable @CodingKeys(.snake_case) public struct WebhookEvent: Equatable, Hashable, Sendable {
	/// Event data payload.
	public struct EventData: Equatable, Hashable, Codable, Sendable {
		/// The unique ID of the model response.
		public var id: String

		/// Creates a new `EventData` instance.
		///
		/// - Parameter id: The unique ID of the model response.
		public init(id: String) {
			self.id = id
		}
	}

	/// The unique ID of the event.
	public var id: String

	/// The type of the event.
	public var type: String

	/// The date when the model response was completed.
	@CodedBy(Since1970DateCoder())
	public var createdAt: Date

	/// Event data payload.
	public var data: EventData

	/// Creates a new `WebhookEvent` instance.
	///
	/// - Parameter id: The unique ID of the event.
	/// - Parameter type: The type of the event.
	/// - Parameter createdAt: The date when the model response was completed.
	/// - Parameter data: Event data payload.
	public init(id: String, type: String, createdAt: Date, data: EventData) {
		self.id = id
		self.type = type
		self.data = data
		self.createdAt = createdAt
	}
}
