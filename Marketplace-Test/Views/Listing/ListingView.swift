import SwiftUI
import CoreData

enum ListingSheet: Identifiable {
    case create
    case edit(Listing)

    var id: String {
        switch self {
        case .create:
            return "create"
        case .edit(let listing):
            return listing.id?.uuidString ?? UUID().uuidString
        }
    }
}

struct ListingView: View {
     @State var viewModel: ListingViewModel

    // We only need one piece of state to manage the sheet
    // If selectedListing is nil, we are "Creating". 
    // If it has a value, we are "Editing".
    @State private var activeSheet: ListingSheet?

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.listings.isEmpty {
                    ProgressView("Loading Marketplace...")
                } else if viewModel.listings.isEmpty {
                    ContentUnavailableView(
                        "No Listings",
                        systemImage: "bag",
                        description: Text("Try adding something new or check your listings.json file.")
                    )
                } else {
                    List(viewModel.listings) { item in
                        ListingRow(listing: item)
                            .contentShape(Rectangle())
                            // Adding a unique ID helps SwiftUI track rows during updates
                            .id("\(item.objectID.uriRepresentation().absoluteString)-\(item.updatedAt?.timeIntervalSince1970 ?? 0)")
                            .onTapGesture {
                                activeSheet = .edit(item)
                            }
                    }
                }
            }
            .navigationTitle("Marketplace")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Task{
                    await viewModel.loadEvents()
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        activeSheet = .create
                    }) {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
            }
        }
    }
}
