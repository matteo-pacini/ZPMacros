import ZPMacros
import Combine
import Foundation

struct SomeError: Error { }

@WrapWithCombine
protocol SomeService {
    func a(_ aa: Int) async throws(SomeError)
    func b<T>(_ input: T)
    func c<A>() throws -> A where A: Decodable
    func d() async
}
