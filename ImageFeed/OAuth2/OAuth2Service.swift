//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 04.04.2026.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
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
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "OAuth2Service", code: -1)))
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
                    let tokenStorage = OAuth2TokenStorage()
                    tokenStorage.token = token
                    
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

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

