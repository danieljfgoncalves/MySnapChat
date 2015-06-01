//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBAction func submit(sender: AnyObject) {
        
        // Log in user
        PFUser.logInWithUsernameInBackground(username.text, password: "mypass") { (user: PFUser?, error: NSError?) -> Void in
            
            if user != nil {
                println("user is logged in")
                self.performSegueWithIdentifier("showUsers", sender: self)
            } else {
                println("Log in failed.")
                // Setup User
                var user = PFUser()
                user.username = self.username.text
                user.password = "mypass"
                
                user.signUpInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                    if error == nil {
                        println("sign up")
                        self.performSegueWithIdentifier("showUsers", sender: self)
                    } else {
                        println(error?.description)
                    }
                })
                
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

