//
//  GalleryView.swift
//  AWSPhotoAlbum
//
//  Created by Emma Olthof on 14/01/2021.
//

import Foundation
import UIKit
import Amplify
import Combine

class GalleryView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imageCache = [String: UIImage?]()
    var token: AnyCancellable?
    var publisher: AnyPublisher<MutationEvent, DataStoreError>?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        getPost()
        observePosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        observePosts()
        DispatchQueue.main.async {
            self.photoCollection.reloadData()
        }
    }
    
    // MARK: - AWS Amplify GraphQL - Subscriber methods
    /****************************************************************************************************************************//**
    ** \brief      Function to query data from the datastore and call downloadImages() func when query succeeded.
    ********************************************************************************************************************************/
    func getPost() {
        Amplify.DataStore.query(Post.self) { result in
            switch result {
            case .success(let posts):
                // download images
                downloadImages(for: posts, completion: handleDownloadImages(succeed:))
                
                ////TESTING////************************************************************
//                downloadImages(for: posts, completion: CameraView().handleDownloadImages(data:error:))
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.messageAlert(firstLine: "Failed", alertMessage: "Could not get images from backend.")
                }
            }
        }
    }
    
    /****************************************************************************************************************************//**
    ** \brief      Function to download Post from AWS S3 bucket / storage and add the data to imageCache dictionary.
    ** \param   The function takes parameter from getPost with the Post data.
    ********************************************************************************************************************************/
    func downloadImages(for posts: [Post], completion: @escaping (Bool) -> Void) {
        print("nr of posts: \(posts.count)")
        guard posts.count >= 1 else {
            completion(true)
            return
        }
        for post in posts {
            _ = Amplify.Storage.downloadData(key: post.imageKey) { result in
                switch result {
                case .success(let imageData):
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        self.imageCache[post.imageKey] = image
                        self.photoCollection.reloadData()
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                    }
                case .failure(let error):
                    print("Failed to download image data: \(error)")
                    DispatchQueue.main.async {
                        self.messageAlert(firstLine: "Failed", alertMessage: "Could not download images from backend.")
                    }
                }
            }
        }
    }
    
    ////TESTING////************************************************************
//    func downloadImages(for posts: [Post], completion: @escaping ([Data], Error?) -> Void) {
//        print("nr of posts: \(posts.count)")
//        guard posts.count >= 1 else {
//            return
//        }
//        for post in posts {
//            _ = Amplify.Storage.downloadData(key: post.imageKey) { result in
//                switch result {
//                case .success(let imageData):
//                    print("downloadImages() imageData: \(imageData.debugDescription)")
//                    print("downloadImages() imageData: \(post.imageKey)")
//                    completion([imageData], nil)
////                    let image = UIImage(data: imageData)
////                    DispatchQueue.main.async {
////                        self.imageCache[post.imageKey] = image
////                        self.photoCollection.reloadData()
////                        self.activityIndicator.isHidden = true
////                        self.activityIndicator.stopAnimating()
////                    }
//                case .failure(let error):
//                    print("Failed to download image data: \(error)")
//                    completion([],error)
//                }
//            }
//        }
//    }
    ////TESTING////************************************************************
    
    //-------------------------------------------------------------------------------------
    func handleDownloadImages(succeed: Bool) {
        if succeed {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.messageAlert(firstLine: "No Photos Present", alertMessage: "There aren't any photos. You haven't saved your photos to the backend yet.")
            }
        }
    }
    
    /****************************************************************************************************************************//**
    ** \brief      Function to delete the chosen image from Datastore the observePosts function keeps track and synchronize with AWS appsync within AWS S3 storage
            and DynamoDB table.
    ** \param   Parameter is given by the collectionview; the selected cell.
    ********************************************************************************************************************************/
    func deleteImage(photoId: String) {
        Amplify.DataStore.query(Post.self,
                                where: Post.keys.imageKey.eq(photoId)) { result in
                switch(result) {
                case .success(let posts):
                    guard posts.count == 1, let deletePost = posts.first else {
                        print("Did not find exactly one post, bailing")
                        return
                    }
                    Amplify.DataStore.delete(deletePost) { result in
                        switch(result) {
                        case .success:
                            print("Deleted Post: \(deletePost)")
                        case .failure(let error):
                            print("Could not update data in Datastore: \(error)")
                            DispatchQueue.main.async {
                                self.messageAlert(firstLine: "Failed to Delete", alertMessage: "Could not delete images from backend.")
                            }
                        }
                    }
                case .failure(let error):
                    print("Could not query DataStore: \(error)")
                    DispatchQueue.main.async {
                        self.messageAlert(firstLine: "Failed to Fetch", alertMessage: "Could not query data from backend.")
                    }
                }
           }
    }

    /****************************************************************************************************************************//**
    ** \brief      Function to keep track of events within the app. CRUD events that need to be synchronized with the AWS backend. Also see variables at top.
    ********************************************************************************************************************************/
    func observePosts() {
        self.token = Amplify.DataStore.publisher(for: Post.self)
            // token hangs on to the sink of the publisher
            .sink(receiveCompletion: { print("Subscription has been completed: \($0)") },
            receiveValue: { mutationEvent in
                print("Subscription got this value: \(mutationEvent)")
                do {
                    let post = try mutationEvent.decodeModel(as: Post.self)

                    switch mutationEvent.mutationType {
                    case "create":
                        print("Created: \(post)")
                        self.downloadImages(for: [post], completion: self.handleDownloadImages(succeed:))
                        
                        ////TESTING////************************************************************
//                        self.downloadImages(for: [post], completion: CameraView().handleDownloadImages(data:error:))
                    case "update":
                        print("Updated: \(post)")
                    case "delete":
                        print("Deleted: \(post)")
                    default:
                        break
                    }
                } catch {
                    print("Model could not be decoded: \(error)")
                }
            })
    }
    
    // MARK: - UICollectionView methods
    /****************************************************************************************************************************//**
    ** \brief      3 Functions for displaying the CollectionView with all the images from AWS S3 storage and for deleting an image by tapping on it.
    ********************************************************************************************************************************/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCache.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let gallery = [UIImage?](imageCache.values)[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        cell.setImage(collectionImage: gallery)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedCell = photoCollection.indexPathsForSelectedItems {
            for image in selectedCell {
                let photoK = [String](imageCache.keys)[image.item]
                deleteImage(photoId: photoK)
                self.imageCache.removeValue(forKey: photoK)
                DispatchQueue.main.async {
                    self.photoCollection.reloadData()
                }
            }
        }
    }
    
    // MARK: - UIAlertController method
    /****************************************************************************************************************************//**
    ** \brief      Function to handle the alert dispaying it to the user when an error occures.
    ** \param   The function takes a title and message for the alert.
    ********************************************************************************************************************************/
    func messageAlert(firstLine: String, alertMessage: String) {
        let alert = UIAlertController(title: firstLine, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
        }))
        present(alert, animated: true, completion: nil)
   }
    
    
}
