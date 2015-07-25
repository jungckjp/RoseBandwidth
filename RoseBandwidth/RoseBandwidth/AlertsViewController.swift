//
//  AlertsTableViewController.swift
//  Rose-Hulman Bandwidth
//
//  Created by Jonathan Jungck on 2/1/15.
//  Copyright (c) 2015 Jonathan Jungck and Anthony Minardo. All rights reserved.
//

import UIKit
import CoreData

class AlertsViewController: UIViewController {
    @IBOutlet var containedView: UIView!
    var managedObjectContext : NSManagedObjectContext?
    let showAddViewIdentifier = "showAddView"
    let alertsIdentifier = "Alerts"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        //self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "showEditAlertsView"), animated: true)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "pushAddView"), animated: true)
        
        let backButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "dismiss")
        self.navigationItem.leftBarButtonItem = backButton
        
    }
    
    @IBAction func dismiss(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        print("Dismiss")
    }
    func dismiss() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showEditAlertsView() {
        let alertTableView = containedView.subviews[0] as! UITableView
        alertTableView.setEditing(true, animated: true)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "hideEditAlertsView"), animated: true)
        
    }
    
    func pushAddView() {
        performSegueWithIdentifier("showAddView", sender: self)
    }
    
    func hideEditAlertsView() {
        let alertTableView = containedView.subviews[0] as! UITableView
        alertTableView.setEditing(false, animated: true)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "showEditAlertsView"), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == showAddViewIdentifier {
            (segue.destinationViewController as! AddAlertViewController).viewTitle = "Add Alert"
            (segue.destinationViewController as! AddAlertViewController).managedObjectContext = managedObjectContext
        }
    }


}
