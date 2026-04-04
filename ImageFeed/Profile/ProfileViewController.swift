//
//  Untitled.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 07.03.2026. //////
//

import UIKit

final class ProfileViewController: UIViewController {
    @objc private func didTapButton() {}
    
    private var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        let profileImage = UIImage(named: "avatar")
        let imageView = UIImageView(image: profileImage)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhiteIOS
        label.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        self.label = label
        
        let label2 = UILabel()
        label2.text = "@ekaterina_nov"
        label2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label2)
        label2.textColor = .ypGrayIOS
        label2.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
        label2.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8).isActive = true
        self.label = label2
        
        let label3 = UILabel()
        label3.text = "Hello, world!"
        label3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label3)
        label3.textColor = .ypWhiteIOS
        label3.leadingAnchor.constraint(equalTo: label2.leadingAnchor).isActive = true
        label3.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 8).isActive = true
        self.label = label3
        
        let button = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        button.tintColor = .ypRedIOS
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    
}

