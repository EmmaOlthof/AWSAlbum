//
//  CameraView.swift
//  AWSPhotoAlbum
//
//  Created by Emma Olthof on 14/01/2021.
//

import UIKit
import Amplify

class CameraView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var shouldShowImagePicker = false
    var custButton = CustomButton().button
    let imagePicker = UIImagePickerController()
    
    // MARK: - Lifecycle
    /*********************************************************************************************************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        imagePicker.delegate = self
        setImageButton(imageName: "icon-camera-white")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    ////TESTING////************************************************************
//    func handleDownloadImages(data: [Data], error: Error?) {
//        if data.count > 0 {
//            DispatchQueue.main.async {
//                self.activityIndicator.stopAnimating()
//                self.activityIndicator.isHidden = true
//                self.messageAlert(firstLine: "No Photos Present", alertMessage: "There aren't any photos. You haven't saved your photos to the backend yet.")
//            }
//        } else {
//            print("Could not download product images")
//        }
//    }
    ////TESTING////************************************************************
    
    // MARK: - Closure Amplify Configuration
    /****************************************************************************************************************************//**
    ** \brief      Function to handle the closure from function BackendConfig for handling the error when it occures and displays it to the user.
    ** \param   Completion handler with bool and error as parameter.
    ********************************************************************************************************************************/
    func handleAmplifyConfig(succeed: Bool, error: Error?) {
        if succeed {
            print("handleAmplifyConfig() succeeded")
        } else {
            DispatchQueue.main.async {
                self.messageAlert(firstLine: "Error", alertMessage: "Could not connect to PhotoAlbum backend. Unable to use this app now. Try again later.")
            }
        }
    }
    
    // MARK: - UIButton
    /****************************************************************************************************************************//**
    ** \brief      Function to set the costumized button when calling the imagePicker or uploading the chosen image.
    ** \param   ImageName is the name of the image to display within the button.
    ********************************************************************************************************************************/
    func setImageButton(imageName: String) {
        let image = UIImage(named: imageName)
        custButton.setImage(image, for: .normal)
        
        view.addSubview(custButton)
        custButton.center = view.center
    }
    
    /****************************************************************************************************************************//**
    ** \brief      An @objc function linked to the custom button and for showing the imagePicker OR uploading the chosen image.
    ** \param   Parameter is the custom button with all it's settings.
    ********************************************************************************************************************************/
    @objc func buttonPressed(_ sender: CustomButton) {
        if let image = self.imageView.image {
            //upload image
            upload(image)
        } else {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            shouldShowImagePicker.toggle()

            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - AWS Amplify - GraphQL methods
    /****************************************************************************************************************************//**
    ** \brief      Function to create an image and an uuid for uploading to the AWS S3 storage. It also calles the save() function.
    ** \param   The function takes an image from buttonPressed().
    ********************************************************************************************************************************/
    func upload(_ image: UIImage) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let key = UUID().uuidString + ".jpg"
        
        _ = Amplify.Storage.uploadData(key: key, data: imageData) { result in
            switch result {
            case .success:
                print("key uploaded image: \(key)")
                //save image to a post
                let post = Post(imageKey: key)
                self.save(post, completion: self.handleSave)
            case .failure(let error):
                print("Failed to upload: \(error)")
                DispatchQueue.main.async {
                    self.messageAlert(firstLine: "Error", alertMessage: "Could not upload image")
                }
            }
        }
    }
    
    /****************************************************************************************************************************//**
    ** \brief      Function to save the Post to Datastore. The datastore is used for persisting data on the device.
    ** \param   The post parameter is takes the data from upload().
    ** \param   Completion handler with a boolean as parameter.
    ********************************************************************************************************************************/
    func save(_ post: Post, completion: @escaping (Bool, Error?) -> Void) {
        Amplify.DataStore.save(post) { result in
            switch result {
            case .success:
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }
    
    /****************************************************************************************************************************//**
    ** \brief      Function to handle the closure from function save() to update the UI.
    ** \param   Completion handler with a boolean as parameter.
    ********************************************************************************************************************************/
    func handleSave(succeed: Bool, error: Error?) {
        if succeed {
            DispatchQueue.main.async {
                self.imageView.image = nil
                self.setImageButton(imageName: "icon-camera-white")
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        } else {
            DispatchQueue.main.async {
                self.messageAlert(firstLine: "Error", alertMessage: "Could not save image")
            }
        }
    }
//    []
    // MARK: - UIImagePickerControllerDelegate Methods
    /****************************************************************************************************************************//**
    ** \brief      Function to get the right image from imagePicker and set the imageView to it. If there is picked an image the imagePicker will dismiss and
            set the button to an upload button.
    ** \param   The ImagePickerController and the did finish picking media with info.
    ********************************************************************************************************************************/
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = pickedImage
        
        dismiss(animated: true, completion: nil)
        setImageButton(imageName: "icon-upload-white")
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
    /****************************************************************************************************************************//**
    ** \brief      If the imagePicker is cancelled the imagePicker will disappear from screen, it will be dismissed.
    ** \param   The ImagePickerController.
    ********************************************************************************************************************************/
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIAlertController
    /****************************************************************************************************************************//**
    ** \brief      Function to handle the alert dispaying it to the user when an error occures.
    ** \param   The function takes a title and message for the alert.
    ********************************************************************************************************************************/
    func messageAlert(firstLine: String, alertMessage: String) {
        let alert = UIAlertController(title: firstLine, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
        }))
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(alert, animated: true, completion: nil)
   }
    
    
}
