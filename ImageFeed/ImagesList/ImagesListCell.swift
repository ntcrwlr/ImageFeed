//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 02.03.2026.
//

import UIKit
import QuartzCore
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLabel.text = nil
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImageName = isLiked ? "like_button_on" : "like_button_off"
        likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
    
    func setLikeButtonEnabled(_ isEnabled: Bool) {
        likeButton.isEnabled = isEnabled
    }
}
