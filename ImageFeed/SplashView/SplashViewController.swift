//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 04.04.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let authViewControllerStoryboardIdentifier = "AuthViewController"
    private let tabBarStoryboardIdentifier = "TabBarViewController"
    private let minimumSplashDuration: TimeInterval = 0
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared
    private var routingWorkItem: DispatchWorkItem?
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Vector"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
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
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            showAuthViewController()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 75),
            logoImageView.heightAnchor.constraint(equalToConstant: 77)
        ])
    }
    
    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(
            withIdentifier: authViewControllerStoryboardIdentifier
        ) as? AuthViewController else {
            assertionFailure("Failed to instantiate AuthViewController")
            return
        }
        
        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
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

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = storage.token else {
            return
        }
        fetchProfile(token: token)
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToGallery()
                
            case .failure:
                self.showProfileLoadingError(token: token)
            }
        }
    }
    
    private func showProfileLoadingError(token: String) {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось загрузить профиль",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.fetchProfile(token: token)
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
}
