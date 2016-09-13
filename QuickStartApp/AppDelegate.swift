//
//  AppDelegate.swift
//  QuickStartApp
//
//  Created by Wang Yujia on 12/9/16.
//  Copyright © 2016 National University of Singapore Design Centric Program. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        print ("hello")
        return true
    }
    
    // indicate this app can open url
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        
        // turn the URL into an array of queryItems
        func processOAuthStep1Response(url: NSURL)
        {
            let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
            var code:String?
            if let queryItems = components?.queryItems
            {
                for queryItem in queryItems
                {
                    if (queryItem.name.lowercaseString == "code")
                    {
                        // authorization code
                        code = queryItem.value

                        
                        
                        // 2. get access token
                        func requestFitbitAccessToken() {
                            let getTokenPath:String = "https://api.fitbit.com/oauth2/token"
                            let tokenParams = ["client_id":"227ZFK",
                                               "client_secret":"47e5382a22367a094b075587fb559f05",
                                               "code": code!,
                                               "grant_type":"authorization_code",
                                               "redirect_uri":"nusdcp2016://",
                                               "expires_in":"28800"]
                            // base64 encode client id and secret
                            let client_id = "227ZFK"
                            let client_secret = "47e5382a22367a094b075587fb559f05"
                            let apiLoginString = NSString(format: "%@:%@", client_id, client_secret)
                            let apiLoginData = apiLoginString.dataUsingEncoding(NSUTF8StringEncoding)!
                            let base64ApiLoginString = apiLoginData.base64EncodedStringWithOptions([])
                            
                            let theHeader = "Basic " + base64ApiLoginString
                            
                            Alamofire.request(
                                .POST,
                                getTokenPath,
                                headers: ["Authorization" : theHeader],
                                parameters: tokenParams)
                                .responseJSON { (response) -> Void in
                                    // TODO: handle response to extract OAuth token
                                    print(response.response?.statusCode)
                                    let access_token = response.result.value!["access_token"] as! String
                                    let theAPIHeader: String = "Bearer " + access_token
                                    // 3. make API call for activity
                                    // config data storage
                                    let download_date_list = ["2016-09-04", "2016-09-05", "2016-09-06"]
                                    FitbitAPIHelper.sharedInstance.downloadFitbitData(download_date_list, header: theAPIHeader)
                                    // end of API call
                            }
                            requestFitbitAccessToken()
                            
                        }
                        
                        break
                    }
                }
            }
        }
        processOAuthStep1Response(url)
        return true
    }
    // boilerplate below
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
        // The directory the application uses to store the Core Data store file. This code uses a directory named "nusdcp.QuickStartApp" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("QuickStartApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
