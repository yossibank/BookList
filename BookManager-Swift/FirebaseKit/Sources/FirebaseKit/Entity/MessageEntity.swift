import Foundation

public struct MessageEntity: FirebaseEntityProtocol & Equatable {
    let id: String
    let name: String
    let iconUrl: String
    let message: String
    let sendAt: Date?

    static let collecitonName = "chatMessages"
}
