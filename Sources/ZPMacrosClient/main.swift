import ZPMacros
import Combine
import Foundation

struct SomeError: Error { }


protocol SomeService {
    func a(_ aa: Int) async throws
    func b<T>(_ input: T)
    func c<A>() throws -> A where A: Decodable
    func d() async
}
