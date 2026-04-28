import SwiftUI
import Combine

@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false

    private let url: URL
    private static let cache = NSCache<NSURL, UIImage>()

    init(url: URL) {
        self.url = url
    }

    func load() async {
        if let cached = Self.cache.object(forKey: url as NSURL) {
            self.image = cached
            return
        }

        isLoading = true

        if url.isFileURL {
            loadLocalImage()
        } else {
            await downloadRemoteImage()
        }
    }

    private func loadLocalImage() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            if let data = try? Data(contentsOf: self.url),
               let loadedImage = UIImage(data: data) {

                Self.cache.setObject(loadedImage, forKey: self.url as NSURL)

                DispatchQueue.main.async {
                    self.image = loadedImage
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

    private func downloadRemoteImage() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let downloadedImage = UIImage(data: data) {
                Self.cache.setObject(downloadedImage, forKey: url as NSURL)
                self.image = downloadedImage
                self.isLoading = false
            }
        } catch {
            self.isLoading = false
        }
    }
}
