
//
//  AppDelegate.swift
//  KoalaTeaPlayer
//
//  Created by themisterholliday on 09/27/2017.
//  Copyright (c) 2017 themisterholliday. All rights reserved.
//

import UIKit
import KoalaTeaPlayer
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var ytViewController: YTViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.setupFirstScreen()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Set player to nil to continue audio
        ytViewController?.removeAVPlayer()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Restore player
        ytViewController?.restoreAVPlayer()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    func setupFirstScreen() {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let rootVC = TableViewController(style: .plain)
        ytViewController = YTViewController(rootViewController: rootVC)

        window!.rootViewController = ytViewController
        window!.makeKeyAndVisible()
    }
}

