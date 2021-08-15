import APIKit
import Combine

public protocol SignupUsecase {
    func signup(
        email: String,
        password: String
    ) -> AnyPublisher<UserEntity, APIError>
}

extension UsecaseImpl: SignupUsecase where R == Repos.API.Account.Signup, M == UserMapper {

    public func signup(
        email: String,
        password: String
    ) -> AnyPublisher<UserEntity, APIError> {
        toPublisher { promise in
            analytics.sendEvent()

            repository.request(
                useTestData: useTestData,
                parameters: .init(email: email, password: password),
                pathComponent: .init()
            ) { result in
                switch result {
                    case let .success(response):
                        let entity = mapper.convert(response: response)
                        promise(.success(entity))

                    case let .failure(error):
                        promise(.failure(error))
                }
            }
        }
    }
}
