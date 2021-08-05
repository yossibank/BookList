import Combine
import DomainKit
import FirebaseKit

final class ChatRoomViewModel: ViewModel {

    typealias State = LoadingState<[MessageEntity], APPError>

    var currentUserId: String {
        user.id
    }

    @Published private(set) var state: State = .standby

    private var cancellables: Set<AnyCancellable> = []

    private let roomId: String
    private let user: AccountEntity

    init(
        roomId: String,
        user: AccountEntity
    ) {
        self.roomId = roomId
        self.user = user
    }
}

// MARK: - internal methods

extension ChatRoomViewModel {

    func removeListener() {
        FirestoreManager.removeListner()
    }

    func fetchChatMessages(
        completion: @escaping ((FirestoreManager.documentChange, MessageEntity) -> Void)
    ) {
        FirestoreManager.fetchChatMessages(
            roomId: roomId,
            completion: completion
        )
    }

    func sendChatMessage(message: String) {
        FirestoreManager.createChatMessage(
            roomId: roomId,
            user: user,
            message: message
        ).sink { [weak self] completion in
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
