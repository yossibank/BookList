import Foundation

struct ChatMessage: FirebaseModelProtocol & Equatable {
    var id: String
    var name: String
    var iconUrl: String
    var message: String
    var sendAt: FirestoreManager.timeStamp

    static let collecitonName = "chatMessages"
}
