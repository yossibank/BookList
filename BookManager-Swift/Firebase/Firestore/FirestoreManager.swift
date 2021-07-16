import FirebaseFirestore
import RxSwift
import Combine

final class FirestoreManager {

    typealias timeStamp = Timestamp
    typealias documentChange = DocumentChange

    private let database = Firestore.firestore()
    private var listner: ListenerRegistration?
    private var cancellables: Set<AnyCancellable> = []

    static let shared = FirestoreManager()

    private init() {}

    func removeListner() {
        listner?.remove()
    }

    // MARK: - Access for User
    func createUser(
        documentPath: String,
        user: User
    ) {
        guard
            let user = User(
                id: user.id,
                name: user.name,
                email: user.email,
                imageUrl: user.imageUrl,
                createdAt: Date()
            ).toDictionary()
        else {
            return
        }

        database
            .collection(User.collectionName)
            .document(documentPath)
            .setData(user) { error in
                if let error = error {
                    print("user情報の登録に失敗しました: \(error)")
                }
            }
    }

    func findUser(
        documentPath: String,
        completion: @escaping (User) -> Void
    ) {
        database
            .collection(User.collectionName)
            .document(documentPath)
            .getDocument { querySnapshot, error in
                if let error = error {
                    print("user情報の取得に失敗しました: \(error)")
                    return
                }

                guard
                    let querySanpshot = querySnapshot,
                    let data = querySanpshot.data(),
                    let user = User.initialize(json: data)
                else {
                    return
                }
                completion(user)
            }
    }

    func fetchUsers() -> AnyPublisher<[User], Error>  {
        Deferred {
            Future<[User], Error> { promise in
                self.database
                    .collection(User.collectionName)
                    .getDocuments { querySnapshot, error in
                        if let error = error {
                            promise(.failure(error))
                            return
                        }

                        guard
                            let querySnapshot = querySnapshot
                        else {
                            return
                        }

                        let users = querySnapshot.documents
                            .compactMap { User.initialize(json: $0.data()) }
                            .filter { $0.email != FirebaseAuthManager.shared.currentUser?.email }

                        promise(.success(users))
                    }
            }
        }.eraseToAnyPublisher()
    }

    // MARK: - Access for Room
    func createRoom(partnerUser: User) {
        findUser(documentPath: FirebaseAuthManager.shared.currentUserId) { [weak self] user in
            guard
                let self = self,
                let data = Room(
                    id: "\(user.id)\(partnerUser.id)",
                    users: [user, partnerUser],
                    lastMessage: nil,
                    lastMessageSendAt: nil,
                    createdAt: timeStamp()
                ).toDictionary()
            else {
                return
            }

            self.database
                .collection(Room.collectionName)
                .document("\(user.id)\(partnerUser.id)")
                .setData(data, merge: true) { error in
                    if let error = error {
                        print("room情報の作成に失敗しました: \(error)")
                        return
                    }
                }
        }
    }

    func fetchRooms(
        completion: @escaping ((DocumentChange, Room) -> Void)
    ) {
        listner = database
            .collection(Room.collectionName)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("room情報の取得に失敗しました: \(error)")
                    return
                }

                guard let querySnapshot = querySnapshot else { return }

                querySnapshot.documentChanges.forEach { snapshot in
                    guard
                        let room = Room.initialize(json: snapshot.document.data())
                    else {
                        return
                    }
                    completion(snapshot, room)
                }
            }
    }

    // MARK: - Access for ChatMessage
    func createChatMessage(
        roomId: String,
        user: User,
        message: String
    ) {
        guard
            let chatMessage = ChatMessage(
                id: Int(user.id) ?? 0,
                name: user.name,
                iconUrl: user.imageUrl,
                message: message,
                sendAt: timeStamp()
            ).toDictionary()
        else {
            return
        }

        database
            .collection(Room.collectionName)
            .document(roomId)
            .collection(ChatMessage.collecitonName)
            .document()
            .setData(chatMessage) { error in
                if let error = error {
                    print("chatMessage情報の登録に失敗しました: \(error)")
                }
            }

        database
            .collection(Room.collectionName)
            .document(roomId)
            .updateData(
                [
                    "lastMessage": message,
                    "lastMessageSendAt": chatMessage["sendAt"] ?? timeStamp()
                ]
            ) { error in
                if let error = error {
                    print("room情報の更新に失敗しました: \(error)")
                }
            }
    }

    func fetchChatMessages(
        roomId: String,
        completion: @escaping ((DocumentChange, ChatMessage) -> Void)
    ) {
        listner = database
            .collection(Room.collectionName)
            .document(roomId)
            .collection(ChatMessage.collecitonName)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("chatMessage情報の取得に失敗しました: \(error)")
                    return
                }

                guard let querySnapshot = querySnapshot else { return }

                querySnapshot.documentChanges.forEach { snapshot in
                    guard
                        let chatMessage = ChatMessage.initialize(json: snapshot.document.data())
                    else {
                        return
                    }
                    completion(snapshot, chatMessage)
                }
            }
    }
}
