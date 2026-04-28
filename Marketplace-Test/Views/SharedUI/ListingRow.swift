//
//  File.swift
//  test.abc.com
//
//  Created by Munish Sehdev on 2026-04-25.
//

import Foundation
import SwiftUI

struct ListingRow: View {
    var listing: ListingModel

    var body: some View {
        HStack(spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 4) {
                Text(titleText)
                Text(priceText)
                    .font(.caption)
            }
            Spacer()
            syncIndicator
        }
    }
}

// MARK: - Subviews
private extension ListingRow {
    @ViewBuilder
    var thumbnail: some View {
        if let url = imageURL {
            CachedImageView(url: url)
                .id(url.absoluteString) // 🔥 forces refresh
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    var syncIndicator: some View {
        Image(systemName: isSynced ? "checkmark.circle" : "icloud.and.arrow.up")
            .foregroundColor(isSynced ? .green : .orange)
    }
}

// MARK: - Derived State
private extension ListingRow {
    var titleText: String {
        listing.title ?? "Untitled"
    }

    var priceText: String {
        String(format: "$%.2f", listing.price)
    }

    var isSynced: Bool {
        listing.syncStatusEnum == .synced
    }

    var imageURL: URL? {
        resolveImageURL(from: listing.imagePath)
    }
}

// MARK: - Helpers
private extension ListingRow {
    func resolveImageURL(from path: String?) -> URL? {
        guard let path else { return nil }

        if let url = URL(string: path) {
            if let scheme = url.scheme, scheme.hasPrefix("http") {
                return url
            }

            if url.isFileURL {
                return url
            }
        }

        return ImageStore.getURLForFilename(path)
    }
}
