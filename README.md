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

This macro generates a protocol extension where all methods are wrapped in Combine publishers (`Deferred` and `Future`).

#### Features

- Preserves access levels (public, internal)
- Supports async/sync methods
- Supports throwing/non-throwing methods
- Supports Swift 6 typed throws with single and compound error types
- Handles complex return types (tuples, optionals, collections)
- Preserves generic constraints and where clauses
- Handles complex parameter labels and unnamed parameters
- Supports multiple methods in a single protocol

To use it, annotate a protocol with `@WrapWithCombine`:

```swift
@WrapWithCombine
public protocol NetworkService {
    // Simple async throwing method
    func fetch(_ url: URL) async throws -> Data
    
    // Method with complex return type and typed throws
    func fetchItems() throws(NetworkError) -> (items: [Item], metadata: Metadata?)
    
    // Generic method with constraints
    func process<T: Codable>(data: Data) throws -> T where T: Sendable
    
    // Method with complex parameter labels
    func configure(with config: Config, _ timeout: TimeInterval, using mode: Mode)
}

// ...will expand to...

public protocol NetworkService {
    func fetch(_ url: URL) async throws -> Data
    func fetchItems() throws(NetworkError) -> (items: [Item], metadata: Metadata?)
    func process<T: Codable>(data: Data) throws -> T where T: Sendable
    func configure(with config: Config, _ timeout: TimeInterval, using mode: Mode)
}

extension NetworkService {
    public func fetch(_ url: URL) -> AnyPublisher<Data, any Error> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        let result: Data = try await fetch(url)
                        promise(.success(result))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func fetchItems() -> AnyPublisher<(items: [Item], metadata: Metadata?), NetworkError> {
        Deferred {
            Future { promise in
                do throws(NetworkError) {
                    let result = try fetchItems()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func process<T: Codable>(data: Data) -> AnyPublisher<T, any Error> where T: Sendable {
        Deferred {
            Future { promise in
                do {
                    let result: T = try process(data: data)
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func configure(with config: Config, _ timeout: TimeInterval, using mode: Mode) -> AnyPublisher<Void, Never> {
        Deferred {
            Future { promise in
                let result: Void = configure(with: config, timeout, using: mode)
                promise(.success(result))
            }
        }
        .eraseToAnyPublisher()
    }
}
```

## Known issues

- Swift macros require Xcode 16.0+ andSwift 6.0+ to correctly work.
- SwiftSyntax has to be compiled when adopting this package, which may increase initial compilation times

## Contributing

Contributions are more than welcome!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
