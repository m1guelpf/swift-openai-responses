import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public enum ToolMacroError: Error, CustomStringConvertible {
	case unsupportedDeclaration
	case functionNotFound

	public var description: String {
		switch self {
			case .unsupportedDeclaration: "The @Tool macro can only be applied to structs."
			case .functionNotFound: "The @Tool macro requires a function named 'call' in the struct."
		}
	}
}

public struct ToolMacro: ExtensionMacro {
	public static func expansion(
		of _: AttributeSyntax,
		attachedTo declaration: some DeclGroupSyntax,
		providingExtensionsOf type: some TypeSyntaxProtocol,
		conformingTo _: [TypeSyntax],
		in _: some MacroExpansionContext
	) throws -> [ExtensionDeclSyntax] {
		guard let structDecl = declaration.as(StructDeclSyntax.self) else {
			throw ToolMacroError.unsupportedDeclaration
		}

		// TODO: Check there's only one function named `call`, and that it's not the Toolable `call` method
		guard let functionDecl = structDecl.memberBlock.members.first(where: {
			$0.decl.as(FunctionDeclSyntax.self)?.name.text == "call"
		})?.decl.as(FunctionDeclSyntax.self) else {
			throw ToolMacroError.functionNotFound
		}
		let functionDocString = DocString.parse(functionDecl.docString)

		return try [
			ExtensionDeclSyntax(
				extendedType: type,
				inheritanceClause: InheritanceClauseSyntax {
					InheritedTypeSyntax(
						type: IdentifierTypeSyntax(name: "Toolable")
					)
				}
			) {
				try MemberBlockItemListSyntax {
					try addProperties(reading: structDecl, and: functionDocString)
					try addArguments(reading: functionDecl, and: functionDocString)
					try addFunction(reading: functionDecl, and: functionDocString)

					// TODO: Add `call(arguments: Arguments)` method
					// - Call the original `call` method with the `Arguments` properties
				}
			},
		]
	}

	private static func addProperties(
		reading structDecl: StructDeclSyntax,
		and functionDocString: DocString?
	) throws -> [VariableDeclSyntax] {
		var properties: [VariableDeclSyntax] = []
		let structDeclarations = structDecl.memberBlock.members

		if !structDeclarations.declaresVariable(named: "name") {
			try properties.append(VariableDeclSyntax("var name: String { \(literal: structDecl.name.text) }"))
		}

		if !structDeclarations.declaresVariable(named: "description"),
		   let description = functionDocString?.docString ?? structDecl.docString
		{
			try properties.append(VariableDeclSyntax("var description: String { \(literal: description) }"))
		}

		return properties.map(tapping: { $0.trailingTrivia = .newlines(2) })
	}

	private static func addArguments(
		reading functionDecl: FunctionDeclSyntax,
		and functionDocString: DocString?
	) throws -> StructDeclSyntax {
		var structDecl = try StructDeclSyntax(name: TokenSyntax(stringLiteral: "Arguments")) {
			// TODO: Ensure all parameters are 1) named 2) not variadic
			try functionDecl.signature.parameterClause.parameters.map { parameter in
				let name = (parameter.secondName ?? parameter.firstName).text
				var decl = try VariableDeclSyntax("let \(raw: name): \(parameter.type)")

				if let docString = functionDocString?.for(property: name), !docString.isEmpty {
					decl.leadingTrivia = .docLineComment("/// \(docString)").merging(.newline)
				}

				return decl
			}
		}

		structDecl.attributes.append(.attribute(AttributeSyntax("@Schemable")))
		structDecl.trailingTrivia = .newlines(2)

		return structDecl
	}

	private static func addFunction(
		reading functionDecl: FunctionDeclSyntax,
		and _: DocString?
	) throws -> FunctionDeclSyntax {
		let arguments = LabeledExprListSyntax(itemsBuilder: {
			functionDecl.signature.parameterClause.parameters.compactMap { parameter in
				let name = (parameter.secondName ?? parameter.firstName).text
				let expression: ExprSyntax = "arguments.\(raw: name)"

				return LabeledExprSyntax(label: name, expression: expression)
			}
		})

		return try FunctionDeclSyntax(
			"""
			func call(arguments: Arguments) async throws -> Output {
				try await self.call(\(arguments))
			}
			"""
		)
	}
}
