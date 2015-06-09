//
//  SettingsTableViewController.swift
//  RoseBandwidth
//
//  Created by Anthony Minardo on 2/11/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

let logoutIdentifier = "logoutSegue"
let loginCredentialsIdentifier = "LoginCredentials"
let devicesIdentifier = "DataDevice"
let overviewIdentifier = "DataOverview"
let alertsIdentifier = "Alerts"

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var logoutCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        let fetchRequest = NSFetchRequest(entityName: loginCredentialsIdentifier)
        
        var error : NSError? = nil
        var credentials = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [LoginCredentials]
        
        var error2 : NSError? = nil
        let fetchRequest2 = NSFetchRequest(entityName: alertsIdentifier)
        var alerts = managedObjectContext?.executeFetchRequest(fetchRequest2, error: &error) as! [Alerts]
        
        var count = 0
        if credentials.count > 0 {
            if alerts.count > 0 {
                for alert in alerts {
                    if ((alert.username == credentials[0].username) && (alert.isEnabled.boolValue)){
                        count++
                    }
                }
            }
        }
        
        self.tableView(self.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)).detailTextLabel?.text = count != 1 ? "\(count) alerts" : "\(count) alert"
        
        var user : NSString = credentials[0].username
        self.tableView(self.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 4, inSection: 0)).textLabel?.text = "LOGGED IN AS \(user.uppercaseString)"
        
        
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
        return 11
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 5 {
            dataGrabber?.killConnection()
            
            let fetchRequest = NSFetchRequest(entityName: loginCredentialsIdentifier)
            
            var error : NSError? = nil
            var credentials = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [LoginCredentials]
            
            if error != nil {
                println("There was an unresolved error: \(error?.userInfo)")
                abort()
            }
            
            for index in credentials {
                managedObjectContext?.deleteObject(index)
            }
            
            let fetchRequest2 = NSFetchRequest(entityName: devicesIdentifier)
            
            var error2 : NSError? = nil
            var devices = managedObjectContext?.executeFetchRequest(fetchRequest2, error: &error) as! [DataDevice]
            
            for index2 in devices {
                managedObjectContext?.deleteObject(index2)
            }
            
            let fetchRequest3 = NSFetchRequest(entityName: overviewIdentifier)
            
            var error3 : NSError? = nil
            var overview = managedObjectContext?.executeFetchRequest(fetchRequest3, error: &error) as! [DataOverview]
            
            for index3 in overview {
                managedObjectContext?.deleteObject(index3)
            }
            
            
            savedManagedObjectContext()
            self.dismissViewControllerAnimated(true, completion: nil)
            //performSegueWithIdentifier(logoutIdentifier, sender: self)

        }
        
        if indexPath.section == 0 && indexPath.row == 10 {
            var device = UIDevice.currentDevice().model
            var version = UIDevice.currentDevice().systemName + ": " + UIDevice.currentDevice().systemVersion
            var mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients(["jungckjp@rose-hulman.edu"])
            mailComposerVC.setSubject("[RoseBandwidth] Feedback")
            
            mailComposerVC.setMessageBody(" \n \n \n \nDevice: \(device)\n\(version)", isHTML: false)
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposerVC, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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
    
    func savedManagedObjectContext() {
        var error : NSError?
        
        managedObjectContext?.save(&error)
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
    }

}
