import Foundation

internal extension URL {
    static let applicationDefaultCredentialsJSON = URL(fileURLWithPath: NSHomeDirectory())
        .appending(components: ".config", "gcloud", "application_default_credentials.json")
}
