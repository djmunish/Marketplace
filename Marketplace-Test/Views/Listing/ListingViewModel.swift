import Foundation
import Combine
import CoreData

@MainActor
@Observable
class ListingViewModel {
    var repository: ListingRepositoryProtocol

    var listings: [ListingModel] = [] 
    var isLoading = false
    var errorMessage: String?

    init(repository: ListingRepositoryProtocol) {
        self.repository = repository

        self.repository.onDataChanged = { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.listings = self.repository.fetchAllListings()
            }
        }
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

    func sync() async {
        await repository.uploadPendingListings()
        listings = repository.fetchAllListings()
    }
}
