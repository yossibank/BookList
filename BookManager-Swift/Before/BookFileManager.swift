import Foundation

public struct BookFileManager {

    private static var fileManager: FileManager {
        FileManager.default
    }

    private static var fetchFiles: [String] {
        let documentDirectoryUrl = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        do {
            let contentUrls = try fileManager.contentsOfDirectory(
                at: documentDirectoryUrl,
                includingPropertiesForKeys: nil
            )
            let files = contentUrls.map { $0.lastPathComponent }

            return files
        } catch {
            return []
        }
    }

    public static func setData(path: String, data: Data?) {
        guard
            let url = try? fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent(path)
        else {
            return
        }

        try? data?.write(to: url)
    }

    public static func removeData(path: String) {
        guard
            let url = try? fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            ).appendingPathComponent(path)
        else {
            return
        }

        try? fileManager.removeItem(at: url)
    }

    public static func fetchData<T: Decodable>() -> [T] {
        fetchFiles.flatMap { file -> [T] in
            guard
                let url = try? fileManager.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
                ).appendingPathComponent(file)
            else {
                return []
            }

            guard
                let json = try? Data(contentsOf: url),
                let data = try? T.decodeFrom(json: json)
            else {
                return []
            }

            return [data]
        }
    }

    public static func isContainPath(path: String) -> Bool {
        fetchFiles.contains(path) ? true : false
    }
}

public extension Decodable {

    static func decodeFrom(json: Data) throws -> Self {
        let new: Self
        do {
            new = try JSONDecoder().decode(self, from: json)
        } catch {
            throw error
        }
        return new
    }
}
