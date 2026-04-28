//
//  RottenMoviesApp.swift
//  RottenMovies
//
//  SwiftUI App entry point
//

import SwiftUI
import CoreData

@main
struct MyNewApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {

            let repository = ListingRepository(
                container: persistenceController.container
            )

            let viewModel = ListingViewModel(repository: repository)

            ListingView(viewModel: viewModel)
        }
    }
}
