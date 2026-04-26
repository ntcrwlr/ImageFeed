//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 19.04.2026.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

final class ProfileService {
    
    static let shared = ProfileService()
    private init() {}
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let profileURL = URL(string: "https://api.unsplash.com/me")!
    private(set) var profile: Profile?
    
    private func makeProfileRequest(token: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.unsplash.com/me")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        let request = makeProfileRequest(token: token)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                defer { self?.task = nil }
                
                switch result {
                case .failure(let error):
                    print("[ProfileService.fetchProfile]: Failure - \(error.localizedDescription)")
                    completion(.failure(error))
                
                case .success(let result):
                    let name = [result.firstName, result.lastName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    
                    let profile = Profile(
                        username: result.username,
                        name: name,
                        loginName: "@\(result.username)",
                        bio: result.bio
                    )
                    
                    self?.profile = profile
                    completion(.success(profile))
                }
            }
        }
        self.task = task
        task.resume()
    }
}
