//
//  FamilyMemberViewController.swift
//  Memora
//
//  Created by user@3 on 10/11/25.
//

import UIKit

class FamilyMemberViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var membersCollectionView: UICollectionView!
    @IBOutlet weak var postsCollectionView: UICollectionView!

    @IBOutlet weak var ProfilePic: UIImageView!
    
    // MARK: - Dummy Data
    let members: [(name: String, imageName: String)] = [
        ("John", "Window"),
        ("Peter", "Window-1"),
        ("Raqual", "Window-2")
    ]

    let posts: [(prompt: String, author: String, imageName: String)] = [
        ("Birthday Celebration", "Mom", "Window-1"),
        ("Trip to Goa", "Dad", "Window-2"),
        ("Graduation Day", "Peter", "Window")
    ]

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMembersCollection()
        setupPostsCollection()
        
        // ✅ Make Profile Pic circular
        ProfilePic.clipsToBounds = true
        ProfilePic.contentMode = .scaleAspectFill
    }

    // ✅ Ensures perfect circular shape after layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ProfilePic.layer.cornerRadius = ProfilePic.frame.height / 2
    }

    // MARK: - Members Collection Setup
    private func setupMembersCollection() {
        let nib = UINib(nibName: "FamilyMemberCollectionViewCell", bundle: nil)
        membersCollectionView.register(nib, forCellWithReuseIdentifier: "FamilyMemberCell")

        membersCollectionView.delegate = self
        membersCollectionView.dataSource = self

        if let layout = membersCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 12
            layout.itemSize = CGSize(width: 140, height: 190)
        }
    }

    // MARK: - Posts Collection Setup
    private func setupPostsCollection() {
        let nib = UINib(nibName: "FamilyMemoriesCollectionViewCell", bundle: nil)
        postsCollectionView.register(nib, forCellWithReuseIdentifier: "FamilyMemoriesCell")

        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self

        if let layout = postsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 15
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 220)
        }
    }
    
    @IBAction func FamilyMemberPressed(_ sender: UIButton) {
        let FamilyList = FamilyMemberListViewController(nibName: "FamilyMemberListViewController", bundle: nil)
        navigationController?.pushViewController(FamilyList, animated: true)
    }
}

// MARK: - CollectionView Delegate & DataSource
extension FamilyMemberViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == membersCollectionView ? members.count : posts.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == membersCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FamilyMemberCell",
                                                          for: indexPath) as! FamilyMemberCollectionViewCell

            let member = members[indexPath.item]
            let image = UIImage(named: member.imageName)
            cell.configure(name: member.name, image: image)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FamilyMemoriesCell",
                                                          for: indexPath) as! FamilyMemoriesCollectionViewCell

            let post = posts[indexPath.item]
            let img = UIImage(named: post.imageName)
            cell.configure(prompt: post.prompt, author: post.author, image: img)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == membersCollectionView {
            print("Tapped Member:", members[indexPath.item].name)
        } else {
            print("Tapped Post:", posts[indexPath.item].prompt)
        }
    }
}
