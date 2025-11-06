//
//  MainOnboardingViewController.swift
//  Memora
//
//  Created by user@3 on 06/11/25.
//
import UIKit

class MainOnboardingViewController: UIViewController {

    // Connect these to storyboard
    @IBOutlet weak var containerView: UIView!            // the Container View that holds the page VC (optional to have)
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!             // optional

    // Reference to the embedded PageViewController
    weak var pageViewController: Onboardingv3PageViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // If you embedded via storyboard, the child page VC will be available at this point
        for child in children {
            if let pvc = child as? Onboardingv3PageViewController {
                pageViewController = pvc
                break
            }
        }

        // Setup initial UI
        pageControl.numberOfPages = pageViewController?.pages.count ?? 0
        pageControl.currentPage = pageViewController?.currentIndex ?? 0
        updateContinueButtonTitle()
    }

    // Continue tapped in the parent - hooked to the bottom static button
    @IBAction func continueTapped(_ sender: UIButton) {
        guard let pvc = pageViewController else { return }

        let nextIndex = pvc.currentIndex + 1
        if nextIndex < (pvc.pages.count) {
            pvc.setViewControllers([pvc.pages[nextIndex]], direction: .forward, animated: true) { finished in
                if finished {
                    pvc.currentIndex = nextIndex
                    self.pageControl.currentPage = nextIndex
                    self.animateContinueTitleChange()
                }
            }
        } else {
            // Last page -> finish onboarding
            finishedOnboarding()
        }
    }

    @IBAction func skipTapped(_ sender: UIButton) {
        guard let pvc = pageViewController else { return }
        let last = pvc.pages.count - 1
        pvc.setViewControllers([pvc.pages[last]], direction: .forward, animated: true) { finished in
            if finished {
                pvc.currentIndex = last
                self.pageControl.currentPage = last
                self.animateContinueTitleChange()
            }
        }
    }

    @IBAction func pageControlTapped(_ sender: UIPageControl) {
        guard let pvc = pageViewController else { return }
        let target = sender.currentPage
        let direction: UIPageViewController.NavigationDirection = (target > pvc.currentIndex) ? .forward : .reverse
        pvc.setViewControllers([pvc.pages[target]], direction: direction, animated: true) { _ in
            pvc.currentIndex = target
            self.animateContinueTitleChange()
        }
    }

    
    func finishedOnboarding() {
        let signup = AuthViewController(nibName: "AuthViewController", bundle: nil)
        navigationController?.pushViewController(signup, animated: true)
        // performSegue(withIdentifier: "goToHome", sender: self)
    }

    // Called when page control changes or swipe completes. The page VC should call this (see below).
    func pageDidChange(to index: Int) {
        pageControl.currentPage = index
        animateContinueTitleChange()
        
        if let pvc = pageViewController {
                skipButton.isHidden = (index == pvc.pages.count - 1)
            }
    }

    // Helper - sets Continue button title based on index
    func updateContinueButtonTitle() {
        guard let pvc = pageViewController else { return }
        if pvc.currentIndex == (pvc.pages.count - 1) {
            continueButton.setTitle("Let's Get Started", for: .normal)
        } else {
            continueButton.setTitle("Continue", for: .normal)
        }
    }

    func animateContinueTitleChange() {
        UIView.transition(with: continueButton, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.updateContinueButtonTitle()
        }, completion: nil)
    }
}
