import FirebaseKit

final class ChatRoomViewModel: ViewModel {
    private let roomId: String
    private let user: AccountEntity

    var currentUserId: String {
        user.id
    }

    init(roomId: String, user: AccountEntity) {
        self.roomId = roomId
        self.user = user
    }

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
        )
    }
}
