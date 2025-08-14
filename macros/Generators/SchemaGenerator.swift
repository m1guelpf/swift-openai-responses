import SwiftSyntax

enum SchemaGenerator {
	static func `for`(_ declaration: some DeclGroupSyntax) throws -> VariableDeclSyntax {
		if let structDecl = declaration.as(StructDeclSyntax.self) {
			let generator = StructSchemaGenerator(fromStruct: structDecl)

			return try generator.makeSchema()
		}

		if let enumDecl = declaration.as(EnumDeclSyntax.self) {
			let generator = EnumSchemaGenerator(fromEnum: enumDecl)

			return try generator.makeSchema()
		}

		throw ReportableError(errorMessage: "The @Schema macro can only be applied to structs or enums.")
	}
}
