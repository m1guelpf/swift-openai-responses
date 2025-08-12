import SwiftSyntax
import SwiftSyntaxMacros

struct StructSchemaGenerator {
	let name: TokenSyntax
	let docString: String?
	let context: MacroExpansionContext
	let attributes: AttributeListSyntax
	let declModifier: DeclModifierSyntax?
	let members: MemberBlockItemListSyntax

	init(fromStruct structDecl: StructDeclSyntax, using context: some MacroExpansionContext) {
		self.context = context
		name = structDecl.name.trimmed
		docString = structDecl.docString
		attributes = structDecl.attributes
		members = structDecl.memberBlock.members
		declModifier = structDecl.modifiers.first
	}

	func makeSchema() throws -> VariableDeclSyntax {
		let members = members
			.compactMap { $0.decl.as(VariableDeclSyntax.self) }
			.flatMap { variableDecl in variableDecl.bindings.map { (variableDecl, $0) } }
			.filter { $0.1.isStored }
			.compactMap { StructMember(variableDecl: $0, patternBinding: $1, using: context) }

		let properties = DictionaryExprSyntax {
			DictionaryElementListSyntax(members.enumerated().compactMap { i, member -> DictionaryElementSyntax? in
				guard let schema = member.makeSchema(using: context) else { return nil }

				return DictionaryElementSyntax(
					leadingTrivia: .newline.merging(.tabs(2)),
					key: ExprSyntax(literal: member.identifier.text),
					value: ExprSyntax(schema),
					trailingComma: .commaToken(),
					trailingTrivia: i == members.count - 1 ? .newline.merging(.tab) : nil
				)
			})
		}

		return try VariableDeclSyntax("""
		\(declModifier)static var schema: JSONSchema {
			.object(properties: \(raw: properties), description: \(literal: docString))
		}
		""")
	}
}

extension StructSchemaGenerator {
	struct StructMember {
		let type: TypeSyntax
		let docString: String?
		let identifier: TokenSyntax
		let defaultValue: ExprSyntax?
		let declaration: any SyntaxProtocol
		let attributes: AttributeListSyntax

		init(declaration: some SyntaxProtocol, type: TypeSyntax, identifier: TokenSyntax, docString: String? = nil, attributes: AttributeListSyntax = AttributeListSyntax([])) {
			self.type = type
			defaultValue = nil
			self.docString = docString
			self.identifier = identifier
			self.attributes = attributes
			self.declaration = declaration
		}

		init?(variableDecl: VariableDeclSyntax, patternBinding: PatternBindingSyntax, using context: some MacroExpansionContext) {
			guard let identifier = patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier else { return nil }
			guard let type = patternBinding.typeAnnotation?.type else {
				context.diagnose(.init(
					node: variableDecl,
					message: MacroExpansionErrorMessage("You must provide a type for the property '\(identifier.text)'.")
				))
				return nil
			}

			self.type = type
			declaration = variableDecl
			self.identifier = identifier
			docString = variableDecl.docString
			attributes = variableDecl.attributes
			defaultValue = patternBinding.initializer?.value
		}

		func makeSchema(using context: some MacroExpansionContext) -> ExprSyntax? {
			if defaultValue != nil {
				let type = StructMember(declaration: declaration, type: type, identifier: identifier)
				guard let schema = type.makeSchema(using: context) else { return nil }
				return ".anyOf([\(raw: schema), .null], description: \(literal: docString))"
			}

			switch type.typeInfo {
				case .notSupported: return nil
				case let .schemable(type): return "\(raw: type).schema(description: \(literal: docString))"
				case let .primitive(primitive):
					switch primitive {
						case .bool: return ".boolean(description: \(literal: docString))"
						case .int:
							var options = attributes.arguments(for: "NumberSchema") ?? LabeledExprListSyntax()
							options.append(LabeledExprSyntax(label: "description", expression: ExprSyntax(literal: docString)))
							return ".integer(\(options))"
						case .string:
							var options = attributes.arguments(for: "StringSchema") ?? LabeledExprListSyntax()
							options.append(LabeledExprSyntax(label: "description", expression: ExprSyntax(literal: docString)))
							return ".string(\(options))"
						case .double, .float:
							var options = attributes.arguments(for: "NumberSchema") ?? LabeledExprListSyntax()
							options.append(LabeledExprSyntax(label: "description", expression: ExprSyntax(literal: docString)))
							return ".number(\(options))"
						case let .array(type):
							let type = StructMember(declaration: declaration, type: type, identifier: identifier, attributes: attributes)
							guard let schema = type.makeSchema(using: context) else { return nil }

							var options = attributes.arguments(for: "ArraySchema") ?? LabeledExprListSyntax()
							options.append(LabeledExprSyntax(label: "description", expression: ExprSyntax(literal: docString)))
							return ".array(of: \(raw: schema), \(raw: options))"
						case let .optional(type):
							let type = StructMember(declaration: declaration, type: type, identifier: identifier, attributes: attributes)
							guard let schema = type.makeSchema(using: context) else { return nil }
							return ".anyOf([\(raw: schema), .null], description: \(literal: docString))"
						case .dictionary:
							context.diagnose(.init(
								node: declaration,
								message: MacroExpansionErrorMessage("Dictionaries are not supported when using @Schemable. Use a custom struct instead.")
							))
							return nil
					}
			}
		}
	}
}
