import Combine
import DomainKit
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
    ) -> AnyPublisher<Void, APPError> {
        Deferred {
            Future { promise in
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
                        promise(.failure(.init(error: .failureData(error.localizedDescription))))
                        return
                    }

                    FirestoreManager.createUser(
                        documentPath: result.user.uid,
                        account: account
                    )

                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }

    public static func signIn(
        email: String,
        password: String
    ) -> AnyPublisher<Void, APPError> {
        Deferred {
            Future { promise in
                Auth.auth().signIn(
                    withEmail: email,
                    password: password
                ) { user, error in
                    if user == nil, let error = error {
                        promise(.failure(.init(error: .failureData(error.localizedDescription))))
                        return
                    }

                    if let user = user {
                        Logger.debug(message: "success signIn user: \(String(describing: user.user.email))")
                        promise(.success(()))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    public static func logout() -> AnyPublisher<Void, APPError> {
        Deferred {
            Future { promise in
                if Auth.auth().currentUser != nil {
                    do {
                        try Auth.auth().signOut()
                        promise(.success(()))
                    } catch {
                        promise(.failure(.init(error: .failureData(error.localizedDescription))))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
