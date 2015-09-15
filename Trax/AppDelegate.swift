//
//  AppDelegate.swift
//  Trax
//
//  Created by Alexey Tsymlov on 9/14/15.
//  Copyright (c) 2015 Alexey Tsymlov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        println("url = \(url)")
        return true
    }

}

