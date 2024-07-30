# ZPMacros

ZPMacros is a collection of Swift Macros to assist with Swift development. 

These macros aim to streamline and enhance the development process by automating code generation tasks.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
- [Templates](#templates)
- [Contributing](#contributing)
- [License](#license)

## Installation

To get started with ZPMacros, add it to your SwiftPM dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/matteo-pacini/ZPMacros.git", .branch("master"))
]
```

## Macros

### WrapWithCombine

This macros generates a protocol extension, where all
methods are wrapped for Combine (`Deferred` and `Future`).

This supports generics, `async` and `throws`.

To trigger it, annotate a protocol with `@WrapWithCombine`, i.e.:

```swift
@WrapWithCombine
protocol A {
    func test() async throws -> String
}

// ...will expand to...

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
```

To refine the error type, use the `@WrapWithCombine(error:)` alternative, i.e:

```swift
@WrapWithCombine(error: SomeError.self)
protocol A {
    func test() async throws -> String
}

// ...will expand to...

@WrapWithCombine(error: SomeError.self)
protocol A {
    func test() async throws -> String
}

extension A {
    func test() -> AnyPublisher<String, SomeError> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        let result: String = try await test()
                        promise(.success(result))
                    } catch let error as SomeError {
                        promise(.failure(error))
                    } catch {
                        fatalError("Unkown error propagated: \(String(describing: type(of: error)))")
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
```

## Known issues

- Swift is still buggy when it comes to macros
    - i.e. `WrapWithCombine` works in Xcode 16b4 but not on Xcode 15.
- SwiftSyntax has to be compiled when adopting this package, compilation times are going to increase because of this

## Contributing

Contributions are more than welcome!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
