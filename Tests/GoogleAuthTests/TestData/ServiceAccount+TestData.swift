import Foundation
import GoogleAuth

extension ServiceAccount {
    static func test() -> ServiceAccount {
        try! JSONDecoder().decode(
            ServiceAccount.self,
            from: .init(contentsOf: Bundle.module.url(forResource: "test_service_account", withExtension: "json")!)
        )
    }
}
