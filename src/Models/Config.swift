import Foundation
import MetaCodable

/// Configuration options for [reasoning models](https://platform.openai.com/docs/guides/reasoning).
/// Only available for o-series models.
@Codable @CodingKeys(.snake_case) public struct ReasoningConfig: Equatable, Hashable, Sendable {
	/// Constrains effort on reasoning for [reasoning models](https://platform.openai.com/docs/guides/reasoning).
	///
	/// Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.
	public enum Effort: String, CaseIterable, Equatable, Hashable, Codable, Sendable {
		case low
		case high
		case medium
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
public struct TextConfig: Equatable, Hashable, Sendable {
	/// An object specifying the format that the model must output.
	public enum Format: Equatable, Hashable, Sendable {
		/// Used to generate text responses.
		case text
		/// JSON Schema response format. Used to generate structured JSON responses. Learn more about [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs).
		/// - Parameter schema: The schema for the response format, described as a JSON Schema object. Learn how to build JSON schemas [here](https://json-schema.org/).
		/// - Parameter description: A description of what the response format is for, used by the model to determine how to respond in the format.
		/// - Parameter name: The name of the response format. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.
		/// - Parameter strict: Whether to enable strict schema adherence when generating the output. If set to `true`, the model will always follow the exact schema defined in the schema field. Only a subset of JSON Schema is supported when `strict` is `true`.
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

extension TextConfig: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		format = try container.decode(Format.self, forKey: .format)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(format, forKey: .format)
	}

	private enum CodingKeys: String, CodingKey {
		case format
	}
}

extension TextConfig.Format: Codable {
	private enum CodingKeys: String, CodingKey {
		case type
		case schema
		case description
		case name
		case strict
	}

	private enum FormatType: String, Codable {
		case text
		case jsonSchema = "json_schema"
		case jsonObject = "json_object"
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let type = try container.decode(FormatType.self, forKey: .type)

		switch type {
		case .text:
			self = .text
		case .jsonObject:
			self = .jsonObject
		case .jsonSchema:
			let schema = try container.decode(JSONSchema.self, forKey: .schema)
			let description = try container.decode(String.self, forKey: .description)
			let name = try container.decode(String.self, forKey: .name)
			let strict = try container.decodeIfPresent(Bool.self, forKey: .strict)
			self = .jsonSchema(schema: schema, description: description, name: name, strict: strict)
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		switch self {
		case .text:
			try container.encode(FormatType.text, forKey: .type)
		case .jsonObject:
			try container.encode(FormatType.jsonObject, forKey: .type)
		case let .jsonSchema(schema, description, name, strict):
			try container.encode(FormatType.jsonSchema, forKey: .type)
			try container.encode(schema, forKey: .schema)
			try container.encode(description, forKey: .description)
			try container.encode(name, forKey: .name)
			try container.encodeIfPresent(strict, forKey: .strict)
		}
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
