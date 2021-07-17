import Foundation

struct User: FirebaseModelProtocol & Equatable {
    var id: String
    var name: String
    var email: String
    var imageUrl: String
    var createdAt: Date?

    static let collectionName = "users"
}
