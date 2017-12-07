//
//  SkipControlIconButton.swift
//  KoalaTeaPlayer
//
//  Created by Craig Holliday on 8/8/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit

class SkipControlIconButton: UIButton {
    var isFlashing = false
    var isBackwards = false
    var secondsCount: Int = 10
    
    var label = UILabel()
    var contentView = UIView()
    
    var icon1 = UIImageView()
    var icon2 = UIImageView()
    var icon3 = UIImageView()
    
    let iconSize = CGSize(width: UIView.getValueScaledByScreenWidthFor(baseValue: 20), height: UIView.getValueScaledByScreenHeightFor(baseValue: 20))
    
    init(frame: CGRect, isBackwards: Bool = false) {
        self.isBackwards = isBackwards
        super.init(frame: frame)
        setIfBackwards()
        
        contentView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        contentView.backgroundColor = .white
        contentView.alpha = 0
        contentView.isUserInteractionEnabled = false
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(label)
        label.alpha = 0
        label.textColor = .white
        label.anchorCenterXToSuperview()
        label.anchorCenterYToSuperview(constant: UIView.getValueScaledByScreenHeightFor(baseValue: 30))
        
        icon1.setIcon(icon: .fontAwesome(.play), textColor: .white, backgroundColor: .clear, size: iconSize)
        icon2.setIcon(icon: .fontAwesome(.play), textColor: .white, backgroundColor: .clear, size: iconSize)
        icon3.setIcon(icon: .fontAwesome(.play), textColor: .white, backgroundColor: .clear, size: iconSize)
        
        self.addSubview(icon1)
        icon1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        icon1.alpha = 0
        icon1.anchorCenterXToSuperview(constant: UIView.getValueScaledByScreenWidthFor(baseValue: -20))
        icon1.anchorCenterYToSuperview()
        
        self.addSubview(icon2)
        icon2.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        icon2.alpha = 0
        icon2.anchorCenterXToSuperview()
        icon2.anchorCenterYToSuperview()
        
        self.addSubview(icon3)
        icon3.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        icon3.alpha = 0
        icon3.anchorCenterXToSuperview(constant: UIView.getValueScaledByScreenWidthFor(baseValue: 20))
        icon3.anchorCenterYToSuperview()
    }
    
    func setIfBackwards() {
        guard self.isBackwards else { return }
        icon1.setIcon(icon: .fontAwesome(.play), textColor: .white, backgroundColor: .clear, size: iconSize)
        icon2.setIcon(icon: .fontAwesome(.play), textColor: .white, backgroundColor: .clear, size: iconSize)
        icon3.setIcon(icon: .fontAwesome(.play), textColor: .white, backgroundColor: .clear, size: iconSize)

        icon1.scale(by: CGPoint(x: -1.0, y: 1.0))
        icon2.scale(by: CGPoint(x: -1.0, y: 1.0))
        icon3.scale(by: CGPoint(x: -1.0, y: 1.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //@TODO: Fix when another flash comes in to update and reload
    
    func flashSelf(addSecondsCount: Int) {
        //@TODO: See about setting flashing to stop
//        guard !self.isFlashing else { return }
        self.isFlashing = true
        //@TODO: Fix adding 10 to label every flash
//        secondsCount += addSecondsCount
        label.text = String(secondsCount) + " Seconds"
        let duration = 0.4
        self.flashIcons()
        UIView.animate(withDuration: duration, animations: {
            self.label.alpha = 1
            self.contentView.alpha = 0.4
        }, completion: { _ in
            UIView.animate(withDuration: duration, animations: {
                self.label.alpha = 0
                self.contentView.alpha = 0
            })
            self.isFlashing = false
        })
    }
    
    func flashIcons() {
        if self.isBackwards {
            self.flashIconsBackwards()
            return
        }
        
        let durationIn = 0.4 / 3
        let durationOut = 0.4 / 4
        icon1.fadeIn(duration: durationIn, completion: { _ in
            self.icon1.fadeOut(duration: durationOut, completion: nil)
            self.icon2.fadeIn(duration: durationIn, completion: { _ in
                self.icon2.fadeOut(duration: durationOut, completion: nil)
                self.icon3.fadeIn(duration: durationIn, completion: { _ in
                    self.icon3.fadeOut(duration: durationOut, completion: nil)
                })
            })
        })
    }
    
    func flashIconsBackwards() {
        let durationIn = 0.4 / 3
        let durationOut = 0.4 / 4

        icon3.fadeIn(duration: durationIn, completion: { _ in
            self.icon3.fadeOut(duration: durationOut, completion: nil)
            self.icon2.fadeIn(duration: durationIn, completion: { _ in
                self.icon2.fadeOut(duration: durationOut, completion: nil)
                self.icon1.fadeIn(duration: durationIn, completion: { _ in
                    self.icon1.fadeOut(duration: durationOut, completion: nil)
                })
            })
        })
    }
}
