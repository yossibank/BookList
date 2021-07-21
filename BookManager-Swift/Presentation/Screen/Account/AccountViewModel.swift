import Combine
import DomainKit
import FirebaseKit
import Utility

final class AccountViewModel: ViewModel {
    typealias State = LoadingState<NoEntity, APPError>

    @Published private(set) var state: State = .standby

    private let usecase: LogoutUsecase

    private var cancellables: Set<AnyCancellable> = []

    init(usecase: LogoutUsecase = Domain.Usecase.Account.Logout()) {
        self.usecase = usecase
    }
}

// MARK: - internal methods

extension AccountViewModel {

    func logout() {
        state = .loading

        usecase
            .logout()
            .sink { [weak self] completion in
                switch completion {
                    case let .failure(error):
                        self?.state = .failed(.init(error: error))

                    case .finished:
                        self?.logoutForFirebase()
                        self?.state = .finished
                }
            } receiveValue: { [weak self] state in
                self?.state = .done(state)
            }
            .store(in: &cancellables)
    }
}

// MARK: - private methods

private extension AccountViewModel {

    func logoutForFirebase() {
        FirebaseAuthManager.logout()
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
}
