//
//  NavVC.swift
//  KoalaTeaPlayer
//
//  Created by Craig Holliday on 8/18/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit

public class YTPlayerViewNavigationController: UINavigationController  {
    
    //MARK: Properties
    var ytPlayerView: YTPlayerView!
    
    let hiddenOrigin: CGPoint = {
        let y = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 9 / 32) - 10
        let x = -UIScreen.main.bounds.width
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    let minimizedOrigin: CGPoint = {
        let x = UIScreen.main.bounds.width/2 - 10
        let y = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 9 / 32) - 10
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    let fullScreenOrigin = CGPoint.init(x: 0, y: 0)
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let videoUrl = URL(string: "http://wpc.1765A.taucdn.net/801765A/video/uploads/videos/65c3a707-016e-474c-8838-c295bb491a16/index.m3u8")
        let asset = Asset(assetName: "test", url: videoUrl!)
        let frame = CGRect(x: 0, y: 0, width: self.view.width, height: (self.view.width / (16/9)))
        ytPlayerView = YTPlayerView(frame: frame)
        ytPlayerView.asset = asset
        
        self.ytPlayerView.delegate = self
        
        self.view.addSubview(ytPlayerView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChange), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc func orientationChange() {
        self.ytPlayerView.orientationChange()
    }
    
    override public var shouldAutorotate: Bool {
        return false
    }
}

extension YTPlayerViewNavigationController: YTPlayerViewDelegate {
    func animatePlayView(toState: YTPlayerState) {
//        switch toState {
//        case .fullScreen:
//            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [.beginFromCurrentState], animations: {
//                self.ytPlayerView.frame.origin = self.fullScreenOrigin
//            })
//        case .minimized:
//            UIView.animate(withDuration: 0.3, animations: {
//                self.ytPlayerView.frame.origin = self.minimizedOrigin
//            })
//        case .hidden:
//            UIView.animate(withDuration: 0.3, animations: {
//                self.ytPlayerView.frame.origin = self.hiddenOrigin
//            })
//        }
    }
    
    func positionDuringSwipe(scaleFactor: CGFloat) -> CGPoint {
        let width = UIScreen.main.bounds.width * 0.5 * scaleFactor
        let height = width * 9 / 16
        let x = (UIScreen.main.bounds.width - 10) * scaleFactor - width
        let y = (UIScreen.main.bounds.height - 10) * scaleFactor - height
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }
    
    //MARK: Delegate methods
    public func didMinimize() {
//        self.animatePlayView(toState: .minimized)
    }
    
    public func didmaximize(){
//        self.animatePlayView(toState: .portrait)
    }
    
    public func didEndedSwipe(toState: YTPlayerState){
//        self.animatePlayView(toState: toState)
    }
    
    public func swipeToMinimize(translation: CGFloat, toState: YTPlayerState){
//        switch toState {
//        case .fullScreen:
//            self.ytPlayerView.frame.origin = self.positionDuringSwipe(scaleFactor: translation)
//        case .hidden:
//            self.ytPlayerView.frame.origin.x = UIScreen.main.bounds.width/2 - abs(translation) - 10
//        case .minimized:
//            self.ytPlayerView.frame.origin = self.positionDuringSwipe(scaleFactor: translation)
//        }
    }
}
