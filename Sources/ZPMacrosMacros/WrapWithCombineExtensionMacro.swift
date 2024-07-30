import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct WrapWithCombineExtensionMacro: ExtensionMacro {

    private static let messageID = MessageID(
        domain: "ZPMacros",
        id: "WrapWithCombineExtensionMacro"
    )

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {

        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            throw SimpleDiagnosticMessage(
                message: "Macro `WrapWithCombine` can only be applied to a protocol definition",
                diagnosticID: messageID,
                severity: .error
            )
        }

        let errorOverride = node.arguments?
            .as(LabeledExprListSyntax.self)?
            .first?
            .as(LabeledExprSyntax.self)?
            .expression
            .as(MemberAccessExprSyntax.self)?
            .base?
            .trimmedDescription

        let methods = try protocolDecl
            .methods
            .map { function -> FunctionDeclSyntax in

                let generatedFunction: FunctionDeclSyntax

                if function.isAsync && function.throws {
                    generatedFunction = try FunctionDeclSyntax(
                        """
                        \(raw: Self.funcFullSignature(for: function, errorOverride: errorOverride)) {
                            Deferred {
                                Future { promise in
                                    Task {
                                        do {
                                            let result: \(raw: function.returnTypeString) = try await \(raw: function.name)(\(raw: function.parametersInvokeForwardString))
                                            promise(.success(result))
                                        } catch\(raw: extraCatchCodegen(for: errorOverride)) {
                                            promise(.failure(error))
                                        } \(raw: extraGenericCatchCodegen(for: errorOverride))
                                    }
                                }
                            }
                            .eraseToAnyPublisher()
                        }
                        """
                    )
                } else if function.isAsync {
                    generatedFunction =  try FunctionDeclSyntax(
                        """
                        \(raw: Self.funcFullSignature(for: function, errorOverride: errorOverride)) {
                            Deferred {
                                Future { promise in
                                    Task {
                                        let result: \(raw: function.returnTypeString) = await \(raw: function.name)(\(raw: function.parametersInvokeForwardString))
                                        promise(.success(result))
                                    }
                                }
                            }
                            .eraseToAnyPublisher()
                        }
                        """
                    )
                } else if function.throws {
                    generatedFunction =  try FunctionDeclSyntax(
                        """
                        \(raw: Self.funcFullSignature(for: function, errorOverride: errorOverride)) {
                            Deferred {
                                Future { promise in
                                    do {
                                        let result: \(raw: function.returnTypeString) = try \(raw: function.name)(\(raw: function.parametersInvokeForwardString))
                                        promise(.success(result))
                                    } catch\(raw: extraCatchCodegen(for: errorOverride)) {
                                        promise(.failure(error))
                                    } \(raw: extraGenericCatchCodegen(for: errorOverride))
                                }
                            }
                            .eraseToAnyPublisher()
                        }
                        """
                    )
                } else {
                    generatedFunction = try FunctionDeclSyntax("""
                        \(raw: Self.funcFullSignature(for: function, errorOverride: errorOverride)) {
                            Deferred {
                                Future { promise in
                                    let result: \(raw: function.returnTypeString) = \(raw: function.name)(\(raw: function.parametersInvokeForwardString))
                                    promise(.success(result))
                                }
                            }
                            .eraseToAnyPublisher()
                        }
                        """
                    )
                }

                return generatedFunction

            }

        guard !methods.isEmpty else { return [] }

        let extensionDecl = ExtensionDeclSyntax(extendedType: type) {
            for method in methods {
                MemberBlockItemSyntax(decl: method)
            }
        }

        return [extensionDecl]

    }

    private static func funcFullSignature(
        for function: FunctionDeclSyntax,
        errorOverride: String?
    ) -> String {
        "func \(function.name)\(function.genericsClauseString)\(function.parametersString)" +
        "-> \(returnPublisherString(for: function, errorOverride: errorOverride))\(function.genericsWhereClauseString)"
    }

    private static func returnPublisherString(for function: FunctionDeclSyntax, errorOverride: String?) -> String {
        "AnyPublisher<\(function.returnTypeString), \(errorString(for: function, errorOverride: errorOverride))>"
    }

    private static func errorString(for function: FunctionDeclSyntax, errorOverride: String?) -> String {
        if let errorOverride {
            return function.throws ? errorOverride : "Never"
        } else {
            return function.throws ? "any Error" : "Never"
        }
    }

    private static func extraCatchCodegen(for errorOverride: String?) -> String {
        if let errorOverride {
            return " let error as \(errorOverride)"
        } else {
            return ""
        }
    }

    private static func extraGenericCatchCodegen(for errorOverride: String?) -> String {
        if errorOverride != nil {
            "catch { fatalError(\"Unknown error propagated: \\(String(describing: type(of: error)))\") }"
        } else {
            ""
        }
    }

}
