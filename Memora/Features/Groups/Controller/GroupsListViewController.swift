import UIKit

class GroupsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addGroupButton: UIButton!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var emptyStateImage: UIImageView!
    
    private var groups: [UserGroup] = []
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemGray6
        setupTableView()
        setupFloatingButton()
        setupEmptyState()
        
        // Debug: Add test action
        addGroupButton.addTarget(self, action: #selector(debugButtonPress), for: .touchUpInside)
        
        // Listen for refresh notifications
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(refreshGroups),
                                             name: NSNotification.Name("GroupsListShouldRefresh"),
                                             object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGroups()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure button stays circular after layout changes
        addGroupButton.layer.cornerRadius = addGroupButton.frame.width / 2
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "GroupsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "GroupCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = 84
        
        // Add refresh control
        refreshControl.addTarget(self, action: #selector(refreshGroups), for: .valueChanged)
        refreshControl.tintColor = .systemBlue
        tableView.refreshControl = refreshControl
    }
    
    private func setupFloatingButton() {
        // Set button to perfect circle
        addGroupButton.layer.cornerRadius = addGroupButton.frame.width / 2
        addGroupButton.clipsToBounds = true
        addGroupButton.backgroundColor = .systemBlue
        
        // Configure plus icon
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let plusImage = UIImage(systemName: "plus", withConfiguration: config)
        addGroupButton.setImage(plusImage, for: .normal)
        addGroupButton.tintColor = .white
        
        // Shadow
        addGroupButton.layer.shadowColor = UIColor.black.cgColor
        addGroupButton.layer.shadowOpacity = 0.3
        addGroupButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addGroupButton.layer.shadowRadius = 8
        addGroupButton.layer.masksToBounds = false
        
        // Ensure button is on top
        addGroupButton.layer.zPosition = 1000
    }
    
    private func setupEmptyState() {
        emptyStateView.isHidden = true
        emptyStateImage.image = UIImage(systemName: "person.3.fill")
        emptyStateImage.tintColor = .systemGray3
        emptyStateLabel.text = "No groups yet\nCreate or join a group to get started"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
    }
    
    @objc private func debugButtonPress() {
        print("DEBUG: Button pressed at \(Date())")
    }
    
    @objc private func refreshGroups() {
        loadGroups()
    }
    
    private func loadGroups() {
        print("Loading groups...")
        
        Task {
            do {
                let fetchedGroups = try await SupabaseManager.shared.getMyGroups()
                print("Successfully fetched \(fetchedGroups.count) groups")
                
                DispatchQueue.main.async {
                    self.groups = fetchedGroups
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.emptyStateView.isHidden = !self.groups.isEmpty
                    
                    // Debug: Print groups
                    for group in self.groups {
                        print("Group: \(group.name), Code: \(group.code), Admin: \(group.adminId)")
                    }
                }
            } catch {
                print("Error fetching groups: \(error)")
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func addGroupPressed(_ sender: UIButton) {
        print("addGroupPressed called - showing action sheet")
        
        // Create and present the action sheet
        let actionSheet = GroupActionSheetViewController()
        actionSheet.delegate = self
        
        // IMPORTANT: Use overFullScreen to cover everything including tab bar
        actionSheet.modalPresentationStyle = .overFullScreen
        actionSheet.modalTransitionStyle = .crossDissolve
        
        // Present from self (since we're in a tab controller)
        self.present(actionSheet, animated: true) {
            print("Action sheet presented successfully")
        }
    }
    
    // Helper to get topmost view controller
    private func getTopViewController() -> UIViewController? {
        var topController: UIViewController? = self
        
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        
        // If we're in a tab bar controller, return self
        if topController != self {
            return topController
        }
        return self
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension GroupsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "GroupCell",
            for: indexPath
        ) as! GroupsTableViewCell
        
        let group = groups[indexPath.row]
        
        // Check if current user is admin
        let isAdmin = group.adminId == SupabaseManager.shared.getCurrentUserId()
        
        // Configure cell with admin badge if user is admin
        cell.configure(
            title: group.name,
            subtitle: "Code: \(group.code)",
            image: UIImage(named: "group_family"), // Use appropriate image
            isAdmin: isAdmin
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let group = groups[indexPath.row]
        let vc = GroupDetailViewController(group: group)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let group = groups[indexPath.row]
        
        // Only allow admin to delete group
        if group.adminId == SupabaseManager.shared.getCurrentUserId() {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
                self?.confirmDeleteGroup(group: group, at: indexPath)
                completion(true)
            }
            deleteAction.backgroundColor = .systemRed
            
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        let leaveAction = UIContextualAction(style: .destructive, title: "Leave") { [weak self] _, _, completion in
            self?.confirmLeaveGroup(group: group, at: indexPath)
            completion(true)
        }
        leaveAction.backgroundColor = .systemOrange
        
        return UISwipeActionsConfiguration(actions: [leaveAction])
    }
    
    private func confirmDeleteGroup(group: UserGroup, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete Group",
            message: "Are you sure you want to delete '\(group.name)'? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteGroup(group: group, at: indexPath)
        })
        
        present(alert, animated: true)
    }
    
    private func confirmLeaveGroup(group: UserGroup, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Leave Group",
            message: "Are you sure you want to leave '\(group.name)'?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive) { [weak self] _ in
            self?.leaveGroup(group: group, at: indexPath)
        })
        
        present(alert, animated: true)
    }
    
    private func deleteGroup(group: UserGroup, at indexPath: IndexPath) {
        Task {
            do {
                try await SupabaseManager.shared.deleteGroup(groupId: group.id)
                
                DispatchQueue.main.async {
                    self.groups.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.emptyStateView.isHidden = !self.groups.isEmpty
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func leaveGroup(group: UserGroup, at indexPath: IndexPath) {
        guard let userId = SupabaseManager.shared.getCurrentUserId() else { return }
        
        Task {
            do {
                try await SupabaseManager.shared.removeGroupMember(groupId: group.id, userId: userId)
                
                DispatchQueue.main.async {
                    self.groups.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.emptyStateView.isHidden = !self.groups.isEmpty
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - GroupActionSheetDelegate
extension GroupsListViewController: GroupActionSheetDelegate {
    func didSelectCreateGroup() {
        print("Create group selected")
        let createVC = CreateGroupViewController(nibName: "CreateGroupViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: createVC)
        nav.modalPresentationStyle = .pageSheet
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(nav, animated: true)
    }
    
    func didSelectJoinGroup() {
        print("Join group selected")
        let joinVC = JoinGroupModalViewController(nibName: "JoinGroupModalViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: joinVC)
        nav.modalPresentationStyle = .pageSheet
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(nav, animated: true)
    }
}
