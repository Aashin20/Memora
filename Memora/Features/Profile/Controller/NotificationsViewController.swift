//
//  NotificationsViewController.swift
//  Memora
//
//  Created by user@3 on 12/11/25.
//

import UIKit

class NotificationsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var dailyReminderView: UIView!
    @IBOutlet weak var dailyReminderLabel: UILabel!
    @IBOutlet weak var dailyReminderSwitch: UISwitch!
    @IBOutlet weak var dailyReminderDescLabel: UILabel!
    
    @IBOutlet weak var familyPostsView: UIView!
    @IBOutlet weak var familyPostsLabel: UILabel!
    @IBOutlet weak var familyPostsSwitch: UISwitch!
    @IBOutlet weak var familyPostsDescLabel: UILabel!
    
    @IBOutlet weak var familyReactionsView: UIView!
    @IBOutlet weak var familyReactionsLabel: UILabel!
    @IBOutlet weak var familyReactionsSwitch: UISwitch!
    @IBOutlet weak var familyReactionsDescLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notifications"
        view.backgroundColor = UIColor.systemGray6
        setupCardViews()
        setupLabels()
    }
    
    private func setupCardViews() {
        // Round white background cards like on Account page
        let cards = [dailyReminderView, familyPostsView, familyReactionsView]
        for card in cards {
            card?.backgroundColor = .white
            card?.layer.cornerRadius = 22
            card?.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
            card?.layer.shadowOffset = CGSize(width: 0, height: 2)
            card?.layer.shadowOpacity = 0.2
            card?.layer.shadowRadius = 4
        }
    }
    
    private func setupLabels() {
        // Subtle text styling for consistency
        dailyReminderLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        familyPostsLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        familyReactionsLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        let descLabels = [dailyReminderDescLabel, familyPostsDescLabel, familyReactionsDescLabel]
        for desc in descLabels {
            desc?.textColor = .secondaryLabel
            desc?.font = UIFont.systemFont(ofSize: 15)
            desc?.numberOfLines = 0
        }
    }
}
