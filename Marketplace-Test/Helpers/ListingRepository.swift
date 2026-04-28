import Foundation
import CoreData
import Combine


protocol ListingRepositoryProtocol {
    func fetchAllListings() -> [Listing]
    func isDatabaseEmpty() throws -> Bool
    func seedIfNeeded() async throws
    func seedDatabaseFromJson() async throws
}

class ListingRepository: ObservableObject, ListingRepositoryProtocol {

    let container: NSPersistentContainer
    let context: NSManagedObjectContext // Changed to internal so VM can access or use for fetches

    init(container: NSPersistentContainer)  {
        self.container = container
        context = container.viewContext
    }

    // MARK: - Fetching
    func fetchAllListings() -> [Listing] {
        let request: NSFetchRequest<Listing> = Listing.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Listing.updatedAt, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Fetch failed: \(error)")
            return []
        }
    }

    private func saveContext() {
        try? context.save()
    }

    func isDatabaseEmpty() throws -> Bool {
        let request: NSFetchRequest<Listing> = Listing.fetchRequest()
        request.fetchLimit = 1
        let count = try context.count(for: request)
        return count == 0
    }

    // Changed to async to allow awaiting seeding completion
    func seedIfNeeded() async throws {
        do {
            if try isDatabaseEmpty() {
                print("🌱 Seeding database...")
                try await seedDatabaseFromJson()
            } else {
                print("✅ Database already seeded. Skipping.")
            }
        } catch {
            print("❌ Failed to check DB: \(error)")
        }
    }

    func seedDatabaseFromJson() async throws {
        guard let url = Bundle.main.url(forResource: "listings", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { 
            print("⚠️ listings.json not found in bundle")
            return 
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        do {
            let mockItems = try decoder.decode([MockListing].self, from: data)
            for item in mockItems {
                let newListing = Listing(context: context)
                newListing.id = item.id
                newListing.title = item.title
                newListing.imagePath = item.imagePath
                newListing.price = item.price
                newListing.updatedAt = item.updatedAt
                newListing.syncStatusEnum = .synced
            }

            try context.save()
            print("Successfully seeded \(mockItems.count) items.")

            // Image processing stays backgrounded
            Task.detached(priority: .background) { [weak self] in
                guard let self = self else { return }
                let results = await ImageStore.processImagesInBackground(mockItems)
                await MainActor.run {
                    for (id, filename) in results {
                        let fetch: NSFetchRequest<Listing> = Listing.fetchRequest()
                        fetch.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                        if let listing = try? self.context.fetch(fetch).first {
                            listing.imagePath = filename
                        }
                    }
                    try? self.context.save()
                }
            }
        } catch {
            print("Seeding failed: \(error)")
        }
    }
}
