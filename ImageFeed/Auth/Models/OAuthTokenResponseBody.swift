//
//  Models.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 06.04.2026.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
