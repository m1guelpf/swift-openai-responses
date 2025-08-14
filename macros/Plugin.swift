import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main struct Plugin: CompilerPlugin {
	let providingMacros: [Macro.Type] = [
		ToolMacro.self,
		SchemaMacro.self,
		ArraySchemaMacro.self,
		StringSchemaMacro.self,
		NumberSchemaMacro.self,
	]
}
