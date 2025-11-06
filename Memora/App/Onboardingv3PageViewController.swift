//
//  Onboardingv3PageViewController.swift
//  Memora
//
//  Created by user@3 on 06/11/25.
//
import UIKit

class Onboardingv3PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    // keep these identifiers in storyboard for each child VC
    lazy var pages: [UIViewController] = {
        return [
            storyboard!.instantiateViewController(withIdentifier: "Screen1v3ViewController"),
            storyboard!.instantiateViewController(withIdentifier: "Screen2v3ViewController"),
            storyboard!.instantiateViewController(withIdentifier: "Screen3v3ViewController"),
            storyboard!.instantiateViewController(withIdentifier: "Screen4v3ViewController"),
        ]
    }()

    var currentIndex = 0 {
        didSet {
            // inform parent (if it exists) that page changed
            if let parent = parent as? MainOnboardingViewController {
                parent.pageDidChange(to: currentIndex)
            }
        }
    }

    let customPageControl = UIPageControl() // we won't show this if parent uses its own, but you can remove it

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        if !pages.isEmpty {
            setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
            currentIndex = 0
        }
    }

    // Public method parent can call to jump to next (optional)
    func goToNextPage() {
        if currentIndex < pages.count - 1 {
            let nextIndex = currentIndex + 1
            setViewControllers([pages[nextIndex]], direction: .forward, animated: true) { finished in
                if finished {
                    self.currentIndex = nextIndex
                }
            }
        } else {
            // done
        }
    }

    // MARK: UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx > 0 else { return nil }
        return pages[idx - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx < pages.count - 1 else { return nil }
        return pages[idx + 1]
    }

    // MARK: UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visible = viewControllers?.first, let idx = pages.firstIndex(of: visible) {
            currentIndex = idx
        }
    }
}
