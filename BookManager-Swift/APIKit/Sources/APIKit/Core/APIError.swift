import Foundation

public enum APIError: LocalizedError, Equatable {
    case unknown
    case missingTestJsonDataPath
    case invalidRequest
    case offline
    case decodingError(String)
    case responseError
    case failureData(String)

    public var errorDescription: String? {
        switch self {
            case .unknown:
                return "unknown error occurred"

            case .missingTestJsonDataPath:
                return "missing test json data path"

            case .invalidRequest:
                return "invalid Request"

            case .offline:
                return "offline error occurred"

            case let .decodingError(error):
                return "decode error occurred \(error)"

            case .responseError:
                return "response error occurred"

            case let .failureData(error):
                return "failure data \(error)"
        }
    }
}
