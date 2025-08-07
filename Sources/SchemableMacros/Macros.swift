import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main struct Macros: CompilerPlugin {
	let providingMacros: [Macro.Type] = [
		SchemableMacro.self,
		ArraySchemaMacro.self,
		StringSchemaMacro.self,
		NumberSchemaMacro.self,
	]
}
