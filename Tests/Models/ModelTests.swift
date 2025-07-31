import Foundation
import Nimble
import Testing
@testable import OpenAI

@Test
func codableModel() throws {
	let model = Model.gpt4o
	try assertCodable(model, resource: "Model")
}
