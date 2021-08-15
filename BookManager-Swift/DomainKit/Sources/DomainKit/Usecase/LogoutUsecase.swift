import APIKit
import Combine

public protocol LogoutUsecase {
    func logout() -> AnyPublisher<NoEntity, APIError>
}

extension UsecaseImpl: LogoutUsecase where R == Repos.API.Account.Logout, M == NoMapper {

    public func logout() -> AnyPublisher<NoEntity, APIError> {
        toPublisher { promise in
            analytics.sendEvent()

            repository.request(
                useTestData: useTestData,
                parameters: .init(),
                pathComponent: .init()
            ) { result in
                switch result {
                    case .success:
                        promise(.success(.init()))

                    case let .failure(error):
                        promise(.failure(error))
                }
            }
        }
    }
}
