//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 04.04.2026.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    private func fulfillCompletionOnMainThread<T>(
        with result: Result<T, Error>,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        if Thread.isMainThread {
            completion(result)
        } else {
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            if let error {
                let wrappedError = NetworkError.urlRequestError(error)
                print("[URLSession.data]: Failure - \(wrappedError), url: \(request.url?.absoluteString ?? "nil")")
                self.fulfillCompletionOnMainThread(with: .failure(wrappedError), completion: completion)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NetworkError.urlSessionError
                print("[URLSession.data]: Failure - \(error), url: \(request.url?.absoluteString ?? "nil")")
                self.fulfillCompletionOnMainThread(with: .failure(error), completion: completion)
                return
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                let error = NetworkError.httpStatusCode(httpResponse.statusCode)
                print("[URLSession.data]: Failure - \(error), url: \(request.url?.absoluteString ?? "nil")")
                self.fulfillCompletionOnMainThread(with: .failure(error), completion: completion)
                return
            }

            guard let data else {
                let error = NetworkError.urlSessionError
                print("[URLSession.data]: Failure - \(error), url: \(request.url?.absoluteString ?? "nil")")
                self.fulfillCompletionOnMainThread(with: .failure(error), completion: completion)
                return
            }

            self.fulfillCompletionOnMainThread(with: .success(data), completion: completion)
        }
        return task
    }

    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("[URLSession.objectTask]: DecodingError - \(error.localizedDescription), data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
