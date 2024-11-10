import Foundation

internal extension ProcessInfo {
    var googleApplicationCredentials: String? {
        environment["GOOGLE_APPLICATION_CREDENTIALS"]
    }
}
