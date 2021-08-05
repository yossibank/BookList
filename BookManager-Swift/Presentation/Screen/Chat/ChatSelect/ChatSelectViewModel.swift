import Combine
import DomainKit
import FirebaseKit

final class ChatSelectViewModel: ViewModel {

    typealias State = LoadingState<[RoomEntity], APPError>

    @Published private(set) var state: State = .standby

    private(set) var roomList: [RoomEntity] = []
    private(set) var user: AccountEntity?

    private var cancellables: Set<AnyCancellable> = []

    func fetchRooms() {
        state = .loading

        FirestoreManager.fetchRooms()
            .sink { [weak self] completion in
                switch completion {
                    case let .failure(error):
                        self?.state = .failed(error)

                    case .finished:
                        self?.state = .finished
                }
            } receiveValue: { [weak self] roomList in
                self?.state = .done(roomList)
                self?.roomList = roomList
            }
            .store(in: &cancellables)
    }

    func findCurrentUser() {
        state = .loading

        FirestoreManager.findCurrentUser()
            .sink { [weak self] completion in
                switch completion {
                    case let .failure(error):
                        self?.state = .failed(error)

                    case .finished:
                        self?.state = .finished
                }
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &cancellables)
    }
}
