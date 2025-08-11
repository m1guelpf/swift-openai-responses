import Foundation

extension Result {
	init(catching body: () async throws(Failure) -> Success) async {
		do {
			let value = try await body()
			self = .success(value)
		} catch { self = .failure(error) }
	}
}
