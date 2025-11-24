//
//  CategoryDetailsViewController.swift
//  Home
//
//  Created by user@3 on 11/11/25.
//

import UIKit

final class CategoryDetailsViewController: UIViewController {

    // MARK: - Outlets (connect the table view in your XIB)
    @IBOutlet private weak var tableView: UITableView!


    private let category: Category
     private var prompts: [DetailedPrompt] = []

     // MARK: - Init
     init(category: Category) {
         self.category = category
         super.init(nibName: "CategoryDetailsViewController", bundle: nil)
         modalPresentationStyle = .fullScreen
     }

     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }

     // MARK: - Lifecycle
     override func viewDidLoad() {
         super.viewDidLoad()

         // use the soft app background to match Figma outer area
         view.backgroundColor = UIColor.systemGray6

         setupNavigationBar()
         setupTableView()
         loadPrompts()
     }

     // MARK: - Navigation Bar
     private func setupNavigationBar() {
         navigationItem.title = category.title
         navigationItem.leftBarButtonItem = UIBarButtonItem(
             image: UIImage(systemName: "chevron.left"),
             style: .plain,
             target: self,
             action: #selector(onBack)
         )

         if #available(iOS 15.0, *) {
             let appearance = UINavigationBarAppearance()
             appearance.configureWithTransparentBackground()
             appearance.backgroundColor = .clear
             navigationController?.navigationBar.standardAppearance = appearance
             navigationController?.navigationBar.scrollEdgeAppearance = appearance
         }
     }

     // Works whether pushed or presented modally
     @objc private func onBack() {
         if let nav = navigationController, nav.viewControllers.count > 1 {
             nav.popViewController(animated: true)
         } else if presentingViewController != nil {
             dismiss(animated: true)
         } else {
             // fallback
             navigationController?.popViewController(animated: true)
         }
     }

     // MARK: - Table Setup
     private func setupTableView() {
         // make sure tableView is hooked up in the XIB
         guard let tv = tableView else {
             assertionFailure("tableView outlet not connected — check CategoryDetails.xib")
             return
         }

         tv.dataSource = self
         tv.delegate = self

         // background / scroll behavior
         tv.backgroundColor = .clear                    // table background transparent so outer view shows
         tv.showsVerticalScrollIndicator = false        // hide native scroll bar as requested
         tv.separatorStyle = .none

         // register cell nib (keep your XIB filename and reuse identifier matching)
         let nib = UINib(nibName: "CategoryPromptTableViewCell", bundle: .main)
         tv.register(nib, forCellReuseIdentifier: "CategoryPromptTableViewCell")

         // dynamic sizing
         tv.estimatedRowHeight = 360
         tv.rowHeight = UITableView.automaticDimension

         // small top/bottom padding so first/last cell aren't hugging nav or bottom
         tv.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 24, right: 0)
     }

     private func loadPrompts() {
         // use your DetailedPromptData filter helper
         prompts = DetailedPromptData.prompts(forCategorySlug: category.slug)
         tableView.reloadData()
     }
 }

 // MARK: - UITableViewDataSource
 extension CategoryDetailsViewController: UITableViewDataSource {
     // changed to use one prompt per section so we can add spacing (footer) between "cards"
     func numberOfSections(in tableView: UITableView) -> Int {
         return prompts.count
     }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
     }

     func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tv.dequeueReusableCell(withIdentifier: "CategoryPromptTableViewCell", for: indexPath)
                 as? CategoryPromptTableViewCell else {
             return UITableViewCell()
         }

         let prompt = prompts[indexPath.section]
         // the design shows the short description under image; set accordingly
         cell.titleLabel.text = prompt.text
         cell.promptImageView.image = nil

         cell.promptImageView.contentMode = .scaleAspectFill
         cell.promptImageView.clipsToBounds = true
         cell.promptImageView.setImage(from: prompt.imageURL, placeholder: UIImage(systemName: "photo"))

         // Visual tweaks: make cell background clear so the card design in your XIB shows
         cell.backgroundColor = .clear
         cell.contentView.backgroundColor = .clear
         cell.selectionStyle = .none

         return cell
     }
 }

 // MARK: - UITableViewDelegate
 extension CategoryDetailsViewController: UITableViewDelegate {

     // Footer acts as the vertical spacing between cards
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
         return 35 // <-- the 35pt spacing you requested
     }

     func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
         // clear view for spacing
         let v = UIView()
         v.backgroundColor = .clear
         return v
     }

     // optional: small top & bottom padding per section (if you prefer cell-insets)
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 0.0
     }

     func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
         tv.deselectRow(at: indexPath, animated: true)

         // get the tapped DetailedPrompt
         let selected = prompts[indexPath.section]

         // Convert DetailedPrompt -> Prompt
         // NOTE: adjust this initializer if your `Prompt` type expects different parameters.
         let promptModel = Prompt(
             iconName: selected.imageURL ?? "",
             text: selected.text,
             category: selected.categorySlug
         )

         // Create detail VC and present (push if in nav stack, otherwise modal full screen)
         let detailVC = PromptDetailViewControllerSimple(prompt: promptModel)
         if let nav = navigationController {
             nav.pushViewController(detailVC, animated: true)
         } else {
             let nav = UINavigationController(rootViewController: detailVC)
             nav.modalPresentationStyle = .fullScreen
             present(nav, animated: true)
         }
     }
 }
