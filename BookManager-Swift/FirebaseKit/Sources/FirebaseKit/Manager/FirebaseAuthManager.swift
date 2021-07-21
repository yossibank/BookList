import FirebaseAuth
import Utility

public struct FirebaseAuthManager {

    public typealias CurrentUser = FirebaseAuth.User

    public static var currentUser: CurrentUser? {
        Auth.auth().currentUser
    }

    public static func createUser(
        email: String,
        password: String,
        user: AccountEntity
    ) {
        Auth.auth().createUser(
            withEmail: email,
            password: password
        ) { result, error in
            guard let result = result else { return }

            FirestoreManager.createUser(
                documentPath: result.user.uid,
                user: user
            )
            if let error = error {
                print("user情報の登録に失敗しました: \(error)")
            }
        }
    }

    public static func signIn(
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

    public static func logout() {
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
