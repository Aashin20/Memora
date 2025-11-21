//
//  ExploreMoreCollectionViewCell.swift
//  Home
//

import UIKit

final class ExploreMoreCollectionViewCell: UICollectionViewCell {
    static let reuseId = "ExploreMoreCollectionViewCell"

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var promptImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        setupCard()
    }

    private func setupCard() {
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 22
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowRadius = 16
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)

        promptImageView.layer.cornerRadius = 18
        promptImageView.clipsToBounds = true
        if #available(iOS 11.0, *) {
            promptImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        promptImageView.contentMode = .scaleAspectFill

        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        promptImageView.cancelImageLoad()
        promptImageView.image = nil
        titleLabel.text = nil
    }

    func configure(with prompt: DetailedPrompt) {
        titleLabel.text = prompt.text
        promptImageView.setImage(from: prompt.imageURL, placeholder: UIImage(systemName: "photo"))
    }
}
