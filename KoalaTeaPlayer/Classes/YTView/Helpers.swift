//
//  Helpers.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//


import UIKit
import SwifterSwift

extension Helpers {
    static var alert: UIAlertController!
    
    enum Alerts {
        static let error = "Error"
        static let success = "Success"
    }
    
    enum Messages {
    }
}

class Helpers {
    static func alertWithMessage(title: String!, message: String!, completionHandler: (() -> ())? = nil) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            guard !(topController is UIAlertController) else {
                // There's already a alert preseneted
                return
            }
            
            alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            topController.present(alert, animated: true, completion: nil)
            completionHandler?()
        }
    }
    
    static func wait(time: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            completion()
        }
    }
    
    /*
     A formatter for individual date components used to provide an appropriate
     value for the `startTimeLabel` and `durationLabel`.
     */
    static let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()
    
    static func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
}
