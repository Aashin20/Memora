//
//  OnboardingViewController.swift
//  Memory
//
//  Created by user@3 on 05/11/25.
//

import UIKit

class OnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
                let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)

                // No need for if-let since it returns non-optional
                let featureListVC = storyboard.instantiateViewController(withIdentifier: "FeatureListViewController")

                featureListVC.modalTransitionStyle = .crossDissolve
                featureListVC.modalPresentationStyle = .fullScreen
                present(featureListVC, animated: true)
    }
}
