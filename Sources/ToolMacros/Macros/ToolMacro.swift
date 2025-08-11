import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct ToolMacro: ExtensionMacro {
	public static func expansion(
		of _: AttributeSyntax,
		attachedTo declaration: some DeclGroupSyntax,
		providingExtensionsOf type: some TypeSyntaxProtocol,
		conformingTo _: [TypeSyntax],
		in context: some MacroExpansionContext
	) throws -> [ExtensionDeclSyntax] {
		return try ReportableError.report(in: context) {
			guard let structDecl = declaration.as(StructDeclSyntax.self) else {
				throw ReportableError(node: declaration, errorMessage: "The @Tool macro can only be applied to structs.")
			}

			let functionDecl = try getFunctionDeclaration(from: structDecl)
			let functionDocString = DocString.parse(functionDecl.docString)

			if functionDocString.isMissing {
				context.diagnose(Diagnostic(node: functionDecl, message: MacroExpansionWarningMessage(
					"It's recommended to add documentation to the `call` function of your tool to help the model understand its purpose and usage."
				)))
			}

			return try [
				ExtensionDeclSyntax(
					extendedType: type,
					inheritanceClause: InheritanceClauseSyntax { InheritedTypeSyntax(
						type: IdentifierTypeSyntax(name: "Toolable")
					) },
				) {
					try MemberBlockItemListSyntax {
						try addTypes(reading: functionDecl)
						try addProperties(reading: structDecl, and: functionDocString)
						try addArguments(reading: functionDecl, and: functionDocString)
						try addFunction(reading: functionDecl, and: functionDocString)
					}
				},
			]
		} withDefault: { [] }
	}

	private static func getFunctionDeclaration(from structDecl: StructDeclSyntax) throws -> FunctionDeclSyntax {
		let functionDecls = structDecl.memberBlock.members.filter { $0.decl.as(FunctionDeclSyntax.self)?.name.text == "call" }

		guard functionDecls.count <= 1 else {
			throw ReportableError(node: structDecl, errorMessage: "Structs annotated with the @Tool macro may only contain a single `call` function.")
		}
		guard let functionDecl = functionDecls.first?.decl.as(FunctionDeclSyntax.self) else {
			throw try ReportableError(
				node: structDecl,
				errorMessage: "Structs annotated with the @Tool macro must contain a `call` function.",
				fixIts: [
					FixIt(message: MacroExpansionFixItMessage("Add a `call` function"), changes: [
						FixIt.Change.replace(oldNode: Syntax(structDecl), newNode: Syntax(tap(structDecl) { structDecl in
							try structDecl.memberBlock.members.append(MemberBlockItemSyntax(leadingTrivia: .newline, decl: FunctionDeclSyntax("""
								/// <#Describe the purpose of your tool to help the model understand when to use it#>
								func call(<#Any arguments your tool call requires#>) async throws {
									<#The implementation of your tool call, which can optionally return information to the model#>
								}
							"""), trailingTrivia: .newline))
						})),
					]),
				]
			)
		}

		guard !functionDecl.signature.parameterClause.parameters.allSatisfy({
			$0.firstName.text == "parameters" && $0.type.as(IdentifierTypeSyntax.self)?.name.text == "Arguments"
		}) else {
			throw ReportableError(
				node: functionDecl,
				errorMessage: "When using the @Tool macro, use function parameters directly instead of manually creating an `Arguments` struct."
			)
		}

		return functionDecl
	}

	private static func addTypes(reading functionDecl: FunctionDeclSyntax) throws -> [TypeAliasDeclSyntax] {
		let returnType = functionDecl.signature.returnClause?.type
		let errorType = switch functionDecl.signature.effectSpecifiers?.throwsClause {
			case .none: IdentifierTypeSyntax(name: TokenSyntax(stringLiteral: "Never"))
			case let .some(throwsClause):
				if let type = throwsClause.type { type.as(IdentifierTypeSyntax.self)! }
				else { IdentifierTypeSyntax(name: TokenSyntax(stringLiteral: "Swift.Error")) }
		}

		return [
			TypeAliasDeclSyntax(name: TokenSyntax(stringLiteral: "Error"), initializer: TypeInitializerClauseSyntax(value: errorType)),
			TypeAliasDeclSyntax(name: TokenSyntax(stringLiteral: "Output"), initializer: TypeInitializerClauseSyntax(value: returnType ?? "Void"), trailingTrivia: .newlines(2)),
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

		if !structDeclarations.declaresVariable(named: "description"), let description = functionDocString?.docString ?? structDecl.docString, !description.isPlaceholder {
			try properties.append(VariableDeclSyntax("var description: String { \(literal: description) }"))
		}

		return properties.map(tapping: { $0.trailingTrivia = .newlines(2) })
	}

	private static func addArguments(
		reading functionDecl: FunctionDeclSyntax,
		and functionDocString: DocString?
	) throws -> StructDeclSyntax {
		var structDecl = try StructDeclSyntax(name: TokenSyntax(stringLiteral: "Arguments")) {
			try functionDecl.signature.parameterClause.parameters.map { parameter in
				if parameter.firstName.text == "_" {
					throw ReportableError(node: parameter, errorMessage: "All parameters must be named.")
				}

				var decl = try VariableDeclSyntax("let \(raw: (parameter.secondName ?? parameter.firstName).text): \(parameter.type)")

				if let docString = functionDocString?.for(properties: parameter.firstName.text, parameter.secondName?.text), !docString.isEmpty {
					decl.leadingTrivia = .docLineComment("/// \(docString)").merging(.newline)
				}

				return decl
			}
		}

		structDecl.trailingTrivia = .newlines(2)
		structDecl.attributes.append(.attribute(AttributeSyntax("@Schemable")))
		structDecl.inheritanceClause = InheritanceClauseSyntax {
			InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "Decodable"))
		}

		return structDecl
	}

	private static func addFunction(
		reading functionDecl: FunctionDeclSyntax,
		and _: DocString?
	) throws -> FunctionDeclSyntax {
		let arguments = LabeledExprListSyntax(itemsBuilder: {
			functionDecl.signature.parameterClause.parameters.compactMap { parameter in
				let name = (parameter.secondName ?? parameter.firstName).text
				let expression: ExprSyntax = "parameters.\(raw: name)"

				return LabeledExprSyntax(label: parameter.firstName.text, expression: expression)
			}
		})

		return try FunctionDeclSyntax(
			"""
			func call(parameters: Arguments) async throws -> Output {
				try await self.call(\(arguments))
			}
			"""
		)
	}
}
