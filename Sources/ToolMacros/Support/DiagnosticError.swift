import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxMacros

struct ReportableError: Error {
	fileprivate let diagnostic: Diagnostic

	init(node: SyntaxProtocol, errorMessage message: String, fixIts: [FixIt] = []) {
		diagnostic = Diagnostic(node: node, message: MacroExpansionErrorMessage(message), fixIts: fixIts)
	}

	static func report<T>(in context: some MacroExpansionContext, _ body: () throws -> T, withDefault: () -> T) throws -> T {
		do {
			return try body()
		} catch let error as ReportableError {
			context.diagnose(error.diagnostic)
			return withDefault()
		}
	}
}
