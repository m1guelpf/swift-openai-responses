import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxMacros

struct ReportableError: Error {
	private let fixIts: [FixIt]
	private let node: SyntaxProtocol?
	private let message: MacroExpansionErrorMessage

	init(node: SyntaxProtocol? = nil, errorMessage message: String, fixIts: [FixIt] = []) {
		self.node = node
		self.fixIts = fixIts
		self.message = MacroExpansionErrorMessage(message)
	}

	static func report<T>(in context: some MacroExpansionContext, for node: SyntaxProtocol, _ body: () throws -> T, withDefault: () -> T) throws -> T {
		do {
			return try body()
		} catch let error as ReportableError {
			let errorNode = error.node ?? node
			context.diagnose(Diagnostic(node: errorNode, message: error.message, fixIts: error.fixIts))
			return withDefault()
		}
	}
}
