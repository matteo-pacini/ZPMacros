import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, 
// so the corresponding module is not available when cross-compiling.
// Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ZPMacrosMacros)
import ZPMacrosMacros

let testMacros: [String: Macro.Type] = [
    "WrapWithCombine": WrapWithCombineExtensionMacro.self,
]
#endif

final class WrapWithCombineExtensionMacroTests: XCTestCase {

    func testNoMethods() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {

            }
            """,
            expandedSource:
            """
            protocol A {

            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testSimpleFunction() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func test() -> Int
            }
            """,
            expandedSource: 
            """
            protocol A {
                func test() -> Int
            }

            extension A {
                func test() -> AnyPublisher<Int, Never> {
                    Deferred {
                        Future { promise in
                            let result: Int = test()
                            promise(.success(result))
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testSimpleFunctionNastyLabels() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func test(with x: Double, and then: Int, yup: Bool)
            }
            """,
            expandedSource:
            """
            protocol A {
                func test(with x: Double, and then: Int, yup: Bool)
            }

            extension A {
                func test(with x: Double, and then: Int, yup: Bool) -> AnyPublisher<Void, Never> {
                    Deferred {
                        Future { promise in
                            let result: Void = test(with: x, and: then, yup: yup)
                            promise(.success(result))
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testSimpleFunctionNastyLabelsTwo() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func test(with x: Double, _ then: Int, yup: Bool)
            }
            """,
            expandedSource:
            """
            protocol A {
                func test(with x: Double, _ then: Int, yup: Bool)
            }

            extension A {
                func test(with x: Double, _ then: Int, yup: Bool) -> AnyPublisher<Void, Never> {
                    Deferred {
                        Future { promise in
                            let result: Void = test(with: x, then, yup: yup)
                            promise(.success(result))
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testThrowingFunction() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func test() throws -> (a: Int, b: Double)
            }
            """,
            expandedSource:
            """
            protocol A {
                func test() throws -> (a: Int, b: Double)
            }

            extension A {
                func test() -> AnyPublisher<(a: Int, b: Double), any Error> {
                    Deferred {
                        Future { promise in
                            do {
                                let result: (a: Int, b: Double) = try test()
                                promise(.success(result))
                            } catch {
                                promise(.failure(error))
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testTypedThrowingFunction() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func test() throws(SomeError) -> (a: Int, b: Double)
            }
            """,
            expandedSource:
            """
            protocol A {
                func test() throws(SomeError) -> (a: Int, b: Double)
            }

            extension A {
                func test() -> AnyPublisher<(a: Int, b: Double), SomeError> {
                    Deferred {
                        Future { promise in
                            do throws(SomeError) {
                                let result: (a: Int, b: Double) = try test()
                                promise(.success(result))
                            } catch {
                                promise(.failure(error))
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAsyncFunction() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func test(_ a: String) async -> String
            }
            """,
            expandedSource:
            """
            protocol A {
                func test(_ a: String) async -> String
            }

            extension A {
                func test(_ a: String) -> AnyPublisher<String, Never> {
                    Deferred {
                        Future { promise in
                            Task {
                                let result: String = await test(a)
                                promise(.success(result))
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAsyncThrowingFunction() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func test() async throws -> String
            }
            """,
            expandedSource:
            """
            protocol A {
                func test() async throws -> String
            }

            extension A {
                func test() -> AnyPublisher<String, any Error> {
                    Deferred {
                        Future { promise in
                            Task {
                                do {
                                    let result: String = try await test()
                                    promise(.success(result))
                                } catch {
                                    promise(.failure(error))
                                }
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAsyncThrowingTypedErrorFunction() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func test() async throws(AnotherError) -> String
            }
            """,
            expandedSource:
            """
            protocol A {
                func test() async throws(AnotherError) -> String
            }

            extension A {
                func test() -> AnyPublisher<String, AnotherError> {
                    Deferred {
                        Future { promise in
                            Task {
                                do throws(AnotherError) {
                                    let result: String = try await test()
                                    promise(.success(result))
                                } catch {
                                    promise(.failure(error))
                                }
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAsyncThrowingWithGenericsFunction() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func test<SomeType>(input: SomeType) async throws -> String where SomeType: StringProtocol
            }
            """,
            expandedSource:
            """
            protocol A {
                func test<SomeType>(input: SomeType) async throws -> String where SomeType: StringProtocol
            }

            extension A {
                func test<SomeType>(input: SomeType) -> AnyPublisher<String, any Error> where SomeType: StringProtocol {
                    Deferred {
                        Future { promise in
                            Task {
                                do {
                                    let result: String = try await test(input: input)
                                    promise(.success(result))
                                } catch {
                                    promise(.failure(error))
                                }
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAsyncWithGenericsFunction() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func test<SomeType, B, C>(input: SomeType, b: B, c: C) throws -> String where SomeType: StringProtocol
            }
            """,
            expandedSource:
            """
            protocol A {
                func test<SomeType, B, C>(input: SomeType, b: B, c: C) throws -> String where SomeType: StringProtocol
            }

            extension A {
                func test<SomeType, B, C>(input: SomeType, b: B, c: C) -> AnyPublisher<String, any Error> where SomeType: StringProtocol {
                    Deferred {
                        Future { promise in
                            do {
                                let result: String = try test(input: input, b: b, c: c)
                                promise(.success(result))
                            } catch {
                                promise(.failure(error))
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMultipleMethods() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func first() -> Int
                func second() throws -> String
                func third() async -> Double
                func fourth() async throws -> Bool
            }
            """,
            expandedSource:
            """
            protocol A {
                func first() -> Int
                func second() throws -> String
                func third() async -> Double
                func fourth() async throws -> Bool
            }

            extension A {
                func first() -> AnyPublisher<Int, Never> {
                    Deferred {
                        Future { promise in
                            let result: Int = first()
                            promise(.success(result))
                        }
                    }
                    .eraseToAnyPublisher()
                }
                func second() -> AnyPublisher<String, any Error> {
                    Deferred {
                        Future { promise in
                            do {
                                let result: String = try second()
                                promise(.success(result))
                            } catch {
                                promise(.failure(error))
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
                func third() -> AnyPublisher<Double, Never> {
                    Deferred {
                        Future { promise in
                            Task {
                                let result: Double = await third()
                                promise(.success(result))
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
                func fourth() -> AnyPublisher<Bool, any Error> {
                    Deferred {
                        Future { promise in
                            Task {
                                do {
                                    let result: Bool = try await fourth()
                                    promise(.success(result))
                                } catch {
                                    promise(.failure(error))
                                }
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testPublicProtocol() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            public protocol A {
                func test() -> Int
            }
            """,
            expandedSource:
            """
            public protocol A {
                func test() -> Int
            }

            extension A {
                public func test() -> AnyPublisher<Int, Never> {
                    Deferred {
                        Future { promise in
                            let result: Int = test()
                            promise(.success(result))
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testComplexReturnTypes() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func test1() -> (Int?, String, Double?)
                func test2() -> [String: Result<Int, Error>]
                func test3() -> Array<Dictionary<String, Optional<Int>>>
            }
            """,
            expandedSource:
            """
            protocol A {
                func test1() -> (Int?, String, Double?)
                func test2() -> [String: Result<Int, Error>]
                func test3() -> Array<Dictionary<String, Optional<Int>>>
            }

            extension A {
                func test1() -> AnyPublisher<(Int?, String, Double?), Never> {
                    Deferred {
                        Future { promise in
                            let result: (Int?, String, Double?) = test1()
                            promise(.success(result))
                        }
                    }
                    .eraseToAnyPublisher()
                }
                func test2() -> AnyPublisher<[String: Result<Int, Error>], Never> {
                    Deferred {
                        Future { promise in
                            let result: [String: Result<Int, Error>] = test2()
                            promise(.success(result))
                        }
                    }
                    .eraseToAnyPublisher()
                }
                func test3() -> AnyPublisher<Array<Dictionary<String, Optional<Int>>>, Never> {
                    Deferred {
                        Future { promise in
                            let result: Array<Dictionary<String, Optional<Int>>> = test3()
                            promise(.success(result))
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testComplexGenerics() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func test1<T: Comparable & Hashable, U: Collection where U.Element == T>(value: T, collection: U) -> [T]
                func test2<Element>() -> some Sequence where Element: Equatable
            }
            """,
            expandedSource:
            """
            protocol A {
                func test1<T: Comparable & Hashable, U: Collection where U.Element == T>(value: T, collection: U) -> [T]
                func test2<Element>() -> some Sequence where Element: Equatable
            }

            extension A {
                func test1<T: Comparable & Hashable, U: Collection where U.Element == T>(value: T, collection: U) -> AnyPublisher<[T], Never> {
                    Deferred {
                        Future { promise in
                            let result: [T] = test1(value: value, collection: collection)
                            promise(.success(result))
                        }
                    }
                    .eraseToAnyPublisher()
                }
                func test2<Element>() -> AnyPublisher<some Sequence, Never> where Element: Equatable {
                    Deferred {
                        Future { promise in
                            let result: some Sequence = test2()
                            promise(.success(result))
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMultipleErrorTypes() throws {
        #if canImport(ZPMacrosMacros)
        assertMacroExpansion(
            """
            @WrapWithCombine
            protocol A {
                func test() throws(NetworkError & LocalizedError) -> String
            }
            """,
            expandedSource:
            """
            protocol A {
                func test() throws(NetworkError & LocalizedError) -> String
            }

            extension A {
                func test() -> AnyPublisher<String, NetworkError & LocalizedError> {
                    Deferred {
                        Future { promise in
                            do throws(NetworkError & LocalizedError) {
                                let result: String = try test()
                                promise(.success(result))
                            } catch {
                                promise(.failure(error))
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
