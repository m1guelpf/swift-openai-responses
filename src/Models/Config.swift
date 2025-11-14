import Foundation
import MetaCodable

/// Configuration options for [reasoning models](https://platform.openai.com/docs/guides/reasoning).
/// Only available for o-series models.
@Codable @CodingKeys(.snake_case) public struct ReasoningConfig: Equatable, Hashable, Sendable {
	/// Constrains effort on reasoning for [reasoning models](https://platform.openai.com/docs/guides/reasoning).
	///
	/// Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.
	public enum Effort: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
		case none, minimal, low, medium, high
	}

	/// A summary of the reasoning performed by the model.
	///
	/// This can be useful for debugging and understanding the model's reasoning process.
	public enum SummaryConfig: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
		case auto
		case concise
		case detailed
	}

	/// Constrains effort on reasoning for [reasoning models](https://platform.openai.com/docs/guides/reasoning).
	///
	/// Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.
	public var effort: Effort?

	/// A summary of the reasoning performed by the model.
	///
	/// This can be useful for debugging and understanding the model's reasoning process.
	public var summary: SummaryConfig?

	/// Creates a new `ReasoningConfig` instance.
	///
	/// - Parameter effort: Constrains effort on reasoning for reasoning models.
	/// - Parameter summary: A summary of the reasoning performed by the model.
	public init(effort: Effort? = nil, summary: SummaryConfig? = nil) {
		self.effort = effort
		self.summary = summary
	}
}

/// Configuration options for a text response from the model. Can be plain text or structured JSON data.
///
/// Learn more:
/// - [Text inputs and outputs](https://platform.openai.com/docs/guides/text)
/// - [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs)
public struct TextConfig: Equatable, Hashable, Codable, Sendable {
	/// An object specifying the format that the model must output.
	@Codable @CodedAt("type") @CodingKeys(.snake_case) public enum Format: Equatable, Hashable, Sendable {
		/// Used to generate text responses.
		case text

		/// JSON Schema response format. Used to generate structured JSON responses. Learn more about [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs).
		/// - Parameter schema: The schema for the response format, described as a JSON Schema object. Learn how to build JSON schemas [here](https://json-schema.org/).
		/// - Parameter description: A description of what the response format is for, used by the model to determine how to respond in the format.
		/// - Parameter name: The name of the response format. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.
		/// - Parameter strict: Whether to enable strict schema adherence when generating the output. If set to `true`, the model will always follow the exact schema defined in the schema field. Only a subset of JSON Schema is supported when `strict` is `true`.
		@CodedAs("json_schema")
		case jsonSchema(
			schema: JSONSchema,
			description: String,
			name: String,
			strict: Bool?
		)

		/// JSON object response format. An older method of generating JSON responses.
		///
		/// Using `jsonSchema` is recommended for models that support it.
		///
		/// Note that the model will not generate JSON without a system or user message instructing it to do so.
		@CodedAs("json_object")
		case jsonObject
	}

	/// An object specifying the format that the model must output.
	public var format: Format

	/// Creates a new `TextConfig` instance.
	///
	/// - Parameter format: An object specifying the format that the model must output.
	public init(format: Format = .text) {
		self.format = format
	}
}

/// The truncation strategy to use for the model response.
public enum Truncation: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
	/// If the context of this response and previous ones exceeds the model's context window size, the model will truncate the response to fit the context window by dropping input items in the middle of the conversation.
	case auto

	/// If a model response will exceed the context window size for a model, the request will fail with a 400 error.
	case disabled
}

/// The latency to use when processing the request
public enum ServiceTier: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
	/// The request will be processed with the service tier configured in the Project settings.
	///
	/// Unless otherwise configured, the Project will use 'default'.
	case auto

	/// The requset will be processed with the standard pricing and performance for the selected model.
	case `default`

	/// The request will be processed with the Flex Processing service tier.
	case flex

	/// The request will be processed with the Priority Processing service tier.
	case priority
}

public struct Prompt: Equatable, Hashable, Codable, Sendable {
	/// The unique identifier of the prompt template to use.
	public var id: String

	/// Optional version of the prompt template.
	public var version: String?

	/// Optional map of values to substitute in for variables in your prompt.
	///
	/// The substitution values can either be strings, or other Response input types like images or files.
	public var variables: [String: String]?

	/// Creates a new `Prompt` instance.
	/// - Parameter id: The unique identifier of the prompt template to use.
	/// - Parameter version: Optional version of the prompt template.
	/// - Parameter variables: Optional map of values to substitute in for variables in your prompt.
	public init(id: String, version: String? = nil, variables: [String: String]? = nil) {
		self.id = id
		self.version = version
		self.variables = variables
	}
}

/// Constrains the verbosity of the model's response.
public enum Verbosity: String, Equatable, Hashable, Codable, Sendable {
	case low, medium, high
}

public enum Order: String, Equatable, Hashable, Codable, Sendable {
	/// Return the input items in ascending order.
	case asc

	/// Return the input items in descending order.
	case desc
}

public enum CacheRetention: String, Equatable, Hashable, Codable, Sendable {
	case oneDay = "24h"
	case inMemory = "in_memory"
}

public extension TextConfig.Format {
	/// JSON Schema response format. Used to generate structured JSON responses. Learn more about [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs).
	/// - Parameter schemable: A type conforming to `Schemable`, which provides the schema for the response format.
	/// - Parameter description: A description of what the response format is for, used by the model to determine how to respond in the format.
	/// - Parameter name: The name of the response format. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.
	/// - Parameter strict: Whether to enable strict schema adherence when generating the output. If set to `true`, the model will always follow the exact schema defined in the schema field. Only a subset of JSON Schema is supported when `strict` is `true`.
	static func jsonSchema<T: Schemable>(_: T.Type, description: String, name: String, strict: Bool? = true) -> Self {
		.jsonSchema(schema: T.schema, description: description, name: name, strict: strict)
	}
}
