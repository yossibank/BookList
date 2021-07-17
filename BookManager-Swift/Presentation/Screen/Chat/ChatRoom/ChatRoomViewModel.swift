import FirebaseKit

final class ChatRoomViewModel: ViewModel {
    private let roomId: String
    private let user: AccountEntity
    private let firestore = FirestoreManager.shared

    var currentUserId: String {
        user.id
    }

    init(roomId: String, user: AccountEntity) {
        self.roomId = roomId
        self.user = user
    }

    func removeListener() {
        firestore.removeListner()
    }

    func fetchChatMessages(
        completion: @escaping ((FirestoreManager.documentChange, MessageEntity) -> Void)
    ) {
        firestore.fetchChatMessages(
            roomId: roomId,
            completion: completion
        )
    }

    func sendChatMessage(message: String) {
        firestore.createChatMessage(
            roomId: roomId,
            user: user,
            message: message
        )
    }
}
