import Combine
import DomainKit
import FirebaseStorage
import Utility

public struct FirebaseStorageManager {

    private struct Constant {
        static let userIconPath = "user_icon"
    }

    private static let reference = Storage.storage().reference()

    private static let metaData: StorageMetadata = {
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        return metaData
    }()

    public static func saveUserIconImage(
        path: String,
        uploadImage: Data
    ) -> AnyPublisher<Void, APPError> {
        Deferred {
            Future { promise in
                reference
                    .child(Constant.userIconPath)
                    .child(path)
                    .putData(uploadImage, metadata: metaData) { _, error in
                        if let error = error {
                            promise(.failure(.init(error: .failureData(error.localizedDescription))))
                            return
                        }

                        promise(.success(()))
                    }
            }
        }.eraseToAnyPublisher()
    }

    public static func fetchDownloadUrlString(path: String) -> AnyPublisher<String, APPError> {
        Deferred {
            Future { promise in
                reference
                    .child(Constant.userIconPath)
                    .child(path)
                    .downloadURL { url, error in
                        if let error = error {
                            promise(.failure(.init(error: .failureData(error.localizedDescription))))
                            return
                        }

                        guard
                            let urlString = url?.absoluteString
                        else {
                            return
                        }

                        promise(.success(urlString))
                    }
            }
        }.eraseToAnyPublisher()
    }
}
