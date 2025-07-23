import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func save<T: Encodable>(_ object: T, forKey key: String) throws {
        let data = try encoder.encode(object)
        userDefaults.set(data, forKey: key)
    }
    
    func load<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T {
        guard let data = userDefaults.data(forKey: key) else {
            throw PersistenceError.notFound
        }
        return try decoder.decode(type, from: data)
    }
    
    func getObject<T: Decodable>(forKey key: String, as type: T.Type) throws -> T {
        guard let data = userDefaults.data(forKey: key) else {
            throw PersistenceError.notFound
        }
        return try decoder.decode(type, from: data)
    }
    
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}

enum PersistenceError: Error {
    case notFound
    case encodingFailed
    case decodingFailed
} 