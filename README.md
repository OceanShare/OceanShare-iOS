# OceanShare-iOS

* Open 'OceanShare.xcworkspace' in Xcode.
* Open 'OceanShare' in the 'Project Navigator'.
* Define a Team name in the 'Signin' Part.
* Download the 'GoogleService-info.plist' file in the Firebase console and put it in the 'OceanShare' directory.
* If needed, in 'OceanShare-iOS' directory, run:
```
>>> pod install
```
* Run the project.

## Important
* Don't push the 'Pods/' directory.
* Don't push the 'GoogleService-info.plist' file.
* Don't remove '.gitignore' file.
* All the used assets are located in 'Ressources/images.zip'.

## Useful tools & links
* [Firebase Authentication Dashboard](https://console.firebase.google.com/u/2/project/oceanshare-1519985626980/authentication/users)
* [Firebase Realtime Database](https://console.firebase.google.com/u/2/project/oceanshare-1519985626980/database/oceanshare-1519985626980/data)
* [Firebase Codelab](https://codelabs.developers.google.com/codelabs/firebase-ios-swift/#16)
* [GidSignIn issues](https://stackoverflow.com/questions/31413937/initiate-google-signin-without-the-gidsigninbutton-but-programmatically)
* [Facebook Login with Firebase Tutorial n°1](https://medium.com/tfhtutorials/facebook-login-and-firebase-step-by-step-set-up-ios-9-swift-cocoapods-e39051bf13c7)
* [Facebook Login with Firebase Tutorial n°2](https://medium.com/@lawgimenez/facebook-login-and-firebase-using-swift-3-1-c6e0b1fff0df)
* [PageViewController issues](https://stackoverflow.com/questions/32299874/change-view-in-a-page-view-controller-when-button-is-pressed-in-one-of-the-contr)

## Useful pod commands
* Installation.
```
>>> pod init
```
* Downloads all dependencies defined in Podfile and creates an Xcode Pods library project in ./Pods.
```
>>> pod install
```
* Updates the Pods identified by the specified POD_NAMES, which is a space-delimited list of pod names. If no POD_NAMES are specified, it updates all the Pods, ignoring the contents of the Podfile.lock. This command is reserved for the update of dependencies; pod install should be used to install changes to the Podfile.
```
>>> pod update [POD_NAMES ...]
```
* Shows the outdated pods in the current Podfile.lock, but only those from spec repos, not those from local/external sources.
```
>>> pod outdated
```
* Deintegrate your project from CocoaPods. Removing all traces of CocoaPods from your Xcode project.
```
>>> pod deintegrate
```
