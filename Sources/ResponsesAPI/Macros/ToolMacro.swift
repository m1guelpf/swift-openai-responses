/// Automatically generate a Tool from a struct with a `call` method.
///
/// When declaring your tool, make sure you specify documentation for both
/// the function (explaining what the tool does) and each parameter
/// (explaining what the parameter is for), like so:
///
/// ```swift
/// @Tool
/// struct GetWeather {
///		/// Get the weather for a location.
///		/// - Parameter location: The location to get the weather for.
///		func call(location: String) -> String {
///			"Sunny in \(location)"
///		}
/// }
/// ```
///
/// This macro conforms the type to the `Toolable` protocol
@attached(
	extension,
	conformances: Toolable,
	names: named(name), named(description), named(Arguments), named(Error), named(Output), named(call)
)
public macro Tool() = #externalMacro(
	module: "ToolMacros", type: "ToolMacro"
)
