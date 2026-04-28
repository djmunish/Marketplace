import Foundation
import Combine
import CoreData

@MainActor
@Observable
class ListingViewModel {
    let repository: ListingRepositoryProtocol

    var listings: [ListingModel] = []
    var isLoading = false
    var errorMessage: String?

    init(repository: ListingRepositoryProtocol) {
        self.repository = repository
    }

    func loadEvents() async {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.seedIfNeeded()
            listings = repository.fetchAllListings()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func fetchFromCoreData() {
        self.listings = repository.fetchAllListings()
    }
}
