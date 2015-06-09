//
//  AddAlertViewController.swift
//  RoseBandwidth
//
//  Created by Anthony Minardo on 2/7/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

import UIKit
import CoreData

class AddAlertViewController: UIViewController {
    
    @IBAction func cancelPressed(sender: AnyObject) {
        if newAlert != nil {
            managedObjectContext?.deleteObject(newAlert!)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func savePressed(sender: AnyObject) {
        if alert != nil {
            managedObjectContext?.deleteObject(alert!)
        }
        if newAlert != nil {
            alerts.append(newAlert!)
            savedManagedObjectContext()
            
            if (newAlert!.alertType == "%") {
                newAlert!.threshold = ((newAlert!.alertName as NSString).floatValue / 100) * 8000
                
            } else if (newAlert!.alertType == " GB") {
                newAlert!.threshold = (newAlert!.alertName as NSString).floatValue * 1000
                
            } else {
                newAlert!.threshold = (newAlert!.alertName as NSString).floatValue
                
            }
            println("Saved: \(newAlert!.threshold)")
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBOutlet weak var navItemTitle: UINavigationItem!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var containedView: UIView!
    
    var alerts = [Alerts]()
    var alert : Alerts?
    var newAlert : Alerts?
    var viewTitle : NSString?
    var managedObjectContext : NSManagedObjectContext?
    let alertsIdentifier = "Alerts"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newAlert = NSEntityDescription.insertNewObjectForEntityForName(self.alertsIdentifier, inManagedObjectContext: self.managedObjectContext!) as? Alerts


        if alert != nil {
            newAlert?.threshold = alert!.threshold
            newAlert?.alertName = alert!.alertName
            newAlert?.alertType = alert!.alertType
            newAlert?.isEnabled = alert!.isEnabled
            if (newAlert!.alertType == "") {
                typeLabel.text = "%"
            } else {
               typeLabel.text = "\(newAlert!.alertType)"
            }
            if (newAlert!.alertName == "") {
                valueLabel.text = "0"
            } else {
                valueLabel.text = "\(newAlert!.alertName)"
            }
            descLabel.text = "Your data has exceeded your \(newAlert!.alertName)\(newAlert!.alertType) limit"
        } else {
            newAlert?.threshold = 1000.00
            newAlert?.alertName = valueLabel.text!
            newAlert?.alertType = typeLabel.text!
            newAlert?.isEnabled = true
        }
        
        var loginCredentialsIdentifier = "LoginCredentials"
        let fetchRequest = NSFetchRequest(entityName: loginCredentialsIdentifier)
        
        var error : NSError? = nil
        var credentials = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [LoginCredentials]
        
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
        
        if (credentials.count > 0){
            newAlert?.username = credentials[0].username
        }
        
        if viewTitle != nil {
            navItemTitle.title = viewTitle! as String
        }
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        if (newAlert!.alertType == "") {
            newAlert!.alertType = "%"
        }
        typeLabel.text = "\(newAlert!.alertType)"
        if (newAlert!.alertName == "") {
            newAlert!.alertName = "0"
        }
        valueLabel.text = "\(newAlert!.alertName)"

        descLabel.text = "Your data has exceeded your \(newAlert!.alertName)\(newAlert!.alertType) limit"
        var typeCell = (containedView.subviews[0] as! UITableView).cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
        var valueCell = (containedView.subviews[0] as! UITableView).cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))!
        
        
        if (newAlert!.alertType == "%") {
            typeCell.detailTextLabel?.text = "Percentage (%)"
            valueCell.detailTextLabel?.text = "\(newAlert!.alertName)"
        } else if (newAlert!.alertType == " GB") {
            typeCell.detailTextLabel?.text = "Gigabytes (GB)"
            valueCell.detailTextLabel?.text = "\(newAlert!.alertName)"
        } else if (newAlert!.alertType == " MB") {
            typeCell.detailTextLabel?.text = "Megabytes (MB)"
            valueCell.detailTextLabel?.text = "\(newAlert!.alertName)"
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateAlerts() {
        let fetchRequest = NSFetchRequest(entityName: alertsIdentifier)
        
        var error : NSError? = nil
        alerts = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [Alerts]
        
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
        
    }
    
    func savedManagedObjectContext() {
        var error : NSError?
        
        managedObjectContext?.save(&error)
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
    }

    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //(segue.destinationViewController as ModalViewController).alert = newAlert
        //(segue.destinationViewController as ModalViewController).managedObjectContext = managedObjectContext
    }


}
