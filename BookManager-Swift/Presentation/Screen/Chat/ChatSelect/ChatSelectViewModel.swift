// temporary
import FirebaseKit

final class ChatSelectViewModel: ViewModel {

    func removeListener() {
        FirestoreManager.removeListner()
    }

    func fetchRooms(
        completion: @escaping ((FirestoreManager.documentChange, RoomEntity) -> Void)
    ) {
        FirestoreManager.fetchRooms(completion: completion)
    }

    func findUser(completion: @escaping (AccountEntity) -> Void) {
        FirestoreManager.findUser(
            documentPath: FirebaseAuthManager.currentUser?.uid ?? String.blank,
            completion: completion
        )
    }
}
