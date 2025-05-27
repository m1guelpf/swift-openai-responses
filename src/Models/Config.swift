import Foundation
import MetaCodable

/// Configuration options for [reasoning models](https://platform.openai.com/docs/guides/reasoning).
/// Only available for o-series models.
@Codable @CodingKeys(.snake_case) public struct ReasoningConfig: Equatable, Hashable, Sendable, Codable {
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
		case concise
		case detailed
	}

	/// Constrains effort on reasoning for [reasoning models](https://platform.openai.com/docs/guides/reasoning).
	///
	/// Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response.
	public var effort: Effort?

	/// A summary of the reasoning performed by the model. `computer_use_preview` only.
	///
	/// This can be useful for debugging and understanding the model's reasoning process.
	public var generateSummary: SummaryConfig?

	/// Creates a new `ReasoningConfig` instance.
	///
	/// - Parameter effort: Constrains effort on reasoning for reasoning models.
	/// - Parameter generateSummary: A summary of the reasoning performed by the model.
	public init(effort: Effort? = nil, generateSummary: SummaryConfig? = nil) {
		self.effort = effort
		self.generateSummary = generateSummary
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
			schema: Tool.Function.Parameters,
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
	/// If the Project is Scale tier enabled, the system will utilize scale tier credits until they are exhausted. Otherwise, the request will be processed using the default service tier with a lower uptime SLA and no latency guarentee.
	case auto
	/// The request will be processed using the default service tier with a lower uptime SLA and no latency guarentee.
	case `default`
	/// The request will be processed with the Flex Processing service tier.
	case flex
}
