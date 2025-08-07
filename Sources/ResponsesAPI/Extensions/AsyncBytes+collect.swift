import Foundation

extension URLSession.AsyncBytes {
	func collect() async throws -> Data {
		var data = Data()

		for try await byte in self {
			data.append(byte)
		}

		return Data(data)
	}
}
