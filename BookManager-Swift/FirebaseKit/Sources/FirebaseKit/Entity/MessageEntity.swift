import Foundation

public struct MessageEntity: FirebaseEntityProtocol & Equatable {
    public let id: String
    public let name: String
    public let iconUrl: String
    public let message: String
    public let sendAt: Date?

    static let collecitonName = "chatMessages"
}
