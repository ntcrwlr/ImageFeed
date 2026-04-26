//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//

import UIKit

@MainActor
protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
