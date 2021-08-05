import Combine
import DomainKit
import FirebaseKit
import Utility

final class ChatUserListViewModel: ViewModel {

    typealias State = LoadingState<[AccountEntity], APPError>

    private(set) var userList: [AccountEntity] = []

    @Published private(set) var state: State = .standby

    private var cancellables: Set<AnyCancellable> = []
}

// MARK: - internal methods

extension ChatUserListViewModel {

    func fetchUsers() {
        state = .loading

        FirestoreManager.fetchUsers()
            .sink { [weak self] completion in
                switch completion {
                    case let .failure(error):
                        self?.state = .failed(error)

                    case .finished:
                        self?.state = .finished
                }
            } receiveValue: { [weak self] state in
                guard let self = self else { return }
                self.userList.append(contentsOf: state)
                self.state = .done(state)
            }
            .store(in: &cancellables)
    }

    func createRoom(partnerUser: AccountEntity) {
        state = .loading

        FirestoreManager.createRoom(partnerUser: partnerUser)
            .sink { [weak self] completion in
                switch completion {
                    case let .failure(error):
                        self?.state = .failed(error)

                    case .finished:
                        self?.state = .finished
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
