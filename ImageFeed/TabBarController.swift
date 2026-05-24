//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 26.04.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        if let imagesListViewController = imagesListViewController as? ImagesListViewController {
            imagesListViewController.configure(ImagesListPresenter())
        }
        let profileViewController = ProfileViewController()
        profileViewController.configure(ProfilePresenter())
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
