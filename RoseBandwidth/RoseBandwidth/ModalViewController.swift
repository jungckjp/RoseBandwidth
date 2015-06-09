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
        println("Pressed")
        if tableSettingCell != nil {
            println("Cell")
            if alert != nil {
                println("Alert")
                if typeView {
                    println("Type")
                    var typeTable = containedView.subviews[0] as! TypeTableView
                    var string = typeTable.getSelected()
                    tableSettingCell?.detailTextLabel?.text = string as String
                    alert!.alertType = typeTable.getType() as String
                    savedManagedObjectContext()
                } else if valueView {
                    println("Value")
                    var valueTable = containedView.subviews[0] as! ValueTableView
                    var string = valueTable.getSelected()
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
        
        managedObjectContext?.save(&error)
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
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
