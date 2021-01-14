//
//  CameraView.swift
//  AWSPhotoAlbum
//
//  Created by Rick Gijsberts on 14/01/2021.
//

import Foundation
import UIKit
import Amplify

class CameraView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
