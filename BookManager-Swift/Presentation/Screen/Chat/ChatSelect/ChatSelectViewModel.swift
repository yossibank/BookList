// temporary
import FirebaseKit

final class ChatSelectViewModel: ViewModel {

    private let firestore = FirestoreManager.shared

    func removeListener() {
        firestore.removeListner()
    }

    func fetchRooms(
        completion: @escaping ((FirestoreManager.documentChange, RoomEntity) -> Void)
    ) {
        firestore.fetchRooms(completion: completion)
    }

    func findUser(completion: @escaping (AccountEntity) -> Void) {
        firestore.findUser(
            documentPath: FirebaseAuthManager.shared.currentUserId,
            completion: completion
        )
    }
}
