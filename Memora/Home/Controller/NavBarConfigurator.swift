import UIKit

// MARK: - Navigation bar helper (single function to call)
final class NavBarHelpers {

    /// Call from viewDidLoad of your HomeViewController:
    /// NavBarHelpers.configureLargeNav(for: self, title: "Home")
    static func configureLargeNav(for vc: UIViewController, title: String, avatarSize: CGFloat = 40) {
        guard let nav = vc.navigationController else {
            // If not embedded in a navigation controller, nothing to do.
            return
        }

        // Make sure nav bar is visible
        nav.setNavigationBarHidden(false, animated: false)

        // Large title
        nav.navigationBar.prefersLargeTitles = true
        vc.navigationItem.largeTitleDisplayMode = .always
        vc.title = title

        // Appearance - match background to vc.view (so it looks like a native large title screen)
        let bgColor = vc.view.backgroundColor ?? .systemBackground
        let largeFont = UIFont.systemFont(ofSize: 34, weight: .heavy)
        let smallFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = bgColor

            appearance.largeTitleTextAttributes = [
                .font: largeFont,
                .foregroundColor: UIColor.label
            ]
            appearance.titleTextAttributes = [
                .font: smallFont,
                .foregroundColor: UIColor.label
            ]

            nav.navigationBar.standardAppearance = appearance
            nav.navigationBar.scrollEdgeAppearance = appearance
            nav.navigationBar.compactAppearance = appearance
        } else {
            // Fallback for older iOS
            nav.navigationBar.barTintColor = bgColor
            nav.navigationBar.titleTextAttributes = [.font: smallFont]
            nav.navigationBar.largeTitleTextAttributes = [.font: largeFont]
        }

        // Make nav bar translucent so large title sits visually on the same background if needed
        nav.navigationBar.isTranslucent = true

        // Create a fixed-size container (important so Auto Layout doesn't collapse)
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: avatarSize),
            container.heightAnchor.constraint(equalToConstant: avatarSize)
        ])

        // Image view (circular avatar)
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = avatarSize / 2
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true

        // Load avatar from Session if present, else show person symbol
        if let name = Session.shared.currentUser.avatarName,
           let img = UIImage(named: name) {
            imageView.image = img
        } else {
            let cfg = UIImage.SymbolConfiguration(pointSize: avatarSize * 0.5, weight: .regular)
            imageView.image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: cfg)
            imageView.tintColor = .gray
            imageView.backgroundColor = .clear
            imageView.contentMode = .scaleAspectFill
        }

        container.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // Tap gesture (calls vc.navAvatarTapped() if implemented)
        let tap = UITapGestureRecognizer(target: AvatarTarget(targetVC: vc), action: #selector(AvatarTarget.didTap(_:)))
        imageView.addGestureRecognizer(tap)

        // Put container in right bar button item
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: container)
    }

    // small helper target to avoid leaking VC from gesture
    private final class AvatarTarget: NSObject {
        weak var targetVC: UIViewController?
        init(targetVC: UIViewController) { self.targetVC = targetVC }

        @objc func didTap(_ sender: UITapGestureRecognizer) {
            if let vc = targetVC {
                // call optional selector on VC if they override it
                if vc.responds(to: #selector(UIViewController.navAvatarTapped)) {
                    vc.perform(#selector(UIViewController.navAvatarTapped))
                } else {
                    // default fallback action
                    let a = UIAlertController(title: "Avatar tapped", message: nil, preferredStyle: .actionSheet)
                    a.addAction(UIAlertAction(title: "OK", style: .cancel))
                    vc.present(a, animated: true)
                }
            }
        }
    }
}

// make it easy to override behavior in your view controllers
extension UIViewController {
    /// Override in your controller if you want a custom avatar action
    @objc func navAvatarTapped() { }
}
