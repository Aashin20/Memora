//
//  CategoryCollectionViewCell.swift
//  Home
//
//  Created by user@3 on 11/11/25.
//

import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CategoryCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var pillView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()

        // pill background
        pillView.backgroundColor = .white
        pillView.layer.cornerRadius = 25      // pill shape (adjust as needed)
        pillView.layer.masksToBounds = true

        // icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue // default tint; replace per item if needed

        // label
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        // accessibility & small polish
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    func configure(icon: UIImage?, text: String, tint: UIColor? = nil) {
        iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)
        if let tint = tint {
            iconImageView.tintColor = tint
        }
        titleLabel.text = text
        accessibilityLabel = text
    }
}
