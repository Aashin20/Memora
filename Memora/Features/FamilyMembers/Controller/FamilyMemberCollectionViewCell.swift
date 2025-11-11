//
//  FamilyMemberCollectionViewCell.swift
//  Memora
//
//  Created by user@3 on 10/11/25.
//

import UIKit

class FamilyMemberCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var MemberImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }

    private func setupAppearance() {

        // --- Round Image ---
        MemberImageView.clipsToBounds = true
        MemberImageView.contentMode = .scaleAspectFill
        MemberImageView.layer.cornerRadius = 20   // smooth rounded image everywhere

        // --- Card Background ---
        contentView.layer.cornerRadius = 50       // rounded card edges
        contentView.layer.masksToBounds = true    // ensures content respects rounded corner

        // Optional subtle shadow
        layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 1
        layer.masksToBounds = false
    }

    func configure(name: String, image: UIImage?) {
        MemberImageView.image = image
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        MemberImageView.image = nil
    }
}
