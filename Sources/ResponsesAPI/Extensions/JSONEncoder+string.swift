import Foundation

extension JSONEncoder {
	func encodeToString<T: Encodable>(_ value: T) throws -> String {
		let data = try encode(value)

		guard let string = String(data: data, encoding: .utf8) else {
			throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Unable to convert data to string"))
		}

		return string
	}
}
