# AWSAlbum
The PhotoAlbum app let users chose there favorite images from there photoalbum and saves it one by one to the cloud. This way the user will always have a backup from there favorite images saved. The saved images could be shown in the second view, entered by the tabbar.

The iOS PhotoAlbum app uses Amazon Web Services to store images in the cloud and GraphQL API to interact between the app and AWS.


## UX description
The app uses AWS AppSync service, which provides local data access when devices go offline, and data synchronization with customizable conflict resolution, when they are back online. This interaction with the data is enabled by using a managed GraphQL service. GraphQL APIs are organized in terms of types and fields, not endpoints. To access the full capabilities of the data is possible from a single endpoint. This endpoint can be found in the configuration.json files within the Configuration group.


## UI description
The ImagePicker is used to enter the users photo library, so the user can chose there favorite images to be saved to the backend. The button for this action will change to an upload button as soon as the user made there pick. After the user did one or several uploads to the backend, the user can see the uploaded images in the second tab, the photo album.


## Requirements
Apple: 
- Xcode 12
- Swift 5
- Platform iOS 14.0
- Info.plist
  - Privacy - photo library usage description
  - Privacy - camera usage description

AWS Services:
- S3 Bucket (Storage)
- DynamoDB (DataBase)
- AppSync (Synchronisation)
- GraphQL (query language API)

Pods: 
- Amplify
- AmplifyPlugins/AWSCognitoAuthPlugin
- AmplifyPlugins/AWSS3StoragePlugin
- AmplifyPlugins/AWSAPIPlugin
- AmplifyPlugins/AWSDataStorePlugin


## How to Build
The app doesn't need to be initialized manually and is ready to use immediately.

Otherwise: 
Install the Amplify CLI:
```
$ npm install -g @aws-amplify/cli
```
Update the podfile (which is present):
```
$ pod install --repo-update
```
Start the configured project:
```
$ xed .
```


## Implementation
The PhotoAlbum app consist of two views which can be entered trough the tabbar. 
- One view for picking and saving the image 
- One view for showing all the images saved in the backend.

***Stack build-up***

There are 5 source files which needs to be added to the project:
- AmplifyModels.swift
- Post+Schema.swift
- Post.swift
- amplifyconfiguration.json
- awsconfiguration.json

***Configuration***

This group contains the needed awsconfiguration.json and amplifyconfiguration.json files. These files are needed for the right API configuration and connection with Amazon Web Services. 
In the PhotoAlbumApp.swift file the configuration with Amplify and Amplify plugins begins when the app starts.

***Models***

This group contains the generaded files from amplify library, based on the scheme.graphql. 
These files are needed within the API for communication trough GraphQL. 

***View***

This group contains the file for the custom generaded button for the first / CameraView.
These button will be set within the CameraView.swift file. It changes it's imageName and so the appearence and function of the button.

***ViewController***

This CameraView.swift file contains the functions to uploadthe an image to the storage and save the image with an UUID to the database. The image in the storage is the actual image, the image to the database is a link to the actual image.

This GalleryView.swift file contains the functions to query the saved data from the backend. When the query was successfull the images which where queried are downloaded and when successfully downloaded they are displayed in a collection view. When tapping on one of the images, you will delete the image from the collection view and also from the database and storage.

***info.plist***

These properties are added:
Privacy - photo library usage description
Privacy - camera usage description


## License
For the app the Amplify library is used, the license Apache 2.0 is applicable.
