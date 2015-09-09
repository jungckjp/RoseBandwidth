//
//  DataGrabber.swift
//  RoseBandwidth
//
//  Created by Jonathan Jungck on 2/9/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//
import UIKit
import CoreData

class DataGrabber: NSObject {

    let myURLString : NSString
    var myURL : NSURL?
    var conn: NSURLConnection?
    var request : NSMutableURLRequest?
    var data: NSMutableData = NSMutableData()
    var login : LoginCredentials?
    var managedObjectContext : NSManagedObjectContext? 
    
    let dataOverviewIdentifier = "DataOverview"
    let dataDeviceIdentifier = "DataDevice"
    
    var overviews = [DataOverview]()
    var devices = [DataDevice]()
    var isReady = false
    var loginSuccessful = false
    var cancelledAttempt = false
    var usageViewController : UsageViewController?
    var loginViewController : LoginViewController?
    
    convenience init(login : LoginCredentials, usageView: UsageViewController) {
        self.init()
        self.login = login
        self.usageViewController = usageView
    }
    
    convenience init(login : LoginCredentials, loginView: LoginViewController) {
        self.init()
        self.login = login
        self.loginViewController = loginView
    }
    
    convenience init(login : LoginCredentials) {
        self.init()
        self.login = login
    }

    override init() {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        myURLString = "http://netreg.rose-hulman.edu/tools/networkUsage.pl#"
        super.init()
        
        
        
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        
        let storage : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies  as [NSHTTPCookie]!{
            storage.deleteCookie(cookie)
        }
        
        
        
        NSUserDefaults.standardUserDefaults()
        self.killConnection()
        
        myURL = NSURL(string: myURLString as String)
        
        
        if myURL != nil {
            request = NSMutableURLRequest(URL: myURL!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 8.0)
            //NSMutableURLRequest(
            conn = NSURLConnection(request: request!, delegate: self)
            conn?.start()
        }
        self.data = NSMutableData()
    }

    
    func killConnection() {
        conn?.cancel()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        killConnection()
        if (self.loginViewController != nil) {
            if (self.loginViewController!.alertShowing) {
                self.loginViewController!.loadingController.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.loginViewController!.alertShowing = false
                    self.loginViewController!.couldNotConnect()
                    
                })
            } else {
                self.loginViewController!.couldNotConnect()
            }
        } else {
            couldNotConnect()
        }
        print("Failed with error:\(error.localizedDescription)")

    }
    
    func couldNotConnect() {
        let networkFailController = UIAlertController(title: "Connection Failed", message: "Please ensure you are connected to the Rose-Hulman Wi-Fi.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let failedAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        networkFailController.addAction(failedAction)
        UIApplication.sharedApplication().keyWindow?.rootViewController!.presentedViewController!.presentViewController(networkFailController, animated: true, completion: nil)
        
    }
    
    func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge!){
        if login != nil {
            let authentication: NSURLCredential = NSURLCredential(user: login!.username, password: login!.password, persistence: NSURLCredentialPersistence.None)
            
            // If the website allows for user session cookies, use this instead to allow multiple logins in one session.
            //var authentication: NSURLCredential = NSURLCredential(user: login!.username, password: login!.password, persistence: NSURLCredentialPersistence.None)
            if challenge.previousFailureCount > 0 {
                if (loginViewController != nil) {
                    killConnection()
                    loginViewController!.loginFailed()
                }
            }
            challenge.sender!.useCredential(authentication, forAuthenticationChallenge: challenge)
        }
    }
    
    func connection(connection: NSURLConnection!, willCacheResponse: NSCachedURLResponse) -> Bool {
        return false
    }
    
    //NSURLConnection delegate method
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        //New request so we need to clear the data object
        self.data = NSMutableData(data: NSMutableData())
        self.data.setData(NSData())
    }
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        //Append incoming data
        self.data = NSMutableData(data: NSMutableData())
        self.data.setData(NSData())
        self.data.appendData(data)
    }
    
    
    //NSURLConnection delegate method
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        let myHTMLString = NSString(data: self.data, encoding: NSUTF8StringEncoding)
        
        var err : NSError?
        let parser     = HTMLParser(html: myHTMLString as String!, error: &err)
        if err != nil {
            print(err)
            exit(1)
        } else {
            let items = parser.body?.findChildTags("td")
//            var i = 0
//            for item in items! {
//                println("\(i): \(item.contents)")
//                i++
//            }
            if items != nil {
                
                var array = items!
                
                //Gather old data
                updateData()
                
                //Delete any old data
                for i in 0..<overviews.count {
                    managedObjectContext?.deleteObject(overviews[i])
                }
                for i in 0..<devices.count {
                    managedObjectContext?.deleteObject(devices[i])
                }
                
                
                //Set overview data
                let newOverview = NSEntityDescription.insertNewObjectForEntityForName(dataOverviewIdentifier, inManagedObjectContext: self.managedObjectContext!) as! DataOverview
                newOverview.bandwidthClass = array[15].contents
                newOverview.recievedData = array[16].contents
                newOverview.sentData = array[17].contents
                overviews.append(newOverview)
                let numDevices = (array.count - 27)/7
                
                for i in 0..<numDevices {
                    //Set devices data
                    let newDevice = NSEntityDescription.insertNewObjectForEntityForName(dataDeviceIdentifier, inManagedObjectContext: self.managedObjectContext!) as! DataDevice
                    newDevice.addressIP = array[27+7*i].contents
                    newDevice.hostName = array[29+7*i].contents
                    newDevice.recievedData = array[30+7*i].contents
                    newDevice.sentData = array[31+7*i].contents
                    devices.append(newDevice)
                }
                
            }
            
        }
        isReady = true
        loginSuccessful = true
        killConnection()
        if (usageViewController != nil) {
            usageViewController?.replaceData(login!)
        } else if (loginViewController != nil){
            loginViewController!.justLoggedIn = true
            loginViewController?.loginFromGrabber(login!)
        }
        
    }

    func updateData() {
        let fetchRequestDevices = NSFetchRequest(entityName: dataDeviceIdentifier)
        let fetchRequestOverview = NSFetchRequest(entityName: dataOverviewIdentifier)
        
        var error : NSError? = nil
        do {
            try devices = managedObjectContext?.executeFetchRequest(fetchRequestDevices) as! [DataDevice]
            try overviews = managedObjectContext?.executeFetchRequest(fetchRequestOverview) as! [DataOverview]
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            print("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
        
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


    func grabData(){
        var error: NSError?
        let myHTMLString: NSString?
        do {
            myHTMLString = try NSString(contentsOfURL: myURL!, encoding: NSUTF8StringEncoding)
        } catch let error1 as NSError {
            error = error1
            myHTMLString = nil
        }
        
        if let error = error {
            print("Error : \(error)")
        }
        
        
        var err : NSError?
        var parser = HTMLParser(html: myHTMLString! as String, error: &err)
        if err != nil {
            print(err)
            exit(1)
        }

    }

}
