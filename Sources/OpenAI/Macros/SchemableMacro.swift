/// Automatically generate a JSON Schema for a Swift type.
///
/// This macro conforms the type to the `Schemable` protocol
@attached(extension, conformances: Schemable, names: named(schema))
public macro Schemable() = #externalMacro(
	module: "SchemableMacro", type: "SchemableMacro"
)
