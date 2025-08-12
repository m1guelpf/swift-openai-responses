/// Customize the auto-generated JSON schema for a string property.
///
/// - Parameter pattern: A regular expression pattern that the string must match.
/// - Parameter format: An optional format for the string, such as email or date.
@attached(peer)
public macro StringSchema(
	pattern: String? = nil,
	format: JSONSchema.StringFormat? = nil
) = #externalMacro(module: "Macros", type: "StringSchemaMacro")
