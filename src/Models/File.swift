import Foundation
import MetaCodable
import HelperCoders

@Codable @CodingKeys(.snake_case) public struct File: Equatable, Hashable, Sendable, Codable {
	public struct Upload: Equatable, Hashable, Sendable {
		/// The name of the file
		public var name: String
		/// The contents of the file
		public var contents: Data
		/// The mime type of the file
		public var contentType: String

		/// Creates a new file upload
		///
		/// - Parameter name: The name of the file
		/// - Parameter contents: The contents of the file
		/// - Parameter contentType: The mime type of the file
		public init(name: String, contents: Data, contentType: String = "application/octet-stream") {
			self.name = name
			self.contents = contents
			self.contentType = contentType
		}
	}

	/// The intended purpose of the file.
	public enum Purpose: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
		/// Used in the Assistants API
		case assistants
		/// Used in the Assistants API
		case assistantsOutput = "assistants_output"
		/// Used in the Batch API
		case batch
		/// Used for fine-tuning
		case fineTune = "fine-tune"
		/// Images used for vision fine-tuning
		case vision
		/// Flexible file type for any purpose
		case userData = "user_data"
		/// Used for eval data sets
		case evals
	}

	/// The current status of the file
	public enum Status: String, CaseIterable, Equatable, Codable, Sendable {
		case error
		case uploaded
		case processed
	}

	/// The file identifier, which can be referenced in the API endpoints.
	public var id: String

	/// The intended purpose of the file.
	public var purpose: Purpose

	/// The name of the file.
	public var filename: String

	/// The size of the file, in bytes.
	public var bytes: Int

	/// The `Date` when the file was created.
	@CodedBy(Since1970DateCoder())
	public var createdAt: Date

	/// The `Date` when the file will expire.
	@CodedBy(Since1970DateCoder())
	public var expiresAt: Date?

	/// The current status of the file
	public var status: Status

	/// Create a new `File` instance.
	///
	/// - Parameter id: The file identifier, which can be referenced in the API endpoints.
	/// - Parameter purpose: The intended purpose of the file.
	/// - Parameter filename: The name of the file.
	/// - Parameter bytes: The size of the file, in bytes.
	/// - Parameter createdAt: The `Date` when the file was created.
	/// - Parameter expiresAt: The `Date` when the file will expire.
	/// - Parameter status: The current status of the file
	public init(id: String, purpose: Purpose, filename: String, bytes: Int, createdAt: Date, expiresAt: Date? = nil, status: Status) {
		self.id = id
		self.bytes = bytes
		self.status = status
		self.purpose = purpose
		self.filename = filename
		self.createdAt = createdAt
		self.expiresAt = expiresAt
	}
}

// MARK: - Creation helpers

public extension File.Upload {
	/// Creates a file upload from a local file or URL.
	///
	/// - Parameter url: The URL of the file to upload.
	/// - Parameter name: The name of the file.
	/// - Parameter contentType: The mime type of the file.
	static func url(_ url: URL, name: String? = nil, contentType: String = "application/octet-stream") async throws -> File.Upload {
		let name = name ?? url.lastPathComponent == "/" ? "unknown_file" : url.lastPathComponent

		return try File.Upload(name: name, contents: Data(contentsOf: url), contentType: contentType)
	}

	/// Creates a file upload from the given data.
	///
	/// - Parameter name: The name of the file.
	/// - Parameter contents: The contents of the file.
	/// - Parameter contentType: The mime type of the file.
	static func file(name: String, contents: Data, contentType: String = "application/octet-stream") -> File.Upload {
		return File.Upload(name: name, contents: contents, contentType: contentType)
	}
}

// MARK: - Private helpers

extension File.Upload {
	func toFormEntry(paramName: String = "file") -> FormData.Entry {
		.file(paramName: paramName, fileName: name, fileData: contents, contentType: contentType)
	}
}
