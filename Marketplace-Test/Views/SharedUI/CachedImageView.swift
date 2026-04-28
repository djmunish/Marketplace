import SwiftUI

struct CachedImageView: View {
    @StateObject private var loader: ImageLoader

    init(url: URL) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else if loader.isLoading {
                ProgressView()
            } else {
                placeholder
            }
        }
        .task {
            await loader.load()
        }
    }

    private var placeholder: some View {
        ZStack {
            Color.gray.opacity(0.1)
            Image(systemName: "photo")
                .foregroundColor(.gray)
        }
    }
}
