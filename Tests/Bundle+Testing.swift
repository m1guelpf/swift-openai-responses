import Foundation
import Testing

func loadJSON(for resource: String) throws -> Data {
    guard let fileURL = Bundle.module.url(forResource: resource, withExtension: "json") else {
        throw NSError(
            domain: "BundleTesting",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Could not find \(resource).json in test bundle"]
        )
    }
    return try Data(contentsOf: fileURL)
}

func loadJSONString(for resource: String) throws -> String {
    guard let fileURL = Bundle.module.url(forResource: resource, withExtension: "json") else {
        throw NSError(
            domain: "BundleTesting",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Could not find \(resource).json in test bundle"]
        )
    }
    return try String(contentsOf: fileURL, encoding: .utf8)
}

/// Use `UPDATE_SNAPSHOTS=1 swift test` from the project root to update the expected JSON files.
let updateExpectedJSON = ProcessInfo.processInfo.environment["UPDATE_SNAPSHOTS"] == "1"

func encodeJSONString(_ obj: some Encodable, to resource: String) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let json = try encoder.encode(obj)
    let jsonString = String(data: json, encoding: .utf8)!

    if updateExpectedJSON {
        let fileURL = URL(fileURLWithPath: "Tests/Resources/" + resource + ".json")
        try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    return jsonString
}

func assertCodable<T: Codable & Equatable>(
    _ value: T,
    resource: String,
    file _: StaticString = #filePath,
    line _: UInt = #line
) throws {
    let jsonString = try encodeJSONString(value, to: resource)

    let expectedJSONString = try loadJSONString(for: resource)
    #expect(jsonString == expectedJSONString, """
        Expected JSON:
        \(expectedJSONString)

        Actual JSON:
        \(jsonString)
        """)

    let decoded = try JSONDecoder().decode(T.self, from: jsonString.data(using: .utf8)!)
    #expect(decoded == value)
}
