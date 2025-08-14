import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

struct EnumSchemaGenerator {
	let name: TokenSyntax
	let docString: String?
	let attributes: AttributeListSyntax
	let declModifier: DeclModifierSyntax?
	let members: MemberBlockItemListSyntax

	init(fromEnum enumDecl: EnumDeclSyntax) {
		name = enumDecl.name.trimmed
		docString = enumDecl.docString
		attributes = enumDecl.attributes
		members = enumDecl.memberBlock.members
		declModifier = enumDecl.modifiers.first
	}

	func makeSchema() throws -> VariableDeclSyntax {
		let schemableCases = members
			.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
			.flatMap { caseDecl in caseDecl.elements.map { (caseDecl, $0) } }
			.map(EnumCase.init)

		let casesWithoutAssociatedValues = schemableCases.filter { $0.associatedValues == nil }
		let casesWithAssociatedValues = schemableCases.filter { $0.associatedValues != nil }

		guard !casesWithAssociatedValues.isEmpty else {
			let expr = try buildSimpleEnum(withCases: casesWithoutAssociatedValues)

			return try VariableDeclSyntax("""
			\(declModifier)static var schema: JSONSchema {
				\(raw: expr)
			}
			""")
		}

		var cases = try casesWithAssociatedValues.map { try $0.makeSchema() }
		if !casesWithoutAssociatedValues.isEmpty { cases = try [buildSimpleEnum(withCases: casesWithoutAssociatedValues, includeComment: false)] + cases }

		return try VariableDeclSyntax("""
		\(declModifier)static var schema: JSONSchema {
			.anyOf(\(raw: ArrayElementListSyntax(expressions: cases)), description: \(literal: docString))
		}
		""")
	}

	func buildSimpleEnum(withCases cases: [EnumCase], includeComment: Bool = true) throws -> ExprSyntax {
		var docString = includeComment ? self.docString : nil
		let caseComments = cases
			.filter { $0.docString != nil }
			.map { "- \($0.identifier.text): \($0.docString!)" }
			.joined(separator: "\n")

		if !caseComments.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			docString = docString != nil ? "\(docString!)\n\n" : ""
			docString! += caseComments
		}

		return try ".enum(cases: [\(raw: ArrayElementListSyntax(expressions: cases.map { try $0.makeSchema() }))], description: \(literal: docString))"
	}
}

extension EnumSchemaGenerator {
	struct EnumCase {
		let docString: String?
		let identifier: TokenSyntax
		let declaration: SyntaxProtocol
		let associatedValues: EnumCaseParameterListSyntax?

		init(enumCaseDecl: EnumCaseDeclSyntax, caseElement: EnumCaseElementSyntax) {
			declaration = enumCaseDecl
			docString = enumCaseDecl.docString
			identifier = caseElement.name.trimmed
			associatedValues = caseElement.parameterClause?.parameters
		}

		func makeSchema() throws -> ExprSyntax {
			guard let associatedValues else { return "\(literal: identifier.text)" }
			var docString = self.docString
			var propertyDocStrings: [String: String] = [:]

			if docString != nil {
				let regex = /- Parameter (?<parameter>\w*): ?(?<comment>.*)/

				for match in docString!.matches(of: regex) {
					docString!.removeSubrange(match.range.lowerBound..<match.range.upperBound)
					propertyDocStrings[String(match.output.parameter)] = String(match.output.comment)
				}

				docString = docString!.trimmingCharacters(in: .whitespacesAndNewlines)
			}

			let properties = try DictionaryElementListSyntax(
				associatedValues.enumerated()
					.compactMap { i, property -> DictionaryElementSyntax? in
						let key = property.firstName?.text ?? "_\(i)"

						let parameter = StructSchemaGenerator.StructMember(
							declaration: declaration,
							type: property.type,
							identifier: TokenSyntax(stringLiteral: key),
							docString: propertyDocStrings[key]
						)

						guard let schema = try parameter.makeSchema() else { return nil }
						return DictionaryElementSyntax(
							key: ExprSyntax(literal: key),
							value: schema
						)
					}
			)

			return """
			.object(properties: [\(literal: identifier.text): .object(properties: [\(raw: properties)])], description: \(literal: docString))
			"""
		}
	}
}
