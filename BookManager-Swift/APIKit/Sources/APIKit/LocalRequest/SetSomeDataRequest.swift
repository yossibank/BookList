import Foundation

public struct SetSomeDataRequest: LocalRequest {
    public typealias Response = EmptyResponse
    public typealias Parameters = BookResponse
    public typealias PathComponent = EmptyPathComponent

    public var localDataInterceptor: (Parameters) -> Response? {
        { book in
            PersistedDataHolder.someData?.append(book)
            return EmptyResponse()
        }
    }

    public init(parameters _: Parameters, pathComponent _: EmptyPathComponent) {}
}
