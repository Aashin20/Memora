import UIKit

final class MemoryContainerViewController: UIViewController {
    private var homeFromXib: MemoryViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        embedHomeXIB()
    }

    private func embedHomeXIB() {
        let memory = MemoryViewController(nibName: "MemoryViewController", bundle: nil)
        addChild(memory)
        view.addSubview(memory.view)
        memory.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            memory.view.topAnchor.constraint(equalTo: view.topAnchor),
            memory.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            memory.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            memory.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        memory.didMove(toParent: self)
        self.homeFromXib = memory
    }
}
