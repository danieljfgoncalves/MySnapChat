//
//  UserTableViewController.swift
//  MySnapChat
//
//  Created by Daniel Goncalves on 2015-06-01.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // Properties
    var userArray = [String]()
    var activeUser = 0
    var messageCount = 0
    var timer = NSTimer()
    // image picker controller
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        // upload to Parse
        var imageSend = PFObject(className: "Image")
        imageSend.ACL?.setPublicWriteAccess(true)
        imageSend["image"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.5))
        imageSend["sender"] = PFUser.currentUser()?.username
        imageSend["receiver"] = userArray[activeUser]
        imageSend.save()
    }
    func pickImage(sender: AnyObject) {
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var query = PFUser.query()
        query?.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
        var users = query?.findObjects()
        if let testUsers = users {
            for user in users! {
                println(user.username!)
                userArray.append(user.username!!)
                // Reload the tableView
                tableView.reloadData()
            }
        }
        // User Timer for reloading image
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("checkForMessages"), userInfo: nil, repeats: true)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func checkForMessages() {
        println("Checking for messages")
        // set up a query on the image class
        var query = PFQuery(className: "Image")
        // get the user
        query.whereKey("receiver", equalTo: PFUser.currentUser()!.username!)
        // grab the images from the list

        var images: Void = query.findObjectsInBackgroundWithBlock { (photo: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                var done = false
                if let myPhotoObject = photo {
                    var imageView:PFImageView = PFImageView()
                    for image in myPhotoObject {

                        if let imageFile = image["image"] as? PFFile {
                            
                            imageView.file = imageFile
                            imageView.loadInBackground()
                            println(imageView.file)
                            imageView.loadInBackground({ (photo: UIImage?, error: NSError?) -> Void in
                                if error == nil {
                                    var senderUsername = ""
                                    if image["sender"] != nil {
                                        senderUsername = image["sender"] as! String
                                    } else {
                                        senderUsername = "anonymous user"
                                    }
                                    // create an alert view
                                    var messageAlert = UIAlertController(title: "New Message", message: "Hey you have a message from \(senderUsername).", preferredStyle: UIAlertControllerStyle.ActionSheet)
                                    messageAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
                                        var backgroundView = UIImageView(frame: CGRect(origin: CGPointZero, size: self.view.frame.size))
                                        backgroundView.backgroundColor = UIColor.blackColor()
                                        backgroundView.alpha = 0.5
                                        backgroundView.tag = 3
                                        self.view.addSubview(backgroundView)
                                        // Create a variable for the displayed image
                                        var displayedImage = UIImageView(frame: CGRect(origin: CGPointZero, size: self.view.frame.size))
                                        displayedImage.image = photo
                                        displayedImage.tag = 3
                                        displayedImage.contentMode = UIViewContentMode.ScaleAspectFit
                                        self.view.addSubview(displayedImage)
//                                        // Delete image
                                        image.delete()
                                        // Hide messge
                                        self.timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("hideMessage"), userInfo: nil, repeats: false)
                                    }))
                                    if self.messageCount == 0 {
                                        self.presentViewController(messageAlert, animated: true, completion: nil)
                                        self.messageCount++
                                    }
                                }
                            })
                            done = true
                        }
                    }
                }
                
            }
        }
        
    }
    
    func hideMessage() {
        
        
        
        for subview in self.view.subviews {
            if subview.tag == 3 {
                subview.removeFromSuperview()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return userArray.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel!.text = userArray[indexPath.row]

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Selected user
        activeUser = indexPath.row
        pickImage(self)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
