import SwiftSyntax
import SwiftSyntaxMacros

public enum SchemableError: Error, CustomStringConvertible {
	case unsupportedDeclaration

	public var description: String {
		switch self {
			case .unsupportedDeclaration: "The @Schemable macro can only be applied to structs or enums."
		}
	}
}

public struct SchemableMacro: ExtensionMacro {
	public static func expansion(
		of _: AttributeSyntax,
		attachedTo declaration: some DeclGroupSyntax,
		providingExtensionsOf type: some TypeSyntaxProtocol,
		conformingTo _: [TypeSyntax],
		in context: some MacroExpansionContext
	) throws -> [ExtensionDeclSyntax] {
		let implementation: VariableDeclSyntax
		if let structDecl = declaration.as(StructDeclSyntax.self) {
			let generator = StructSchemaGenerator(fromStruct: structDecl, using: context)

			implementation = try generator.makeSchema()
		} else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
			let generator = EnumSchemaGenerator(fromEnum: enumDecl, using: context)

			implementation = try generator.makeSchema()
		} else {
			throw SchemableError.unsupportedDeclaration
		}

		return [
			ExtensionDeclSyntax(
				extendedType: type,
				inheritanceClause: InheritanceClauseSyntax { InheritedTypeSyntax(
					type: IdentifierTypeSyntax(name: "Schemable")
				) },
			) { MemberBlockItemListSyntax { implementation } },
		]
	}
}
