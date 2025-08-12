import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxMacros

struct ReportableError: Error {
	private let fixIts: [FixIt]
	private let message: MacroExpansionErrorMessage

	init(errorMessage message: String, fixIts: [FixIt] = []) {
		self.fixIts = fixIts
		self.message = MacroExpansionErrorMessage(message)
	}

	static func report<T>(in context: some MacroExpansionContext, for node: SyntaxProtocol, _ body: () throws -> T, withDefault: () -> T) throws -> T {
		do {
			return try body()
		} catch let error as ReportableError {
			context.diagnose(Diagnostic(node: node, message: error.message, fixIts: error.fixIts))
			return withDefault()
		}
	}
}
