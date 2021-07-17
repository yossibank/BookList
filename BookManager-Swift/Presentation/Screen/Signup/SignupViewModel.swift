import Combine
import DomainKit
import Foundation
import Utility

// temporary
import FirebaseKit

final class SignupViewModel: ViewModel {
    typealias State = LoadingState<UserEntity, APPError>

    @Published var userName = String.blank
    @Published var email = String.blank
    @Published var password = String.blank
    @Published var passwordConfirmation = String.blank
    @Published private(set) var state: State = .standby

    var userNameValidationText: String? {
        NickNameValidator.validate(userName).errorDescription
    }

    var emailValidationText: String? {
        EmailValidator.validate(email).errorDescription
    }

    var passwordValidationText: String? {
        PasswordValidator.validate(password).errorDescription
    }

    var passwordConfirmationValidationText: String? {
        PasswordConfirmationValidator.validate(password, passwordConfirmation).errorDescription
    }

    private(set) lazy var isEnabledButton = Publishers
        .CombineLatest4($userName, $email, $password, $passwordConfirmation)
        .receive(on: DispatchQueue.main)
        .map { _ in self.isValidate() }
        .eraseToAnyPublisher()

    private let usecase: SignupUsecase

    private var id = UUIDIdentifiable().id
    private var cancellables: Set<AnyCancellable> = []

    init(usecase: SignupUsecase = Domain.Usecase.Account.Signup()) {
        self.usecase = usecase
    }
}

// MARK: - internal methods

extension SignupViewModel {

    func signup() {
        state = .loading

        usecase
            .signup(email: email, password: password)
            .sink { [weak self] completion in
                switch completion {
                    case let .failure(error):
                        self?.state = .failed(.init(error: error))

                    case .finished:
                        self?.createUserForFirebase()
                }
            } receiveValue: { [weak self] state in
                self?.state = .done(state)
            }
            .store(in: &cancellables)
    }

    func saveUserIconImage(uploadImage: Data) {
        FirebaseStorageManager.saveUserIconImage(
            path: id,
            uploadImage: uploadImage
        )
    }
}

// MARK: - private methods

extension SignupViewModel {

    func createUserForFirebase() {
        FirebaseStorageManager.fetchDownloadUrlString(path: id) { [weak self] imageUrl in
            guard let self = self else { return }

            let user = AccountEntity(
                id: self.id,
                name: self.userName,
                email: self.email,
                imageUrl: imageUrl,
                createdAt: Date()
            )

            FirebaseAuthManager.createUser(
                email: self.email,
                password: self.password,
                user: user
            )
        }
    }

    func isValidate() -> Bool {
        let results = [
            NickNameValidator.validate(userName).isValid,
            EmailValidator.validate(email).isValid,
            PasswordValidator.validate(password).isValid,
            PasswordConfirmationValidator.validate(password, passwordConfirmation).isValid
        ]
        return results.allSatisfy { $0 }
    }
}
