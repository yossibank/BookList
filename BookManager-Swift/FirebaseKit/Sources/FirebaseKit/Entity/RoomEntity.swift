import Foundation

public struct RoomEntity: FirebaseEntityProtocol & Equatable {
    public let id: String
    public let users: [AccountEntity]
    public let lastMessage: String?
    public let lastMessageSendAt: Date?
    public let createdAt: Date

    static let collectionName = "rooms"
}
