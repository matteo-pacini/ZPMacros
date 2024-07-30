import SwiftSyntax

extension FunctionDeclSyntax {

    var isAsync: Bool {
        signature.effectSpecifiers?.asyncSpecifier != nil
    }

    var `throws`: Bool {
        signature.effectSpecifiers?.throwsSpecifier != nil
    }

    var parametersString: String {
        signature.parameterClause.trimmedDescription
    }

    var returnTypeString: String {
        signature.returnClause?.type.trimmedDescription ?? "Void"
    }

    var genericsClauseString: String {
        genericParameterClause?.trimmedDescription ?? ""
    }

    var genericsWhereClauseString: String {
        genericWhereClause?.trimmedDescription ?? ""
    }

    var parametersInvokeForwardString: String {
        var tmp = ""
        let nParameters = signature.parameterClause.parameters.count
        for (index, parameter) in signature.parameterClause.parameters.enumerated() {

            let parameterLhs = parameter.firstName.text
            let parameterRhs = parameter.secondName?.text ?? parameter.firstName.text

            if parameterLhs == "_" {
                tmp += "\(parameterRhs)\(index == nParameters - 1 ? "" : ", ")"
            } else {
                tmp += "\(parameterLhs): \(parameterRhs)\(index == nParameters - 1 ? "" : ", ")"
            }
        }
        return tmp
    }

}
