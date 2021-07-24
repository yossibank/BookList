import Combine
import DomainKit
import FirebaseFirestore
import Utility

public struct FirestoreManager {

    public typealias documentChange = DocumentChange

    private static let database = Firestore.firestore()
    private static var listner: ListenerRegistration?

    public static func removeListner() {
        listner?.remove()
    }

    // MARK: - Access for User

    public static func createUser(
        documentPath: String,
        account: AccountEntity,
        completion: @escaping (Error) -> Void
    ) {
        guard
            let user = AccountEntity(
                id: account.id,
                name: account.name,
                email: account.email,
                imageUrl: account.imageUrl,
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
                    completion(error)
                }
            }
    }

    public static func findCurrentUser() -> AnyPublisher<AccountEntity, APPError> {
        Deferred {
            Future { promise in
                database
                    .collection(AccountEntity.collectionName)
                    .document(FirebaseAuthManager.currentUser?.uid ?? "")
                    .getDocument { querySnapshot, error in
                        if let error = error {
                            promise(.failure(.init(error: .failureData(error.localizedDescription))))
                            return
                        }

                        guard
                            let querySanpshot = querySnapshot,
                            let data = querySanpshot.data(),
                            let user = AccountEntity.initialize(json: data)
                        else {
                            return
                        }

                        promise(.success(user))
                    }
            }
        }.eraseToAnyPublisher()
    }

    public static func fetchUsers() -> AnyPublisher<[AccountEntity], APPError>  {
        Deferred {
            Future { promise in
                self.database
                    .collection(AccountEntity.collectionName)
                    .getDocuments { querySnapshot, error in
                        if let error = error {
                            promise(.failure(.init(error: .failureData(error.localizedDescription))))
                            return
                        }

                        guard
                            let querySnapshot = querySnapshot
                        else {
                            return
                        }

                        let users = querySnapshot.documents
                            .compactMap { AccountEntity.initialize(json: $0.data()) }
                            .filter { $0.email != FirebaseAuthManager.currentUser?.email }

                        promise(.success(users))
                    }
            }
        }.eraseToAnyPublisher()
    }

    // MARK: - Access for Room

    public static func createRoom(partnerUser: AccountEntity) {
        database
            .collection(AccountEntity.collectionName)
            .document(FirebaseAuthManager.currentUser?.uid ?? "")
            .getDocument { querySnapshot, error in
                if let error = error {
                    Logger.debug(message: "failure get info user \(error.localizedDescription)")
                    return
                }

                guard
                    let querySanpshot = querySnapshot,
                    let data = querySanpshot.data(),
                    let user = AccountEntity.initialize(json: data),
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
                    .document()
                    .setData(data, merge: true) { error in
                        if let error = error {
                            Logger.debug(message: "failure create room \(error.localizedDescription)")
                        }
                    }
            }
    }

    public static func fetchRooms(
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

    public static func createChatMessage(
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

    public static func fetchChatMessages(
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
