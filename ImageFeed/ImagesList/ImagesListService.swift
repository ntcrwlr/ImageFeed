//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 01.05.2026.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case urls
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    
    private init() {}
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard task == nil else { return }
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService.fetchPhotosNextPage]: Failure - authorization token missing")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makePhotosRequest(page: nextPage, token: token) else {
            print("[ImagesListService.fetchPhotosNextPage]: Failure - invalidRequest, page: \(nextPage)")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                defer { self.task = nil }
                
                switch result {
                case .success(let photoResults):
                    self.lastLoadedPage = nextPage
                    self.photos.append(contentsOf: photoResults.map { Photo(photoResult: $0) })
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                    
                case .failure(let error):
                    print("[ImagesListService.fetchPhotosNextPage]: Failure - \(error.localizedDescription), page: \(nextPage)")
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makePhotosRequest(page: Int, token: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "\(Constants.defaultBaseURLString)/photos") else {
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        return request
    }
}

private extension Photo {
    init(photoResult: PhotoResult) {
        self.init(
            id: photoResult.id,
            size: CGSize(width: photoResult.width, height: photoResult.height),
            createdAt: ISO8601DateFormatter.unsplashDateFormatter.date(from: photoResult.createdAt ?? ""),
            welcomeDescription: photoResult.description,
            thumbImageURL: photoResult.urls.thumb,
            largeImageURL: photoResult.urls.full,
            isLiked: photoResult.likedByUser
        )
    }
}

private extension ISO8601DateFormatter {
    static let unsplashDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
