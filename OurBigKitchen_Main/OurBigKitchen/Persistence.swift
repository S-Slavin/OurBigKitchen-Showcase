//
//  Persistence.swift
//  OurBigKitchen
//
//  Created by Admin on 17/4/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add sample data for previews when Core Data entities are defined
        // for _ in 0..<10 {
        //     let newItem = Item(context: viewContext)
        //     newItem.timestamp = Date()
        // }
        
        do {
            try viewContext.save()
        } catch {
            // Log error for debugging but don't crash
            let nsError = error as NSError
            print("Preview context save failed: \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    var container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "OurBigKitchen")
        
        if inMemory {
            guard let firstStoreDescription = container.persistentStoreDescriptions.first else {
                print("Error: No persistent store descriptions found")
                return
            }
            firstStoreDescription.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { [container] (storeDescription, error) in
            if let error = error as NSError? {
                // Log the error for debugging
                print("Error loading persistent store: \(error), \(error.userInfo)")
                
                // Attempt to recover by deleting and recreating the store
                if let storeURL = storeDescription.url {
                    do {
                        try FileManager.default.removeItem(at: storeURL)
                        print("Removed corrupted store at \(storeURL)")
                        
                        // Try loading again
                        do {
                            try container.persistentStoreCoordinator.addPersistentStore(
                                ofType: storeDescription.type,
                                configurationName: storeDescription.configuration,
                                at: storeURL,
                                options: storeDescription.options
                            )
                            print("Successfully recreated store")
                        } catch {
                            print("Failed to recreate store: \(error)")
                            // Create a new in-memory store as fallback
                            let newContainer = NSPersistentCloudKitContainer(name: "OurBigKitchen")
                            guard let firstStoreDescription = newContainer.persistentStoreDescriptions.first else {
                                print("Error: No persistent store descriptions found in fallback container")
                                return
                            }
                            firstStoreDescription.url = URL(fileURLWithPath: "/dev/null")
                            newContainer.loadPersistentStores { (_, error) in
                                if let error = error {
                                    print("Failed to create in-memory store: \(error)")
                                }
                            }
                        }
                    } catch {
                        print("Failed to remove corrupted store: \(error)")
                    }
                }
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Configure the view context for better performance
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
    }
    
    // MARK: - Error Handling
    
    func save() throws {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                throw PersistenceError.saveFailed(nsError)
            }
        }
    }
    
    func delete(_ object: NSManagedObject) throws {
        let context = container.viewContext
        context.delete(object)
        try save()
    }
    
    func rollback() {
        container.viewContext.rollback()
    }
}

// MARK: - Persistence Errors

enum PersistenceError: LocalizedError {
    case saveFailed(Error)
    case deleteFailed(Error)
    case fetchFailed(Error)
    case storeNotFound
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save changes: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete object: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch data: \(error.localizedDescription)"
        case .storeNotFound:
            return "Core Data store not found"
        }
    }
}
