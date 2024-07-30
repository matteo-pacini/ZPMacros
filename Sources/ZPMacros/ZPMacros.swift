
/// Macro that generates a protocol extension, implementing Combine-wrapped
/// methods for the protocol it is attached to.
///
/// `async` and `throws` methods are supported.
///
/// Generated Combine-wrapped methods are wrapped in `Deferred` and `Future`.
///
/// - Warning: Errors, if not mathing the `error` type, will not be handled
/// and a fatal error will be thrown.
///
@attached(extension, names: arbitrary)
public macro WrapWithCombine<Failure: Error>(error: Failure.Type) = #externalMacro(
    module: "ZPMacrosMacros",
    type: "WrapWithCombineExtensionMacro"
)

/// Macro that generates a protocol extension, implementing Combine-wrapped
/// methods for the protocol it is attached to.
///
/// `async` and `throws` methods are supported.
///
/// Generated Combine-wrapped methods are wrapped in `Deferred` and `Future`.
///
/// - SeeAlso: Use the `WrapWithCombine(error:)` alternative, to specify the expected error type for the methods.
/// 
@attached(extension, names: arbitrary)
public macro WrapWithCombine() = #externalMacro(
    module: "ZPMacrosMacros",
    type: "WrapWithCombineExtensionMacro"
)
