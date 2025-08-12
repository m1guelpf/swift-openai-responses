import SwiftSyntax

extension PatternBindingSyntax {
	var isStored: Bool {
		switch accessorBlock?.accessors {
			case nil: return true
			case .getter: return false
			case let .accessors(accessors):
				for accessor in accessors {
					switch accessor.accessorSpecifier.tokenKind {
						case .keyword(.willSet), .keyword(.didSet): break
						default: return false
					}
				}
				return true
		}
	}
}
