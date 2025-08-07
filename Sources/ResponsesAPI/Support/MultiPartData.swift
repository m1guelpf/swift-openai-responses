import Foundation

final class FormData {
	enum Entry {
		case string(paramName: String, value: Any)

		case file(paramName: String, fileName: String, fileData: Data, contentType: String)

		var data: Data {
			var body = Data()

			switch self {
				case let .string(paramName, value):
					body.append("Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n")
					body.append("\(value)\r\n")

				case let .file(paramName, fileName, fileData, contentType):
					body.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n")
					body.append("Content-Type: \(contentType)\r\n\r\n")
					body.append(fileData)
					body.append("\r\n")
			}

			return body
		}
	}

	let boundary: String
	let entries: [Entry]

	init(boundary: String, entries: [Entry]) {
		self.entries = entries
		self.boundary = boundary
	}

	var data: Data {
		var httpData = entries.map(\.data).reduce(Data()) { result, element in
			var result = result

			result.append("--\(boundary)\r\n")
			result.append(element)

			return result
		}

		httpData.append("--\(boundary)--\r\n")
		return httpData
	}

	var header: String {
		return "multipart/form-data; boundary=\(boundary)"
	}
}

extension URLRequest {
	mutating func attach(formData form: FormData) {
		httpBody = form.data
		addValue(form.header, forHTTPHeaderField: "Content-Type")
	}
}

fileprivate extension Data {
	mutating func append(_ string: String) {
		if let data = string.data(using: .utf8, allowLossyConversion: true) {
			append(data)
		}
	}
}
