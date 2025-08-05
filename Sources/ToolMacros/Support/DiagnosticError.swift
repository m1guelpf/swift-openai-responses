import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxMacros

extension MacroExpansionContext {
	func report(_ error: ReportableError) {
		diagnose(error.diagnostic)
	}
}

struct ReportableError: Error {
	fileprivate let diagnostic: Diagnostic

	init(node: SyntaxProtocol, message: DiagnosticMessage) {
		diagnostic = Diagnostic(node: node, message: message)
	}

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
