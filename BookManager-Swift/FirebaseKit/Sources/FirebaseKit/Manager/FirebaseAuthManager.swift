import FirebaseAuth
import Utility

public class FirebaseAuthManager {

    public typealias CurrentUser = FirebaseAuth.User

    public static let shared = FirebaseAuthManager()

    public var currentUser: CurrentUser? {
        Auth.auth().currentUser
    }

    public var currentUserId: String {
        currentUser?.uid ?? ""
    }

    private init() {}

    public func createUser(
        email: String,
        password: String,
        user: AccountEntity
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

    public func signIn(
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

    public func logout() {
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
