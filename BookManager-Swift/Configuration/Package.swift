import DomainKit
import Firebase
import Utility

struct PackageConfig {

    static func setup() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        DomainConfig.setup(baseURL: API.baseURL)
        UtilityConfig.setup(analytics: FirebaseProvider())
    }

    static func hasAccessToken() -> Bool {
        Domain.Local.Token.hasAccessToken()
    }
}
