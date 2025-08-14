import SwiftSyntax
import SwiftSyntaxMacros

public struct SchemaMacro: ExtensionMacro {
	public static func expansion(
		of _: AttributeSyntax,
		attachedTo declaration: some DeclGroupSyntax,
		providingExtensionsOf type: some TypeSyntaxProtocol,
		conformingTo _: [TypeSyntax],
		in context: some MacroExpansionContext
	) throws -> [ExtensionDeclSyntax] {
		return try ReportableError.report(in: context, for: declaration) {
			try [
				ExtensionDeclSyntax(extending: type, inheritsTypes: ["Schemable"]) {
					try SchemaGenerator.for(declaration)
				},
			]
		} withDefault: { [] }
	}
}
