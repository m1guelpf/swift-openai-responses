/// Customize the auto-generated JSON schema for an array property.
///
/// - Parameter minItems: The minimum number of items in the array.
/// - Parameter maxItems: The maximum number of items in the array.
@attached(peer)
public macro ArraySchema(
	minItems: Int? = nil,
	maxItems: Int? = nil
) = #externalMacro(module: "Macros", type: "ArraySchemaMacro")
