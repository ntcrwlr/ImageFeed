//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 04.04.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let tabBarStoryboardIdentifier = "TabBarViewController"
    private let minimumSplashDuration: TimeInterval = 0
    
    private let storage = OAuth2TokenStorage()
    private var routingWorkItem: DispatchWorkItem?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scheduleRouting()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        routingWorkItem?.cancel()
        routingWorkItem = nil
    }
    
    private func scheduleRouting() {
        routingWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.routeAccordingToAuthState()
        }
        routingWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + minimumSplashDuration, execute: work)
    }
    
    private func routeAccordingToAuthState() {
        if storage.token != nil {
            switchToGallery()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToGallery() {
        guard let window = resolveKeyWindow() else {
            assertionFailure("No key window for splash transition")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let tabBarController = storyboard.instantiateViewController(
            withIdentifier: tabBarStoryboardIdentifier
        ) as? UITabBarController else {
            assertionFailure("Tab bar not found in Main.storyboard (identifier: \(tabBarStoryboardIdentifier))")
            return
        }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = tabBarController
        }
        window.makeKeyAndVisible()
    }
    
    private func resolveKeyWindow() -> UIWindow? {
        if let w = view.window {
            return w
        }
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }
        return scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let authViewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            authViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        switchToGallery()
    }
}
