import Combine
import FirebaseStorage
import FirebaseStorageSwift
import Utility

struct FirebaseStorageManager {

    private struct Constant {
        static let userIconPath = "user_icon"
    }

    private static let reference = Storage.storage().reference()

    private static let metaData: StorageMetadata = {
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        return metaData
    }()

    static func saveUserIconImage(
        path: String,
        uploadImage: Data
    ) {
        reference.child(Constant.userIconPath).child(path).putData(
            uploadImage,
            metadata: metaData
        ) { _, error in
            if let error = error {
                Logger.debug(message: error.localizedDescription)
                return
            }
        }
    }

    static func fetchDownloadUrlString(path: String, completion: @escaping (String) -> Void) {
        reference.child(Constant.userIconPath).child(path).downloadURL { url, error in
            if let error = error {
                Logger.debug(message: error.localizedDescription)
                return
            }

            guard
                let urlString = url?.absoluteString
            else {
                return
            }

            completion(urlString)
        }
    }
}
