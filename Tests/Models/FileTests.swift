import Foundation
import Nimble
import Testing
@testable import OpenAI

@Test
func codableFile() throws {
	let fixedDate = Date(timeIntervalSince1970: 946684800) // January 1, 2000, at 00:00:00 UTC
	let file = File(
		id: "file-123",
		purpose: .assistants,
		filename: "test.txt",
		bytes: 100,
		createdAt: fixedDate,
		expiresAt: fixedDate,
		status: .uploaded)
	try assertCodable(file, resource: "File")
}
