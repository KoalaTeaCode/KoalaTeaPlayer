//
//  PassThroughView.swift
//  KoalaTeaPlayer
//
//  Created by Craig Holliday on 8/8/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit

public class PassThroughView: UIView {
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}
