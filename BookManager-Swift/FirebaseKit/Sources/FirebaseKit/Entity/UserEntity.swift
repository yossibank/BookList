import Foundation

public struct UserEntity: FirebaseEntityProtocol & Equatable {
    let id: String
    let name: String
    let email: String
    let imageUrl: String
    let createdAt: Date?

    static let collectionName = "users"
}
