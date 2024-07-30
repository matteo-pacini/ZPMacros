import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ZPMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        WrapWithCombineExtensionMacro.self
    ]
}
