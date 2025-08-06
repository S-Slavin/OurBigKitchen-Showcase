import Foundation
import SwiftUI

enum PersistenceError: Error {
    case encodingFailed
    case decodingFailed
    case saveFailed
    case notFound
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .encodingFailed:
            return "Failed to encode data"
        case .decodingFailed:
            return "Failed to decode data"
        case .saveFailed:
            return "Failed to save data"
        case .notFound:
            return "Data not found"
        case .invalidData:
            return "Invalid data format"
        }
    }
}

@Observable
final class PersistenceManager: @unchecked Sendable {
    static let shared = PersistenceManager()
    
    private let fileManager: FileManager = .default
    private let cacheDirectory: URL
    private let userDefaults: UserDefaults
    
    private init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        self.cacheDirectory = urls[0].appendingPathComponent("OBKCache")
        self.userDefaults = UserDefaults.standard
        
        try? fileManager.createDirectory(at: cacheDirectory, 
                                       withIntermediateDirectories: true)
    }
    
    func save<T: Encodable>(_ value: T, forKey key: String) throws {
        do {
            let data = try JSONEncoder().encode(value)
            userDefaults.set(data, forKey: key)
        } catch {
            throw PersistenceError.encodingFailed
        }
    }
    
    func getObject<T: Decodable>(forKey key: String, as type: T.Type) throws -> T {
        guard let data = userDefaults.data(forKey: key) else {
            throw PersistenceError.notFound
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw PersistenceError.decodingFailed
        }
    }
    
    func saveString(_ value: String, forKey key: String) throws {
        userDefaults.set(value, forKey: key)
    }
    
    func getString(forKey key: String) throws -> String {
        guard let value = userDefaults.string(forKey: key) else {
            throw PersistenceError.notFound
        }
        return value
    }
    
    func remove(forKey key: String) throws {
        userDefaults.removeObject(forKey: key)
    }
    
    func clearAll() throws {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }
    
    // MARK: - File Operations
    
    func saveFile(_ data: Data, withName filename: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        try data.write(to: fileURL)
    }
    
    func loadFile(named filename: String) throws -> Data {
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        return try Data(contentsOf: fileURL)
    }
    
    func deleteFile(named filename: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        try fileManager.removeItem(at: fileURL)
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, 
                                       withIntermediateDirectories: true)
    }
    
    func getCacheSize() throws -> Int64 {
        let resourceValues = try cacheDirectory.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
        return Int64(resourceValues.totalFileAllocatedSize ?? 0)
    }
    
    func load<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T {
        guard let data = userDefaults.data(forKey: key) else {
            throw NSError(domain: "PersistenceManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data found for key: \(key)"])
        }
        return try JSONDecoder().decode(type, from: data)
    }
} 