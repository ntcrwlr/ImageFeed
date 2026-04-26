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
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private var activeRequestID: UUID?
    
    // MARK: - Private Methods
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("[OAuth2Service.makeOAuthTokenRequest]: Failure - invalidURL, code: \(code)")
            return nil
        }

        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        let bodyString = parameters
            .map { key, value in
                let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(escapedKey)=\(escapedValue)"
            }
            .joined(separator: "&")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        return request
    }
    
    // MARK: - Public Methods
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print("[OAuth2Service.fetchOAuthToken]: Failure - invalidRequest, code: \(code)")
            completion(.failure(OAuth2ServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code
        let requestID = UUID()
        activeRequestID = requestID
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service.fetchOAuthToken]: Failure - invalidRequest, code: \(code)")
            activeRequestID = nil
            lastCode = nil
            completion(.failure(OAuth2ServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard
                    let self = self,
                    self.activeRequestID == requestID,
                    self.lastCode == code
                else {
                    return
                }

                switch result {
                case .success(let responseBody):
                    let token = responseBody.accessToken
                    self.tokenStorage.token = token
                    completion(.success(token))

                case .failure(let error):
                    print("[OAuth2Service.fetchOAuthToken]: Failure - \(error.localizedDescription), code: \(code)")
                    completion(.failure(error))
                }

                self.task = nil
                self.lastCode = nil
                self.activeRequestID = nil
            }
        }
        self.task = task
        task.resume()
    }
}
