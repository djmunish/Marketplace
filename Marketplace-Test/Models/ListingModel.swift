//
//  ListingModel.swift
//  Marketplace-Test
//
//  Created by Munish Sehdev on 2026-04-27.
//

import Foundation

struct ListingModel {
    let id: UUID
    let title: String
    let price: Double
    let imagePath: String?
    let updatedAt: Date?
    let syncStatusEnum: SyncStatus
}
