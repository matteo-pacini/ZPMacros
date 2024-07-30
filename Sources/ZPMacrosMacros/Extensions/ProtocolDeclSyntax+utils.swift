import SwiftSyntax

extension ProtocolDeclSyntax {

    var accessLevel: String {
        modifiers.first?.trimmedDescription ?? ""
    }

    var methods: [FunctionDeclSyntax] {
        memberBlock.members
            .map(\.decl)
            .compactMap { declaration -> FunctionDeclSyntax? in
                guard let function = declaration.as(FunctionDeclSyntax.self) else {
                    return nil
                }
                return function
            }
    }

}
