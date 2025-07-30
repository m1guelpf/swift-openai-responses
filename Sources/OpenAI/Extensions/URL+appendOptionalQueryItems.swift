import Foundation

extension URL {
	mutating func append(queryItems: [URLQueryItem?]) {
		append(queryItems: queryItems.compactMap { $0 })
	}
}
