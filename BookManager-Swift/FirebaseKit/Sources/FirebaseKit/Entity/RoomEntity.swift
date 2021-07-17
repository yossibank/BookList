import Foundation

public struct RoomEntity: FirebaseEntityProtocol & Equatable {
    let id: String
    let users: [UserEntity]
    let lastMessage: String?
    let lastMessageSendAt: Date?
    let createdAt: Date

    static let collectionName = "rooms"
}
