import SwiftSyntax

extension TypeSyntax {
	enum TypeInformation: Equatable {
		indirect enum SupportedPrimitive: RawRepresentable, Equatable {
			case int
			case bool
			case float
			case double
			case string
			case dictionary
			case array(TypeSyntax)
			case optional(TypeSyntax)

			var rawValue: String {
				switch self {
					case .int: return "Int"
					case .bool: return "Bool"
					case .array: return "Array"
					case .float: return "Float"
					case .double: return "Double"
					case .string: return "String"
					case .optional: return "Optional"
					case .dictionary: return "Dictionary"
				}
			}

			init?(rawValue: String) {
				switch rawValue {
					case "Int": self = .int
					case "Bool": self = .bool
					case "Float": self = .float
					case "Double": self = .double
					case "String": self = .string
					case "Dictionary": self = .dictionary
					default: return nil
				}
			}
		}

		case notSupported
		case schemable(String)
		case primitive(SupportedPrimitive)
	}

	var typeInfo: TypeInformation {
		let type = self.as(TypeSyntaxEnum.self)

		switch type {
			case .dictionaryType: return .primitive(.dictionary)
			case let .someOrAnyType(type): return type.constraint.typeInfo
			case let .arrayType(itemType): return .primitive(.array(itemType.element))
			case let .optionalType(type): return .primitive(.optional(type.wrappedType))
			case let .implicitlyUnwrappedOptionalType(type): return type.wrappedType.typeInfo
			case let .identifierType(type):
				if let generic = type.genericArgumentClause {
					if type.name.text == "Array" {
						let arrayType = ArrayTypeSyntax(element: generic.arguments.first!.argument)
						return TypeSyntax(arrayType).typeInfo
					}

					if type.name.text == "Dictionary" {
						let dictTypes = Array(generic.arguments.prefix(2))
						let dictionaryType = DictionaryTypeSyntax(key: dictTypes[0].argument, value: dictTypes[1].argument)
						return TypeSyntax(dictionaryType).typeInfo
					}
				}

				if let primitive = TypeInformation.SupportedPrimitive(rawValue: type.name.text) {
					return .primitive(primitive)
				}

				return .schemable(type.name.text)
			case .packElementType, .metatypeType, .missingType,
			     .suppressedType, .functionType, .classRestrictionType,
			     .attributedType, .packExpansionType, .namedOpaqueReturnType,
			     .tupleType, .memberType, .compositionType: return .notSupported
		}
	}
}
