//
//  Backend.swift
//  AWSPhotoAlbum
//
//  Created by Rick Gijsberts on 14/01/2021.
//

import Foundation
import UIKit
import Amplify
import AmplifyPlugins

/****************************************************************************************************************************//**
** \brief      Function to configure all the AWS Amplify plugins and call this initializer func in the AppDelegate.swift file.
** \param   Completion handler with bool and error as parameter.
********************************************************************************************************************************/
class BackendConfig {
    static let shared = BackendConfig(completion: CameraView().handleAmplifyConfig(succeed:error:))
    static func initialize() -> BackendConfig {
        return .shared
    }
    
    init(completion: @escaping(Bool, Error?) -> Void) {
        //initialize Amplify
        do {
            // Storage
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            // DataStore
            let models = AmplifyModels()
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: models))
            try Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: models))
            // Configure Plugins
            try Amplify.configure()
            print("Configured Amplify Successfully!")
            completion(true, nil)
        } catch {
            print("Could not configure Amplify, error: \(error)")
            completion(false, error)
        }
    }
}
