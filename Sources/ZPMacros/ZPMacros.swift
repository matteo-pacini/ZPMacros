/// Macro that generates a protocol extension, implementing Combine-wrapped
/// methods for the protocol it is attached to.
///
/// Generated Combine-wrapped methods are wrapped in `Deferred` and `Future`.
/// 
@attached(extension, names: arbitrary)
public macro WrapWithCombine() = #externalMacro(
    module: "ZPMacrosMacros",
    type: "WrapWithCombineExtensionMacro"
)
