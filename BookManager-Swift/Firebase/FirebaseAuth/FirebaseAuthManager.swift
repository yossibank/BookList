import FirebaseAuth
import DomainKit
import Utility

final class FirebaseAuthManager {

    typealias CurrentUser = FirebaseAuth.User

    static let shared = FirebaseAuthManager()

    var currentUser: CurrentUser? {
        Auth.auth().currentUser
    }

    var currentUserId: String {
        currentUser?.uid ?? .blank
    }

    private init() {}

    func createUser(
        email: String,
        password: String,
        user: User
    ) {
        Auth.auth().createUser(
            withEmail: email,
            password: password
        ) { result, error in
            guard let result = result else { return }

            FirestoreManager.shared.createUser(
                documentPath: result.user.uid,
                user: user
            )
            if let error = error {
                print("user情報の登録に失敗しました: \(error)")
            }
        }
    }

    func signIn(
        email: String,
        password: String
    ) {
        Auth.auth().signIn(
            withEmail: email,
            password: password
        ) { user, error in
            if user == nil, let error = error {
                print("userがログインに失敗しました: \(error)")
            }
            if let user = user {
                Logger.debug(message: "success signIn user: \(String(describing: user.user.email))")
            }
        }
    }

    func logout() {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
            } catch {
                Logger.debug(message: "failed logout \(error.localizedDescription)")
            }
        } else {
            return
        }
    }
}
