//
//  PromptCollectionViewCell.swift
//  Home
//
//  Created by user@3 on 10/11/25.
//

import UIKit

class PromptCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var promptLabel: UILabel!
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Configuration
    func configure(icon: UIImage?, text: String) {
        iconImageView.image = icon
        promptLabel.text = text
    }
}
