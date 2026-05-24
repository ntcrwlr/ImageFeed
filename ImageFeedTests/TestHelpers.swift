@testable import ImageFeed
import UIKit

extension Photo {
    static func make(id: String, isLiked: Bool = false) -> Photo {
        Photo(
            id: id,
            size: CGSize(width: 100, height: 200),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://example.com/thumb.jpg",
            regularImageURL: "https://example.com/regular.jpg",
            largeImageURL: "https://example.com/large.jpg",
            isLiked: isLiked
        )
    }
}
