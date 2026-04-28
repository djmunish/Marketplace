//
//  MockImageStore.swift
//  Marketplace
//
//  Created by Munish Sehdev on 2026-04-27.
//

import XCTest
@testable import Marketplace_Test

final class MockImageStore: ImageStoreProtocol {
    var urlToReturn: URL!

    func url(for filename: String) -> URL {
        return urlToReturn
    }
}
