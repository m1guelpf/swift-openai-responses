import SwiftSyntax
import SwiftSyntaxMacros

public struct NumberSchemaMacro: PeerMacro {
	public static func expansion(
		of _: AttributeSyntax,
		providingPeersOf _: some DeclSyntaxProtocol,
		in _: some MacroExpansionContext
	) throws -> [DeclSyntax] { [] }
}
