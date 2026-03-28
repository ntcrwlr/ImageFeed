//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 02.03.2026.
//

import UIKit
import QuartzCore

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    private let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGradientToImage()
    }
    
    private func addGradientToImage() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.6).cgColor]
        gradientLayer.locations = [0.6, 1.0]
        cellImage.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = cellImage.bounds
    }
}
