//
//  CoverViewController.swift
//  Foodaholic
//
//  Created by onechun🌾 on 2016/10/11.
//  Copyright © 2016年 onechun. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class CoverViewController: UIViewController,FBSDKLoginButtonDelegate {
    var loginButton: FBSDKLoginButton = FBSDKLoginButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loginButton.hidden = true
        
        
        FIRAuth.auth()?.addAuthStateDidChangeListener{ auth, user in
        if let user = user{
            let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main",bundle: nil)
            let MapViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MapViewController")
            self.presentViewController(MapViewController, animated: true, completion: nil)
        }else{
            
            self.loginButton.center = self.view.center
            self.loginButton.readPermissions = ["public_profile","email","user_friends"]
            self.loginButton.delegate = self
            
            self.view!.addSubview(self.loginButton)
            self.loginButton.hidden = false

            }
        
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!,didCompleteWithResult result: FBSDKLoginManagerLoginResult!,error: NSError!){
        print("User Logged In")
        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)

        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            print("User logged in to firebase")
        }
    }
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
        print("User did Logout")
    }
}
