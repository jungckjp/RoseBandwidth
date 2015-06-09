//
//  AppDelegate.swift
//  RoseBandwidth
//
//  Created by Anthony Minardo on 2/5/15.
//  Copyright (c) 2015 edu.rosehulman. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let controller = self.window!.rootViewController as! LoginViewController
        controller.managedObjectContext = self.managedObjectContext
        
        let notificationType = UIUserNotificationType.Alert
        let acceptAction = UIMutableUserNotificationAction()
        acceptAction.identifier = "View"
        acceptAction.title = "View"
        acceptAction.activationMode = UIUserNotificationActivationMode.Foreground
        acceptAction.destructive = false
        acceptAction.authenticationRequired = true
        
        
        let category = UIMutableUserNotificationCategory()
        category.identifier = "alert"
        category.setActions([acceptAction], forContext: UIUserNotificationActionContext.Default)
        let categories = NSSet(array: [category])
        let settings = UIUserNotificationSettings(forTypes: notificationType, categories: categories as Set<NSObject>)
        application.registerUserNotificationSettings(settings)
        
        application.setMinimumBackgroundFetchInterval(NSTimeInterval.abs(600))
        
        return true
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        NSLog("Handle identifier : \(identifier)")
        // Must be called when finished
        completionHandler()
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let controller = self.window!.rootViewController as! LoginViewController
        var loginCredentialsIdentifier = "LoginCredentials"
        let fetchRequest = NSFetchRequest(entityName: loginCredentialsIdentifier)
        
        var error : NSError? = nil
        var credentials = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! [LoginCredentials]
        
        if error != nil {
            println("There was an unresolved error: \(error?.userInfo)")
            abort()
        }
        if (credentials.count == 0) {
            return
        }
        if (!credentials[0].isLoggedIn.boolValue) {
            return
        }
        DataGrabber(login: credentials[0]);
        
        delay(10) {
            var alertsIdentifier = "Alerts"
            var overviewIdentifier = "DataOverview"
            let fetchRequest2 = NSFetchRequest(entityName: overviewIdentifier)
            var overview = self.managedObjectContext?.executeFetchRequest(fetchRequest2, error: &error) as! [DataOverview]
            let fetchRequest3 = NSFetchRequest(entityName: alertsIdentifier)
            var alerts = self.managedObjectContext?.executeFetchRequest(fetchRequest3, error: &error) as! [Alerts]
            
            var received : String = overview[0].recievedData
            received = received.substringToIndex(received.endIndex.predecessor().predecessor().predecessor())
            var recNoComma = NSString(string: received).stringByReplacingOccurrencesOfString(",", withString: "")
            var rec : Float = NSString(string: recNoComma).floatValue
            
            var currThreshold : Float = 0.0
            var currAlert : Alerts?
            for alert in alerts {
                println(alert.threshold.floatValue)
                println(rec)
                if ((alert.threshold.floatValue <= rec) && (alert.isEnabled.boolValue) && (alert.username == credentials[0].username)) {
                    if alert.threshold.floatValue > currThreshold {
                        currAlert = alert
                        currThreshold = alert.threshold.floatValue
                    }
                }
            }
            if (currAlert != nil) {
                var localNotification:UILocalNotification = UILocalNotification()
                localNotification.alertBody = "Your data has exceeded your \(currAlert!.alertName)\(currAlert!.alertType) limit!"
                localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
                localNotification.category = "alert"
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            }
        }
        
        
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Anthony-Minardo.RoseBandwidth" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("RoseBandwidth", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("RoseBandwidth.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

