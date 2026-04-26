//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 04.04.2026.
//

import Foundation

enum OAuth2ServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Singleton
    
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: - Private Properties
    
    private let tokenStorage = OAuth2TokenStorage()
    
    // MARK: - Private Methods

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("❌ OAuth2Service: failed to create URLComponents for token endpoint")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let authTokenUrl = urlComponents.url else {
            print("❌ OAuth2Service: failed to get URL from URLComponents: \(urlComponents)")
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }

    // MARK: - Public Methods
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("❌ OAuth2Service: failed to build URLRequest for code: \(code)")
            DispatchQueue.main.async {
                completion(.failure(OAuth2ServiceError.invalidRequest))
            }
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let token = responseBody.accessToken

                    self.tokenStorage.token = token

                    DispatchQueue.main.async {
                        completion(.success(token))
                    }
                    
                } catch {
                    print("❌ Decoding error: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                print("❌ Network or HTTP error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

