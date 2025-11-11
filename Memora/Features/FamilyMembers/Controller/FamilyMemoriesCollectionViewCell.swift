//
//  FamilyMemoriesCollectionViewCell.swift
//  Memora
//
//  Created by user@3 on 10/11/25.
//

import UIKit

class FamilyMemoriesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }

    private func setupAppearance() {

        // --- Rounded Image ---
        cardImageView.clipsToBounds = true
        cardImageView.contentMode = .scaleAspectFill
        cardImageView.layer.cornerRadius = 0

        // --- Styling for card container ---
        contentView.layer.cornerRadius = 50
        contentView.layer.masksToBounds = true

        // --- Shadow on cell (NOT contentView) ---
        layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 1
        layer.masksToBounds = false

        // Label styling
        promptLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        promptLabel.textColor = .black
        promptLabel.numberOfLines = 2

        authorLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        authorLabel.textColor = .darkGray
    }

    func configure(prompt: String, author: String, image: UIImage?) {
        promptLabel.text = prompt
        authorLabel.text = "by \(author)"

        if let img = image {
            cardImageView.image = img
        } else {
            cardImageView.image = nil
            cardImageView.backgroundColor = UIColor(white: 0.94, alpha: 1)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cardImageView.image = nil
        promptLabel.text = nil
        authorLabel.text = nil
    }
}
