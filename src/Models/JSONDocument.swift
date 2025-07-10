import Foundation

public typealias JSONObject = [String: AnyJSONDocument]

public protocol JSONDocument: Equatable, Hashable, Codable, Sendable {}

extension Int: JSONDocument {}
extension Bool: JSONDocument {}
extension String: JSONDocument {}
extension Decimal: JSONDocument {}
struct JSONNullValue: JSONDocument {}
extension Array: JSONDocument where Element: JSONDocument {}
extension Dictionary: JSONDocument where Key == String, Value: JSONDocument {}

public struct AnyJSONDocument: JSONDocument, Equatable, Hashable, Codable, Sendable {
	let value: any JSONDocument

	public init(_ value: any JSONDocument) {
		self.value = value
	}

	public func encode(to encoder: Encoder) throws {
		try value.encode(to: encoder)
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()

		if container.decodeNil() { value = JSONNullValue() }
		else if let intVal = try? container.decode(Int.self) { value = intVal }
		else if let decimalVal = try? container.decode(Decimal.self) { value = decimalVal }
		else if let boolVal = try? container.decode(Bool.self) { value = boolVal }
		else if let stringVal = try? container.decode(String.self) { value = stringVal }
		else if let arrayVal = try? container.decode([AnyJSONDocument].self) { value = arrayVal }
		else if let dictVal = try? container.decode([String: AnyJSONDocument].self) { value = dictVal }
		else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSONDocument type.") }
	}

	public static func == (lhs: AnyJSONDocument, rhs: AnyJSONDocument) -> Bool {
		switch (lhs.value, rhs.value) {
			case let (l as Int, r as Int): return l == r
			case let (l as Bool, r as Bool): return l == r
			case let (l as String, r as String): return l == r
			case let (l as Decimal, r as Decimal): return l == r
			case (_ as JSONNullValue, _ as JSONNullValue): return true
			case let (l as [any JSONDocument], r as [any JSONDocument]):
				return zip(l, r).allSatisfy { AnyJSONDocument($0) == AnyJSONDocument($1) }
			case let (l as [String: any JSONDocument], r as [String: any JSONDocument]):
				return l.count == r.count &&
					l.keys.allSatisfy { key in
						if let lv = l[key], let rv = r[key] {
							return AnyJSONDocument(lv) == AnyJSONDocument(rv)
						}
						return false
					}
			default: return false
		}
	}

	public func hash(into hasher: inout Hasher) {
		switch value {
			case let v as Int:
				hasher.combine(0); hasher.combine(v)
			case let v as Decimal:
				hasher.combine(1); hasher.combine(v)
			case let v as String:
				hasher.combine(2); hasher.combine(v)
			case let v as Bool:
				hasher.combine(3); hasher.combine(v)
			case _ as JSONNullValue:
				hasher.combine(4)
			case let v as [any JSONDocument]:
				hasher.combine(5)
				v.forEach { hasher.combine(AnyJSONDocument($0)) }
			case let v as [String: any JSONDocument]:
				hasher.combine(6)
				for (k, v) in v.sorted(by: { $0.key < $1.key }) {
					hasher.combine(k)
					hasher.combine(AnyJSONDocument(v))
				}
			default:
				break
		}
	}
}
