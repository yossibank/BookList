import Combine
import DomainKit
import FirebaseKit
import Foundation
import Utility

final class LoginViewModel: ViewModel {
    typealias State = LoadingState<UserEntity, APPError>

    @Published var email = String.blank
    @Published var password = String.blank
    @Published private(set) var state: State = .standby

    var emailValidationText: String? {
        EmailValidator.validate(email).errorDescription
    }

    var passwordValidationText: String? {
        PasswordValidator.validate(password).errorDescription
    }

    private(set) lazy var isEnabledButton = Publishers
        .CombineLatest($email, $password)
        .receive(on: DispatchQueue.main)
        .map { _ in self.isValidate() }
        .eraseToAnyPublisher()

    private let usecase: LoginUsecase

    private var cancellables: Set<AnyCancellable> = []

    init(usecase: LoginUsecase = Domain.Usecase.Account.Login()) {
        self.usecase = usecase
    }
}

// MARK: - internal methods

extension LoginViewModel {

    func login() {
        state = .loading

        usecase
            .login(email: email, password: password)
            .sink { [weak self] completion in
                switch completion {
                    case let .failure(error):
                        self?.state = .failed(.init(error: error))

                    case .finished:
                        self?.state = .finished
                        self?.firebaseSignIn()
                }
            } receiveValue: { [weak self] state in
                self?.state = .done(state)
            }
            .store(in: &cancellables)
    }
}

// MARK: - private methods

private extension LoginViewModel {

    func firebaseSignIn() {
        FirebaseAuthManager.signIn(email: email, password: password)
            .sink { completion in
                switch completion {
                    case let .failure(error):
                        self.state = .failed(error)

                    case .finished:
                        self.state = .finished
                }
            } receiveValue: { _ in
                Logger.debug(message: "no receive value")
            }
            .store(in: &cancellables)
    }

    func isValidate() -> Bool {
        let results = [
            EmailValidator.validate(email).isValid,
            PasswordValidator.validate(password).isValid
        ]
        return results.allSatisfy { $0 }
    }
}
