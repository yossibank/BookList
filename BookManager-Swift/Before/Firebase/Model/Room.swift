import Foundation

struct Room: FirebaseModelProtocol & Equatable {
    var id: String
    var users: [User]
    var lastMessage: String?
    var lastMessageSendAt: FirestoreManager.timeStamp?
    var createdAt: FirestoreManager.timeStamp

    static let collectionName = "rooms"
}
