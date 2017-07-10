//
//  LoginViewController.swift
//  Makestagram
//
//  Created by Crystal Zepeda on 6/30/17.
//  Copyright © 2017 Crystal Zepeda. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI
import FirebaseDatabase

typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
  
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if let user = Auth.auth().currentUser {
            let rootRef = Database.database().reference()
            let userRef = rootRef.child("users").child(user.uid)
            
         
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in

                if let user = User(snapshot: snapshot) {
                    print("Welcome back, \(user.username).")
               } else {
                    print("New user!")
                }
            })
        guard let authUI = FUIAuth.defaultAuthUI()
            else { return }
        
        authUI.delegate = self
        
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true)
}

}

}
extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        
        if let error = error {
            assertionFailure("Error signing in: \(error.localizedDescription)")
            return
        }
        guard let user = user
            else { return }
        
        let userRef = Database.database().reference().child("users").child(user.uid)
        
    UserService.show(forUID: user.uid) { (user) in
            if let user = user {
               
                User.setCurrent(user, writeToUserDefaults: true)
                
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()

            } else {
                self.performSegue(withIdentifier: Constants.Segue.toCreateUsername, sender: self)
            }
        
     }
    
    }
}
