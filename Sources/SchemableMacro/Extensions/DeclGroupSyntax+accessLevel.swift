import SwiftSyntax

extension DeclGroupSyntax {
	var accessLabel: String? {
		modifiers.first { modifier in
			["public", "internal", "package", "fileprivate", "private"].contains(modifier.name.text)
		}?.name.text
	}
}
