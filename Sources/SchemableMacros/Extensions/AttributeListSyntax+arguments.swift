import SwiftSyntax

extension AttributeListSyntax {
	func arguments(for attributeName: String) -> LabeledExprListSyntax? {
		guard let argumentList = compactMap({ $0.as(AttributeSyntax.self) })
			.first(where: {
				if let attributeIdentifier = $0.attributeName.as(IdentifierTypeSyntax.self) {
					return attributeIdentifier.name.text == attributeName
				}

				return false
			})?
			.arguments?
			.as(LabeledExprListSyntax.self) else { return nil }

		return LabeledExprListSyntax(argumentList.map {
			$0.with(\.trailingComma, .commaToken())
		})
	}
}
