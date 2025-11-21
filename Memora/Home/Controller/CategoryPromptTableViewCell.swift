import UIKit

class CategoryPromptTableViewCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var promptImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView! // optional

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        // Card appearance (shadow)
        cardView.layer.cornerRadius = 24
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        cardView.layer.shadowRadius = 16

        // Image rounding (rounded top corners only)
        promptImageView.layer.cornerRadius = 18
        promptImageView.clipsToBounds = true
        if #available(iOS 11.0, *) {
            promptImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        promptImageView.contentMode = .scaleAspectFill
    }

    func configure(title: String, image: UIImage?) {
        titleLabel.text = title
        promptImageView.image = image
    }

    // If you want to load from URL, call an async loader from cellForRow (avoid heavy work here)
}
