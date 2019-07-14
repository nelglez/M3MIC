//
//  PostController.swift
//  M3MIC
//
//  Created by Brian Hersh on 7/9/19.
//  Copyright © 2019 Brian Daniel. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

// TODO: - Listeners for Reply Likes and Rank

class PostController {
    
    // MARK: - Properties
    static let shared = PostController()
    private init(){}
    
    let db = UserController.shared.db
    
    var posts = [Post]()
    var postWasCreated = false
    
    // MARK: - CRUD Methods
    func createPostWith(message: String, timestamp: Date = Date(), replyUIDs: [String] = [], completion: @escaping(Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { completion(Errors.noCurrentUser) ; return }
        
        var ref: DocumentReference?
        ref = db.collection("Post").addDocument(data: [
            Document.userUID : currentUser.uid,
            Document.message : message,
            Document.timestamp : timestamp,
            Document.replyUIDs : replyUIDs
            ], completion: { (error) in
                if let error = error {
                    print("❌ Error adding document in \(#function) ; \(error.localizedDescription) ; \(error)")
                    completion(error) ; return
                }
                guard let docID = ref?.documentID else { completion(Errors.unwrapDocumentID) ; return }
                
                UserController.shared.updatePostUIDs(with: docID)
                print("Successfully created document with id: \(docID)")
                completion(nil)
        })
    }
    
    func fetchAllPosts(completion: @escaping(Error?) -> Void) {
        db.collection(Collection.Post).getDocuments { (snapshot, error) in
            if let error = error {
                print("❌ Error fetching documents in \(#function) ; \(error.localizedDescription) ; \(error)")
                completion(error) ; return
            }
            guard let snapshot = snapshot, snapshot.count >= 1 else { completion(Errors.snapshotGuard) ; return }
            
            self.posts = snapshot.documents.compactMap { Post(from: $0.data(), postUID: $0.documentID) }
            completion(nil)
        }
    }
}