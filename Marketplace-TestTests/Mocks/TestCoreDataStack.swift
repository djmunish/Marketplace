//
//  TestCoreDataStack.swift
//  Marketplace
//
//  Created by Munish Sehdev on 2026-04-27.
//

internal import CoreData

final class TestCoreDataStack {

    static func container() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Marketplace_Test")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ In-memory store failed: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }
}
