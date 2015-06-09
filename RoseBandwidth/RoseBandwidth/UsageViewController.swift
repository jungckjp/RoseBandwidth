//
//  UsageViewController.swift
//  Rose-Hulman Bandwidth
//
//  Created by Jonathan Jungck on 1/28/15.
//  Copyright (c) 2015 Jonathan Jungck and Anthony Minardo. All rights reserved.
//

import UIKit

var managedObjectContext : NSManagedObjectContext?
var overview = [DataOverview]()
let usageIdentifier = "DataOverview"
let credentialIdentifier = "LoginCredentials"
var credentials = [LoginCredentials]()
var dataGrabber : DataGrabber?

class UsageViewController: UIViewController {
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var sentLabel: UILabel!
    @IBOutlet weak var receivedPercent: UILabel!
    @IBOutlet weak var sentPercent: UILabel!
    @IBOutlet weak var bandwidthClass: UILabel!
    @IBOutlet weak var classStatus: UIImageView!
    @IBOutlet weak var recBar: UIView!
    @IBOutlet weak var recProg: UIView!
    @IBOutlet weak var senBar: UIView!
    @IBOutlet weak var senProg: UIView!
    
    @IBOutlet weak var titleBarItem: UINavigationItem!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        fetchOverview()
        var username = (credentials[0].username).capitalizedString
        titleBarItem.title = "\(username)'s Usage"
        if ((UIApplication.sharedApplication().keyWindow?.rootViewController! as! LoginViewController).justLoggedIn == false) {
            refreshPressed(refreshPressed)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchOverview()
        updateView()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateView()
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    @IBOutlet weak var refreshPressed: UIBarButtonItem!
    
    @IBAction func refreshPressed(sender: UIBarButtonItem) {
        updateLoginCredentials()
        loadingData(credentials[0])
    }
    
    func updateView() {
        fetchOverview()
        var bandwidth : String = overview[0].bandwidthClass
        bandwidthClass.text = bandwidth
        if bandwidth == "1024k" {
            classStatus.image = UIImage(named: "yellowlight.png")
            recProg.backgroundColor = UIColor(red: 233/255, green: 220/255, blue: 2/255, alpha: 1)
            senProg.backgroundColor = UIColor(red: 233/255, green: 220/255, blue: 2/255, alpha: 1)
        } else if bandwidth == "256k" {
            classStatus.image = UIImage(named: "redlight.png")
            recProg.backgroundColor = UIColor(red: 227/255, green: 36/255, blue: 5/255, alpha: 1)
            senProg.backgroundColor = UIColor(red: 227/255, green: 36/255, blue: 5/255, alpha: 1)
        }
        /* Recieved Math & Contraints */
        var received : String = overview[0].recievedData
        receivedLabel.text = received
        received = received.substringToIndex(received.endIndex.predecessor().predecessor().predecessor())
        var recNoComma = NSString(string: received).stringByReplacingOccurrencesOfString(",", withString: "")
        var rec : Float = NSString(string: recNoComma).floatValue
        rec = rec / 8000
        
        var prog = rec
        if bandwidth == "1024k" || bandwidth == "256k" {
            prog = 1.0
        }
        
        var recCon : NSLayoutConstraint
        var mult = CGFloat(prog)
        
        recCon = NSLayoutConstraint(item: recProg, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: recBar, attribute: NSLayoutAttribute.Width, multiplier: mult, constant: 0.0)
        recCon.active = true
        receivedPercent.text = String(format: "%.1f%%", rec*100)
        
        /* Sent Math & Contraints */
        var sent : String = overview[0].sentData
        sentLabel.text = sent
        sent = sent.substringToIndex(sent.endIndex.predecessor().predecessor().predecessor())
        var senNoComma = NSString(string: sent).stringByReplacingOccurrencesOfString(",", withString: "")
        var sen : Float = NSString(string: senNoComma).floatValue
        sen = sen / 8000
        
        var senCon : NSLayoutConstraint
        var mult2 = CGFloat(sen)
        
        senCon = NSLayoutConstraint(item: senProg, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: senBar, attribute: NSLayoutAttribute.Width, multiplier: mult2, constant: 0.0)
        
        senCon.active = true
        sentPercent.text = String(format: "%.1f%%", sen*100)
        
        self.updateViewConstraints()
            
    }
    
    func updateLoginCredentials() {
        let fetchRequest = NSFetchRequest(entityName: loginCredentialsIdentifier)
        
        var error : NSError? = nil
        credentials = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [LoginCredentials]
        
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
    
    func verifyLogin(dataGrabber : DataGrabber) -> Bool {
        if (dataGrabber.isReady) {
            if (dataGrabber.loginSuccessful) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func loadingData(newCredentials: LoginCredentials){
        dataGrabber = DataGrabber(login: credentials[0], usageView : self)
        
        let loadingController = UIAlertController(title: "Connecting...", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (_) -> Void in
            loadingController.dismissViewControllerAnimated(true, completion: nil)
            dataGrabber!.cancelledAttempt = true
            dataGrabber!.killConnection()
        }
        
        loadingController.addAction(cancelAction)
        
        let loginFailController = UIAlertController(title: "Update Failed", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        loginFailController.addAction(okAction)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

    }
    
    func replaceData(newCredentials : LoginCredentials) {
        self.fetchOverview()
        newCredentials.isLoggedIn = true
        self.savedManagedObjectContext()
        self.updateView()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func fetchOverview() {
        let fetchRequest = NSFetchRequest(entityName: usageIdentifier)
        
        var error : NSError? = nil
        overview = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [DataOverview]
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
        
        let credRequest = NSFetchRequest(entityName: credentialIdentifier)
        credentials = managedObjectContext?.executeFetchRequest(credRequest, error: &error) as! [LoginCredentials]
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
