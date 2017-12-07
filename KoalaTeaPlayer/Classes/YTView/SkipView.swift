//
//  SkipView.swift
//  KoalaTeaPlayer
//
//  Created by Craig Holliday on 8/8/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SnapKit

/// Player delegate protocol
public protocol SkipViewDelegate: NSObjectProtocol {
    func skipForwardButtonPressed()
    func skipBackwardButtonPressed()
    func singleTap()
}

public class SkipView: UIView {
    open weak var delegate: SkipViewDelegate?
    
    var skipForwardButton: SkipControlIconButton!
    var skipBackwardbutton: SkipControlIconButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        skipForwardButton = SkipControlIconButton(frame: CGRect(x: self.frame.maxX - self.width / 3, y: 0, width: self.width / 3, height: self.height))
        skipBackwardbutton = SkipControlIconButton(frame: CGRect(x: self.frame.minX, y: 0, width: self.width / 3, height: self.height), isBackwards: true)
        
        self.addSubview(skipForwardButton)
        self.addSubview(skipBackwardbutton)
        
        skipForwardButton.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        skipBackwardbutton.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        skipBackwardbutton.addTarget(self, action: #selector(self.skipBackwardButtonPressed(_:)), for: .touchDown)
        skipForwardButton.addTarget(self, action: #selector(self.skipForwardButtonPressed(_:)), for: .touchDown)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented"); }
    
    func enableAllButtons() {
        self.skipBackwardbutton.isEnabled = true
        self.skipForwardButton.isEnabled = true
    }
    
    func disableAllButtons() {
        self.skipBackwardbutton.isEnabled = false
        self.skipForwardButton.isEnabled = false
    }
    
    func flashForwardButton() {
        // Add 10 to label
        
        // Flash View
        skipForwardButton.flashSelf(addSecondsCount: 10)
    }
    
    func flashBackwardButton() {
        // Add 10 to label
        
        // Flash View
        skipBackwardbutton.flashSelf(addSecondsCount: 10)
    }
    
    var taps = 0
}

extension SkipView {
    // MARK: Function
    @objc func skipForwardButtonPressed(_ sender: UIButton) {
        twoTapCheck(isBackward: false)
    }
    
    @objc func skipBackwardButtonPressed(_ sender: UITapGestureRecognizer) {
        twoTapCheck(isBackward: true)
    }
    
    func twoTapCheck(isBackward: Bool) {
        taps += 1
        if (taps >= 2) {
            switch isBackward {
            case true:
                flashBackwardButton()
                delegate?.skipBackwardButtonPressed()
            case false:
                flashForwardButton()
                delegate?.skipForwardButtonPressed()
            }
            taps = 0
            return
        }
        self.singleTapCheck()
    }
    
    @objc func viewTapped(_ sender: UIButton) {
        self.delegate?.singleTap()
        self.taps = 0
    }
    
    func singleTapCheck() {
        Helpers.wait(time: 0.25, completion: {
            guard self.taps == 1 else { return }
            self.delegate?.singleTap()
            self.taps = 0
        })
    }
}
