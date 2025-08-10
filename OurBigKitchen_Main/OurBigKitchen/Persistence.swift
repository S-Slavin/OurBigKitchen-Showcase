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
        // TODO: Add sample data when Core Data entities are defined
        // for _ in 0..<10 {
        //     let newItem = Item(context: viewContext)
        //     newItem.timestamp = Date()
        // }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    var container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "OurBigKitchen")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { [container] (storeDescription, error) in
            if let error = error as NSError? {
                // Log the error
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
                            newContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
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
}
