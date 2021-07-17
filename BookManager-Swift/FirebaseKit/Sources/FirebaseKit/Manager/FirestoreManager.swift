import Combine
import FirebaseFirestore

public class FirestoreManager {

    public typealias documentChange = DocumentChange

    private let database = Firestore.firestore()
    private var listner: ListenerRegistration?
    private var cancellables: Set<AnyCancellable> = []

    public static let shared = FirestoreManager()

    private init() {}

    public func removeListner() {
        listner?.remove()
    }

    // MARK: - Access for User
    public func createUser(
        documentPath: String,
        user: AccountEntity
    ) {
        guard
            let user = AccountEntity(
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
            .collection(AccountEntity.collectionName)
            .document(documentPath)
            .setData(user) { error in
                if let error = error {
                    print("user情報の登録に失敗しました: \(error)")
                }
            }
    }

    public func findUser(
        documentPath: String,
        completion: @escaping (AccountEntity) -> Void
    ) {
        database
            .collection(AccountEntity.collectionName)
            .document(documentPath)
            .getDocument { querySnapshot, error in
                if let error = error {
                    print("user情報の取得に失敗しました: \(error)")
                    return
                }

                guard
                    let querySanpshot = querySnapshot,
                    let data = querySanpshot.data(),
                    let user = AccountEntity.initialize(json: data)
                else {
                    return
                }
                completion(user)
            }
    }

    public func fetchUsers() -> AnyPublisher<[AccountEntity], Error>  {
        Deferred {
            Future<[AccountEntity], Error> { promise in
                self.database
                    .collection(AccountEntity.collectionName)
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
                            .compactMap { AccountEntity.initialize(json: $0.data()) }
                            .filter { $0.email != FirebaseAuthManager.shared.currentUser?.email }

                        promise(.success(users))
                    }
            }
        }.eraseToAnyPublisher()
    }

    // MARK: - Access for Room
    public func createRoom(partnerUser: AccountEntity) {
        findUser(documentPath: FirebaseAuthManager.shared.currentUserId) { [weak self] user in
            guard
                let self = self,
                let data = RoomEntity(
                    id: "\(user.id)\(partnerUser.id)",
                    users: [user, partnerUser],
                    lastMessage: nil,
                    lastMessageSendAt: nil,
                    createdAt: Date()
                ).toDictionary()
            else {
                return
            }

            self.database
                .collection(RoomEntity.collectionName)
                .document("\(user.id)\(partnerUser.id)")
                .setData(data, merge: true) { error in
                    if let error = error {
                        print("room情報の作成に失敗しました: \(error)")
                        return
                    }
                }
        }
    }

    public func fetchRooms(
        completion: @escaping ((DocumentChange, RoomEntity) -> Void)
    ) {
        listner = database
            .collection(RoomEntity.collectionName)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("room情報の取得に失敗しました: \(error)")
                    return
                }

                guard let querySnapshot = querySnapshot else { return }

                querySnapshot.documentChanges.forEach { snapshot in
                    guard
                        let room = RoomEntity.initialize(json: snapshot.document.data())
                    else {
                        return
                    }
                    completion(snapshot, room)
                }
            }
    }

    // MARK: - Access for ChatMessage
    public func createChatMessage(
        roomId: String,
        user: AccountEntity,
        message: String
    ) {
        guard
            let chatMessage = MessageEntity(
                id: user.id,
                name: user.name,
                iconUrl: user.imageUrl,
                message: message,
                sendAt: Date()
            ).toDictionary()
        else {
            return
        }

        database
            .collection(RoomEntity.collectionName)
            .document(roomId)
            .collection(MessageEntity.collecitonName)
            .document()
            .setData(chatMessage) { error in
                if let error = error {
                    print("chatMessage情報の登録に失敗しました: \(error)")
                }
            }

        database
            .collection(RoomEntity.collectionName)
            .document(roomId)
            .updateData(
                [
                    "lastMessage": message,
                    "lastMessageSendAt": chatMessage["sendAt"] ?? Date()
                ]
            ) { error in
                if let error = error {
                    print("room情報の更新に失敗しました: \(error)")
                }
            }
    }

    public func fetchChatMessages(
        roomId: String,
        completion: @escaping ((DocumentChange, MessageEntity) -> Void)
    ) {
        listner = database
            .collection(RoomEntity.collectionName)
            .document(roomId)
            .collection(MessageEntity.collecitonName)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("chatMessage情報の取得に失敗しました: \(error)")
                    return
                }

                guard let querySnapshot = querySnapshot else { return }

                querySnapshot.documentChanges.forEach { snapshot in
                    guard
                        let chatMessage = MessageEntity.initialize(json: snapshot.document.data())
                    else {
                        return
                    }
                    completion(snapshot, chatMessage)
                }
            }
    }
}
