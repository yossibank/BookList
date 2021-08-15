import Foundation

public struct GetAccessTokenRequest: LocalRequest {
    public typealias Response = String
    public typealias Parameters = EmptyParameters
    public typealias PathComponent = EmptyPathComponent

    public var localDataInterceptor: (EmptyParameters) -> String? {
        { _ in
            SecretDataHolder.accessToken
        }
    }

    public init(parameters _: EmptyParameters, pathComponent _: EmptyPathComponent) {}
}
