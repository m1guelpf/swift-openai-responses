import SwiftSyntax
import SwiftSyntaxBuilder

extension ExtensionDeclSyntax {
	init(extending extendedType: TypeSyntaxProtocol, inheritsTypes inheritedTypes: [TokenSyntax] = [], @MemberBlockItemListBuilder _ itemsBuilder: () throws -> MemberBlockItemListSyntax) throws {
		try self.init(
			extendedType: extendedType,
			inheritanceClause: InheritanceClauseSyntax {
				inheritedTypes.map { type in
					InheritedTypeSyntax(type: IdentifierTypeSyntax(name: type))
				}
			}
		) {
			try MemberBlockItemListSyntax(itemsBuilder: itemsBuilder)
		}
	}
}
