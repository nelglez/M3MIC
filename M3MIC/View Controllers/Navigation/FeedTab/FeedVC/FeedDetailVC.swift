//
//  FeedDetailVC.swift
//  M3MIC
//
//  Created by Brian Hersh on 7/8/19.
//  Copyright © 2019 Brian Daniel. All rights reserved.
//

import UIKit

class FeedDetailVC: UIViewController {
    
    // MARK: - Properties
    var toggleViewShowing = false
    
    var feedDetailMenuVC = FeedDetailMenuVC()
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var toggleViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var gifTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        fetchImages()
    }
    
    // MARK: - IBActions
    @IBAction func profileButtonTapped(_ sender: Any) {
        switch toggleViewShowing {
        case false:
            toggleViewTrailingConstraint.constant = 0
        case true:
            toggleViewTrailingConstraint.constant = -414
        }
        toggleViewShowing = !toggleViewShowing
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let replyVC = UIStoryboard(name: "Reply", bundle: nil).instantiateViewController(withIdentifier: "ReplyVC") as? ReplyVC else { return }
        navigationController?.pushViewController(replyVC, animated: true)
        
    }
    
    func updateViews() {
        loadViewIfNeeded()

        guard let post = post else { return }
        
        usernameLabel.text = post.username
        timestampLabel.text = Date(timeIntervalSince1970: post.timestamp).stringWith(dateStyle: .short, timeStyle: .short)
        profilePicture.image = #imageLiteral(resourceName: "PrimaryLogo")
        postLabel.text = post.message
    }
    
    func fetchImages() {
        
        ReplyController.shared.replies.removeAll()
        GifController.shared.gifReplyArray.removeAll()
        
        guard let postUID = post?.postUID else { print("No postUID found in \(#function)") ; return }
        
        ReplyController.shared.fetchAllRepliesFor(postUID: postUID, completion: { (error) in
            if let error = error {
                print("❌ Error found in \(#function) ; \(error.localizedDescription) ; \(error)")
            }
            GifController.shared.fetchGifsFromFSURLs(completion: { (success) in
                DispatchQueue.main.async {
                    if success {
                        print("Replies for \(postUID) complete")
                        self.gifTableView.reloadData()
                    }
                }
            })
        })
    }
}

// MARK: - TableView Methods
extension FeedDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GifController.shared.gifReplyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gifCell") as? FeedDetailCell
        let image = GifController.shared.gifReplyArray[indexPath.row]
        cell?.gifImage.image = image
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 255
    }
}

// MARK: - Prepare for Segue
extension FeedDetailVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReplyVC" {
            let destinationVC = segue.destination as? ReplyVC
            let post = self.post
            destinationVC?.post = post
        }
        
        if segue.identifier == "friendMenueVC" {
            let destinationVC = segue.destination as? FeedDetailMenuVC
            destinationVC?.delegate = self
            let post = self.post
            destinationVC?.post = post
        }
    }
}

// MARK: - FeedDetailMenuVCDelegate
extension FeedDetailVC: FeedDetailMenuVCDelegate {
    func dismissFeedDetailMenu(sender: FeedDetailMenuVC) {
        print("delegate responded")
        
        feedDetailMenuVC.dismissButtonTapped(self)
        
        toggleViewTrailingConstraint.constant = -414
        toggleViewShowing = !toggleViewShowing
    
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
