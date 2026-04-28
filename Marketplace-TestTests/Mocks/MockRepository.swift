//
//  MockRepository.swift
//  Marketplace
//
//  Created by Munish Sehdev on 2026-04-27.
//


import XCTest
@testable import Marketplace_Test
import Combine

final class MockRepository: ListingRepositoryProtocol {

    // MARK: - Publisher
    private let subject = CurrentValueSubject<[ListingModel], Never>([])

    var listingsPublisher: AnyPublisher<[ListingModel], Never> {
        subject.eraseToAnyPublisher()
    }

    var listings: [ListingModel] = []
    var createdListing: (title: String, price: Double, image: Data)?
    var updatedListing: (listing: ListingModel, title: String, price: Double, image: Data?)?

    var shouldThrow = false
    var uploadCalled = false
    var updatedCalled = false
    var seedCalled = false

    func fetchAllListings() -> [ListingModel] {
        return listings
    }
    
    func createListing(title: String, price: Double, image: Data) async {
        createdListing = (title, price, image)
    }
    
    func updateListing(listing: ListingModel, title: String, price: Double, newImageData: Data?) async {
        updatedListing = (listing, title, price, newImageData)
        updatedCalled = true
    }
    
    func isDatabaseEmpty() throws -> Bool {
        return true
    }
    
    func seedIfNeeded() async {
        seedCalled = true
    }
    
    func seedDatabaseFromJson() async throws {
    }

    func uploadPendingListings() async {
        uploadCalled = true
    }
}
