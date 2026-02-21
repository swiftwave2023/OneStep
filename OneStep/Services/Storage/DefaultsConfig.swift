import Foundation

struct AppDefaults {
    private static let store = UserDefaults.standard
    
    // MARK: - Keys
    private enum Key {
        static let moreAppsCache = "moreAppsCache"
        static let moreAppsMetadataCache = "moreAppsMetadataCache"
        static let lastMoreAppsFetchTime = "lastMoreAppsFetchTime"
    }
    
    // MARK: - More Apps Cache
    static var moreAppsCache: [MoreAppData] {
        get { getCodable([MoreAppData].self, forKey: Key.moreAppsCache) ?? [] }
        set { setCodable(newValue, forKey: Key.moreAppsCache) }
    }
    
    static var moreAppsMetadataCache: MoreAppsMetadata? {
        get { getCodable(MoreAppsMetadata.self, forKey: Key.moreAppsMetadataCache) }
        set { setCodable(newValue, forKey: Key.moreAppsMetadataCache) }
    }
    
    static var lastMoreAppsFetchTime: Date {
        get { (store.object(forKey: Key.lastMoreAppsFetchTime) as? Date) ?? .distantPast }
        set { store.set(newValue, forKey: Key.lastMoreAppsFetchTime) }
    }
    
    // MARK: - Helpers
    private static func getCodable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = store.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    private static func setCodable<T: Codable>(_ value: T?, forKey key: String) {
        if let value = value, let data = try? JSONEncoder().encode(value) {
            store.set(data, forKey: key)
        } else {
            store.removeObject(forKey: key)
        }
    }
}
