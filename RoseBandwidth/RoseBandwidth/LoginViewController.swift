//
//  LoginViewController.swift
//  Rose-Hulman Bandwidth
//
//  Created by Jonathan Jungck on 1/28/15.
//  Copyright (c) 2015 Jonathan Jungck and Anthony Minardo. All rights reserved.
//

import UIKit
import CoreData
import NetworkExtension

class LoginViewController: UIViewController, UITextFieldDelegate{

    var managedObjectContext : NSManagedObjectContext?
    var credentials = [LoginCredentials]()
    
    let loginCredentialsIdentifier = "LoginCredentials"
    let devicesIdentifier = "DataDevice"
    let overviewIdentifier = "DataOverview"
    
    var justLoggedIn = false
    
    var alertShowing = false
    
    let loadingController = UIAlertController(title: "Connecting...", message: "", preferredStyle: UIAlertControllerStyle.Alert)

    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var loginViewArea: UIView!
    
    var c : NSLayoutConstraint?


    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateViewConstraints()
        username.delegate = self
        password.delegate = self
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (_) -> Void in
            self.loadingController.dismissViewControllerAnimated(true, completion: nil)
            dataGrabber!.cancelledAttempt = true
            dataGrabber!.killConnection()
        }
        self.loadingController.addAction(cancelAction)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
        UIView.animateWithDuration(0.5, animations: {
            self.c?.constant = -45
            self.view.layoutIfNeeded()
            self.username.updateConstraints()
            self.password.updateConstraints()
        })
    }
    
    @IBAction func textFieldSelected(sender: AnyObject) {
        UIView.animateWithDuration(0.5, animations: {
            self.c?.constant = -120
            self.view.layoutIfNeeded()
            self.username.updateConstraints()
            self.password.updateConstraints()
        })
    }

    
    override func viewWillAppear(animated: Bool) {
        c = NSLayoutConstraint(item: loginViewArea, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: topView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: -45)
        c!.active = true
        
        self.username.text = ""
        self.password.text = ""
        
        credentials.removeAll(keepCapacity: false);
        updateLoginCredentials()
    }
    
    override func viewDidAppear(animated: Bool) {
        credentials.removeAll(keepCapacity: false);
        updateLoginCredentials()
        if (credentials.count > 0) {
            var isLogged = credentials[0].isLoggedIn
            if isLogged.boolValue {
                loadNextPage()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadNextPage() {
        performSegueWithIdentifier("loginPush", sender: self.loginButton)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.tag == password.tag){
            textField.resignFirstResponder()
            self.view.endEditing(true);
            login()
        }
        else {
            password.becomeFirstResponder()
        }
        
        return true;
    }
    
    func login() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        UIView.animateWithDuration(0.5, animations: {
            self.c?.constant = -45
            self.view.layoutIfNeeded()
        })
        
        for dataSet in credentials {
            managedObjectContext?.deleteObject(dataSet)
        }
        
        
        credentials.removeAll(keepCapacity: false);
        
        let newCredentials = NSEntityDescription.insertNewObjectForEntityForName(loginCredentialsIdentifier, inManagedObjectContext: self.managedObjectContext!) as! LoginCredentials
        newCredentials.isLoggedIn = false;
        newCredentials.username = username.text
        newCredentials.password = password.text
        
        savedManagedObjectContext()
        updateLoginCredentials()
        
        loadingData(newCredentials)
        
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        login()
    }
    
    
    func loginFailed() {
        self.loadingController.dismissViewControllerAnimated(true, completion: {
            let loginFailController = UIAlertController(title: "Login Failed", message: "Your login details may be incorrect.", preferredStyle: UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            loginFailController.addAction(okAction)
            self.presentViewController(loginFailController, animated: true, completion: nil)
        })

    }
    
    func couldNotConnect() {
        let networkFailController = UIAlertController(title: "Connection Failed", message: "Please ensure you are connected to the Rose-Hulman Wi-Fi.", preferredStyle: UIAlertControllerStyle.Alert)
            
        let failedAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        networkFailController.addAction(failedAction)
        self.presentViewController(networkFailController, animated: true, completion: nil)
        self.alertShowing = true
        
    }
    
    func loadingData(newCredentials: LoginCredentials){
        
        let fetchRequest2 = NSFetchRequest(entityName: devicesIdentifier)
        
        var error2 : NSError? = nil
        var devices = managedObjectContext?.executeFetchRequest(fetchRequest2, error: &error2) as! [DataDevice]
        for index2 in devices {
            managedObjectContext?.deleteObject(index2)
        }
        
        let fetchRequest3 = NSFetchRequest(entityName: overviewIdentifier)
        
        var error3 : NSError? = nil
        var overview = managedObjectContext?.executeFetchRequest(fetchRequest3, error: &error3) as! [DataOverview]
        
        for index3 in overview {
            managedObjectContext?.deleteObject(index3)
        }
        
        savedManagedObjectContext()
        
        
        dataGrabber = DataGrabber(login: credentials[0], loginView: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        presentViewController(loadingController, animated: true, completion: nil)
        self.alertShowing = true

    }
    
    func loginFromGrabber(newCredentials : LoginCredentials){
        loadingController.dismissViewControllerAnimated(true) {
            newCredentials.isLoggedIn = true
            self.savedManagedObjectContext()
            self.loadNextPage()
        }
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


}
