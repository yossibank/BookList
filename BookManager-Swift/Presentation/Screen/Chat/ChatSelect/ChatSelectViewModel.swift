import Combine
import DomainKit
import FirebaseKit

final class ChatSelectViewModel: ViewModel {

    typealias State = LoadingState<AccountEntity, APPError>

    @Published private(set) var state: State = .standby

    private(set) var user: AccountEntity?

    private var cancellables: Set<AnyCancellable> = []

    func removeListener() {
        FirestoreManager.removeListner()
    }

    func fetchRooms(
        completion: @escaping ((FirestoreManager.documentChange, RoomEntity) -> Void)
    ) {
        FirestoreManager.fetchRooms(completion: completion)
    }

    func findUser() {
        FirestoreManager.findUser()
            .sink { [weak self] completion in
                switch completion {
                    case let .failure(error):
                        self?.state = .failed(error)

                    case .finished:
                        self?.state = .finished
                }
            } receiveValue: { [weak self] user in
                self?.state = .done(user)
                self?.user = user
            }
            .store(in: &cancellables)
    }
}
