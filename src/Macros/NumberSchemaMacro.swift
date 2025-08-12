/// Customize the auto-generated JSON schema for a number or integer property.
///
/// - Parameter multipleOf: The number must be a multiple of this value.
/// - Parameter minimum: The number must be greater than or equal to this value.
/// - Parameter exclusiveMinimum: The number must be greater than this value.
/// - Parameter maximum: The number must be less than or equal to this value.
/// - Parameter exclusiveMaximum: The number must be less than this value.
@attached(peer)
public macro NumberSchema(
	multipleOf: Int? = nil,
	minimum: Int? = nil,
	exclusiveMinimum: Int? = nil,
	maximum: Int? = nil,
	exclusiveMaximum: Int? = nil,
) = #externalMacro(module: "Macros", type: "NumberSchemaMacro")
