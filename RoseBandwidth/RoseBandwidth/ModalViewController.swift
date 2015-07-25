//
//  ModalViewController.swift
//  RoseBandwidth
//
//  Created by Anthony Minardo on 2/7/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

import UIKit
import CoreData

class ModalViewController: UIViewController, UITextFieldDelegate {
    
    var managedObjectContext : NSManagedObjectContext?

    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func savePressed(sender: AnyObject) {
        print("Pressed")
        if tableSettingCell != nil {
            print("Cell")
            if alert != nil {
                print("Alert")
                if typeView {
                    print("Type")
                    let typeTable = containedView.subviews[0] as! TypeTableView
                    let string = typeTable.getSelected()
                    tableSettingCell?.detailTextLabel?.text = string as String
                    alert!.alertType = typeTable.getType() as String
                    savedManagedObjectContext()
                } else if valueView {
                    print("Value")
                    let valueTable = containedView.subviews[0] as! ValueTableView
                    let string = valueTable.getSelected()
                    tableSettingCell?.detailTextLabel?.text = string as String
                    alert!.alertName = valueTable.getValue() as String
                    savedManagedObjectContext()
                }
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var containedView: UIView!
    
    
    var tableSettingCell : UITableViewCell?
    var typeView = false
    var valueView = false
    var alert : Alerts?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func savedManagedObjectContext() {
        var error : NSError?
        
        do {
            try managedObjectContext?.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            print("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
