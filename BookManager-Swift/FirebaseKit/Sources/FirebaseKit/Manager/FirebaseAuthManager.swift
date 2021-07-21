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
        account: AccountEntity
    ) {
        Auth.auth().createUser(
            withEmail: email,
            password: password
        ) { result, error in
            guard
                let result = result
            else {
                return
            }

            if let error = error {
                Logger.debug(message: "failure create user: \(error.localizedDescription)")
            }

            FirestoreManager.createUser(
                documentPath: result.user.uid,
                account: account
            )
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
                Logger.debug(message: "failure signIn user: \(error.localizedDescription)")
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
                Logger.debug(message: "failure logout: \(error.localizedDescription)")
            }
        }
    }
}
