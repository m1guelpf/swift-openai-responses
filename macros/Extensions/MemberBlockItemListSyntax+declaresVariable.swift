import SwiftSyntax

extension MemberBlockItemListSyntax {
	/// Checks if the member block contains a variable declaration with the specified name.
	func declaresVariable(named name: String) -> Bool {
		contains(where: { member in
			member.decl.as(VariableDeclSyntax.self)?.bindings.contains(where: { binding in
				binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == name
			}) ?? false
		})
	}
}
