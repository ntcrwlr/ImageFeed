//
//  Constants.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 29.03.2026.
//

import Foundation

enum Constants {
    static let accessKey = "SPlNHGjgD9iAImGq93gnlqSa138rRwxbUmRPVBs44HI"
    static let secretKey = "km_EJUTjDWXhJNgM-JLF4_AXGKJfvQ7Zy3XFE-aeyDo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public read_user write_likes"
    static let defaultBaseURLString = "https://api.unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURLString = defaultBaseURLString
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURLString: Constants.defaultBaseURLString)
    }
}
