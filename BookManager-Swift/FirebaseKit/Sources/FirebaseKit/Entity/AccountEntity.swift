import Foundation

public struct AccountEntity: FirebaseEntityProtocol & Equatable {
    public let id: String
    public let name: String
    public let email: String
    public let imageUrl: String
    public let createdAt: Date?

    public init(
        id: String,
        name: String,
        email: String,
        imageUrl: String,
        createdAt: Date?
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.imageUrl = imageUrl
        self.createdAt = createdAt
    }

    static let collectionName = "users"
}
