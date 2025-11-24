import UIKit

final class HomeContainerViewController: UIViewController {
    private var homeFromXib: HomeViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        embedHomeXIB()
    }

    private func embedHomeXIB() {
        let home = HomeViewController(nibName: "HomeViewController", bundle: nil)
        addChild(home)
        view.addSubview(home.view)
        home.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            home.view.topAnchor.constraint(equalTo: view.topAnchor),
            home.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            home.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            home.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        home.didMove(toParent: self)
        self.homeFromXib = home
    }
}
