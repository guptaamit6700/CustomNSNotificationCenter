//
//  ViewController.swift
//  CustomNotification
//
//  Created by Amit on 15/01/21.
//  Copyright © 2021 Amit. All rights reserved.
//

import UIKit
import Foundation

class Notification {
    var name: String = ""
    // unowned self to avoid retain cycle
    unowned var objectName: AnyObject
    var methodName: Selector
    var userInfo: Dictionary<String, Any>?
    var object: AnyObject?

    init(name: String, objectName: AnyObject, methodName: Selector, thisObject: AnyObject?) {
        self.name = name
        self.objectName = objectName
        self.methodName = methodName
        self.object = thisObject
    }
    deinit {
        print("notification deinit called...")
    }
 }

//
class NotificationCenter: NSCoder {
    private let serialQueue = DispatchQueue(label: "serialQueue")

    // Data structure
    var notifications: Dictionary<String, [Notification]>?
    
    static let sharedInstance: NotificationCenter = {
        let instance = NotificationCenter()
        instance.initVars()
        return instance
    }()
    
    func initVars() {
        notifications = Dictionary<String, [Notification]>()
    }
    
    func addObserver(notificationName: String, objectName: AnyObject, methodName: Selector, object: AnyObject?) {
        let notification = Notification(name: notificationName, objectName: objectName, methodName: methodName, thisObject: object)
        serialQueue.sync {
            var array = notifications?[notificationName]
                  guard array != nil else {
                          array = [Notification]()
                          array?.append(notification)
                          notifications?[notificationName] = array
                      return
                  }
                  notifications![notificationName]?.append(notification)
        }
    }

    func postNotification(notificationName: String) {
        serialQueue.sync {
            guard let notifications = notifications?[notificationName] else {
                return
            }
            for notificationData in notifications {
                let objectName = notificationData.objectName
                let methodName = notificationData.methodName
               _ = objectName.perform(methodName)
            }
        }
    }
    func removeObserver(objectName: AnyObject, notification: String) {
        serialQueue.sync {
            var array = notifications?[notification]
              guard array != nil else {
                  return
              }
              if array!.count > 0 {
                  array?.removeAll(where: { $0.objectName === objectName && $0.name == notification})
                  notifications![notification] = array
              }
        }
    }
 
    
    func postNotification(notificationName: String, object: AnyObject) {
        serialQueue.sync {
            guard let notification = notifications?[notificationName] else {
                 return
             }
             for notify in notification {
                 let objectName = notify.objectName
                 let methodName = notify.methodName
                 if object === notify.object {
                     _ = objectName.perform(methodName, with: object)
                 }
             }
        }
    }
    
    func postNotification(notificationName: String, userInfo: Any) {
        serialQueue.sync {
            guard let notification = notifications?[notificationName] else {
                   return
               }
               for notify in notification {
                   let objectName = notify.objectName
                   let methodName = notify.methodName
                   _ = objectName.perform(methodName, with: ["userInfo" : userInfo])
               }
        }
   
    }
    
    func removeObserver(notification: String) {
        if notification.count > 0 {
            notifications?.removeValue(forKey: notification)
        }
    }
}

//class Notification {
//    var name: String = ""
//    var objectName: AnyObject
//    var methodName: Selector
//    var userInfo: Dictionary<String, Any>?
//    var object: AnyObject?
//
//    init(thisName: String,thisClassName: AnyObject, thisMethodName: Selector, thisObject: AnyObject?) {
//        self.name = thisName
//        self.objectName = thisClassName
//        self.methodName = thisMethodName
//        self.object = thisObject
//    }
//}
//
//class NotificationCenter: NSObject {
//    var notifications : Dictionary<String, [Notification]>?
//    static let sharedInstance: NotificationCenter = {
//       let instance = NotificationCenter()
//        instance.initVars()
//        return instance
//    }()
//    func initVars() {
//        notifications = Dictionary<String, [Notification]>()
//    }
//    // NotificationNme
//    //ObjectName
//    //Method Name
//    //Object
//    func addObserver(notificationName: String, objectName: AnyObject, methodName: Selector, object: AnyObject?) {
//        let notification = Notification(thisName: notificationName, thisClassName: objectName, thisMethodName: methodName, thisObject: object)
//        var array = notifications![notificationName]
//
//        guard let arrayObj = array else {
//            array = Array<Notification>()
//                array?.append(notification)
//                notifications![notificationName] = array
//            return
//        }
//        notifications![notificationName]?.append(notification)
//    }
//
//    func postNotification(notificationName: String) {
//        guard let notification = notifications![notificationName] else {
//                return
//            }
//            for notify in notification {
//                let objectName = notify.objectName
//                let methodName = notify.methodName
//                _ = objectName.perform(methodName)
//            }
//    }
//
//    func postNotification(notificationName: String, object: AnyObject) {
//
//        guard let notification = notifications![notificationName] else {
//            return
//        }
//        for notify in notification {
//            let objectName = notify.objectName
//            let methodName = notify.methodName
//            if object === notify.object {
//                _ = objectName.perform(methodName, with: object)
//            }
//        }
//    }
//
//    func postNotification(notificationName: String, userInfo: Any) {
//
//        guard let notification = notifications![notificationName] else {
//            return
//        }
//        for notify in notification {
//            let objectName = notify.objectName
//            let methodName = notify.methodName
//            _ = objectName.perform(methodName, with: ["userInfo" : userInfo])
//        }
//    }
//    func removeObserver(notification: String) {
//        if notification.count > 0 {
//            notifications?.removeValue(forKey: notification)
//        }
//    }
//}
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
          let testA = TestA()
          let testB = TestB()
          testA.registerNotifications()
          //NotificationCenter.sharedInstance.postNotification(notificationName: "viewisloaded", object: testB)
          //testB.postNotifications()
          let testC = TestC()
          testC.postNotifications()
          //testA.removeNotification()
          testB.postNotifications()
    }

}


class TestA {
    func registerNotifications() {
        NotificationCenter.sharedInstance.addObserver(notificationName: "viewisloaded",
                                                      objectName: self,
                                                      methodName: #selector(displayNoParams),
                                                      object: nil)
        
        NotificationCenter.sharedInstance.addObserver(notificationName: "viewisloaded1",
                                                      objectName: self,
                                                      methodName: #selector(displayClassName(_:)),
                                                      object: nil)
    }
    @objc func displayClassName(_ userInfo : NSDictionary) {
        print("TestA viewisloaded1 ", userInfo.allValues)
    }
    @objc func displayNoParams() {
        print("TestA viewisloaded")
    }
    
    func removeNotification() {
        NotificationCenter.sharedInstance.removeObserver(objectName: self, notification: "viewisloaded")
        NotificationCenter.sharedInstance.removeObserver(notification: "viewisloaded1")
    }
    deinit {
          print("TestA Deinit Called")
      }
}

class TestB {
    func postNotifications() {
        NotificationCenter.sharedInstance.postNotification(notificationName: "viewisloaded")
        NotificationCenter.sharedInstance.postNotification(notificationName: "viewisloaded1", userInfo: "this is userInfo")
        NotificationCenter.sharedInstance.postNotification(notificationName: "viewisloaded1", userInfo: "this is 2userInfo")
    }
    deinit {
        print("TestB Deinit Called")
    }
}

class TestC {
    func postNotifications() {
        NotificationCenter.sharedInstance.postNotification(notificationName: "viewisloaded", object: self)
    }
    deinit {
        print("Test C Deinit Called")
    }
}
