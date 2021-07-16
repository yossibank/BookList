import Combine
import DomainKit
import Utility

final class ChatUserListViewModel: ViewModel {
    typealias State = LoadingState<[User], APPError>

    private(set) var userList: [User] = []
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var state: State = .standby

    func createRoom(partnerUser: User) {
        FirestoreManager.shared.createRoom(partnerUser: partnerUser)
    }

    func fetchUsers() {
        state = .loading

        FirestoreManager.shared.fetchUsers()
            .sink { completion in
                switch completion {
                    case .failure:
                        print("error")

                    case .finished:
                        print("finished")
                }
            } receiveValue: { [weak self] state in
                guard let self = self else { return }
                self.userList.append(contentsOf: state)
                self.state = .done(state)
            }
            .store(in: &cancellables)
    }
}
