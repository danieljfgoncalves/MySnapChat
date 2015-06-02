//
//  User.swift
//  MySnapChat
//
//  Created by Daniel Goncalves on 2015-06-02.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class User: PFUser, PFSubclassing {
   
    override init() {
        super.init()
        
    }
    // Create an override
    convenience init(name: String!, password: String!) {
        self.init()
        PFUser.logOut()
        self.username = name
        self.password = password
        self.createNewUser(self.username!, password: self.password!)
    }
    func createNewUser(username: String, password: String) {
        
        // Log in user
        PFUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, error: NSError?) -> Void in
            
            if user != nil {
                println("user is logged in")
//                self.performSegueWithIdentifier("showUsers", sender: self)
            } else {
                println("Log in failed.")
                // Setup User
                var user = PFUser()
                user.username = username
                user.password = password
                user.signUp()
                
                user.signUpInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                    if error == nil {
                        println("sign up")
//                        self.performSegueWithIdentifier("showUsers", sender: self)
                    } else {
                        println(error?.description)
                    }
                })
                
                
            }
        }
    }
}
