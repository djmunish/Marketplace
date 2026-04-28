import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // A preview instance for SwiftUI Previews
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Add mock data for previews here if needed
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // ⚠️ CRITICAL: The name "Marketplace_Test" must match your .xcdatamodeld filename exactly.
        container = NSPersistentContainer(name: "Marketplace_Test")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        // Enable lightweight migration automatically
        if let description = container.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        }

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for crash here:
                 1. Model name mismatch (check .xcdatamodeld filename).
                 2. Migration failure (delete the app from simulator and Re-run).
                 3. Out of disk space.
                 */
                print("❌ Core Data failed to load: \(error.localizedDescription)")
                print("Error info: \(error.userInfo)")
                
                // In development, you might want to see the error. 
                // In production, handle this gracefully.
                #if DEBUG
                // fatalError("Unresolved error \(error), \(error.userInfo)")
                #endif
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        // This policy prevents crashes when local seeding conflicts with existing IDs
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
