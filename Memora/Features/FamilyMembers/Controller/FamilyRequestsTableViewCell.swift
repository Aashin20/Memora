//
//  FamilyRequestsTableViewCell.swift
//  Memora
//
//  Created by user@3 on 12/11/25.
//

import UIKit

class FamilyRequestsTableViewCell: UITableViewCell {

    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let approveButton = UIButton(type: .system)
    let rejectButton = UIButton(type: .system)

    var approveAction: (() -> Void)?
    var rejectAction: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        
        nameLabel.font = .boldSystemFont(ofSize: 16)
        emailLabel.font = .systemFont(ofSize: 14)
        emailLabel.textColor = .gray
        
        approveButton.setTitle("Approve", for: .normal)
        approveButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        approveButton.layer.cornerRadius = 6
        
        rejectButton.setTitle("Reject", for: .normal)
        rejectButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
        rejectButton.layer.cornerRadius = 6
        
        approveButton.addTarget(self, action: #selector(handleApprove), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(handleReject), for: .touchUpInside)

        // Add UI elements
        [nameLabel, emailLabel, approveButton, rejectButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // ✅ Updated Constraints — SIDE-BY-SIDE buttons
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            approveButton.trailingAnchor.constraint(equalTo: rejectButton.leadingAnchor, constant: -10),
            approveButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            approveButton.widthAnchor.constraint(equalToConstant: 80),
            approveButton.heightAnchor.constraint(equalToConstant: 32),
            
            rejectButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rejectButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rejectButton.widthAnchor.constraint(equalToConstant: 80),
            rejectButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc func handleApprove() {
        approveAction?()
    }
    
    @objc func handleReject() {
        rejectAction?()
    }
}
