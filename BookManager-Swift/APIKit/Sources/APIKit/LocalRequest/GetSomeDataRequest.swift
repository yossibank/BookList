import Foundation

public struct GetSomeDataRequest: LocalRequest {
    public typealias Response = [BookResponse]
    public typealias Parameters = EmptyParameters
    public typealias PathComponent = EmptyPathComponent

    public var localDataInterceptor: (EmptyParameters) -> [BookResponse]? {
        { _ in
            PersistedDataHolder.someData
        }
    }

    public init(parameters _: EmptyParameters, pathComponent _: EmptyPathComponent) {}
}
