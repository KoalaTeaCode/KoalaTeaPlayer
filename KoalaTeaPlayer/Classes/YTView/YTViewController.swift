//
//  YTViewController.swift
//  KoalaTeaPlayer_Example
//
//  Created by Craig Holliday on 9/8/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

public protocol YTViewControllerDelegate: NSObjectProtocol {
    func didMinimize()
    func didmaximize()
    func didSwipeAway()
}

public class YTViewController: UINavigationController {
    let hiddenOrigin: CGPoint = {
        let y = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 9 / 32) - 10
        let x = -UIScreen.main.bounds.width
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    
    // @TODO: abstract container view
    public var ytPlayerView: YTPlayerView? = nil
    public var bottomView: UIView? = nil
    public let containerView: UIView = UIView(frame: .zero)
    
    public weak var ytViewControllerDelegate: YTViewControllerDelegate?
    private var storedAVPlayer: AVPlayer?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(containerView)
        self.containerView.backgroundColor = .white
        self.containerView.isUserInteractionEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChange), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    public func loadYTPlayerViewWith(assetName: String, videoURL: URL, artworkURL: URL? = nil, savedTime: Float = 0) {
        self.containerView.frame = self.view.frame
        
        if ytPlayerView != nil {
            ytPlayerView?.deleteSelf()
            ytPlayerView = nil
        }
        
        // Player View
        let asset = Asset(assetName: assetName, url: videoURL, artworkURL: artworkURL, savedTime: savedTime)
        let frame = CGRect(x: 0, y: 0, width: self.view.width, height: (self.view.width / (16/9)))
        ytPlayerView = YTPlayerView(frame: frame)
        guard let ytPlayerView = ytPlayerView else { return }
        UIView.animate(withDuration: 0.25) {
            ytPlayerView.layoutIfNeeded()
        }
        ytPlayerView.asset = asset
        ytPlayerView.delegate = self
        
        // Bottom View
        let height = (self.view.height - ytPlayerView.height)
        let bottomFrame = CGRect(origin: ytPlayerView.bottomLeftPoint(), size: CGSize(width: self.view.width, height: height))
        self.bottomView = UIView(frame: bottomFrame)
        guard let bottomView = bottomView else { return }
        self.bottomView?.backgroundColor = .white
        
        UIView.animate(withDuration: 0.25) {
            bottomView.layoutIfNeeded()
        }
        
        self.view.addSubview(bottomView)
        self.view.addSubview(ytPlayerView)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func orientationChange() {
        self.ytPlayerView?.orientationChange()
    }
    
    override public var shouldAutorotate: Bool {
        return false
    }
    
    public func removeAVPlayer() {
        // Retain current player
        self.storedAVPlayer = self.ytPlayerView?.assetPlayer?.playerView?.player
        // Set player to nil to continue audio
        self.ytPlayerView?.assetPlayer?.playerView?.player = nil
    }
    
    public func restoreAVPlayer() {
        self.ytPlayerView?.assetPlayer?.playerView?.player = self.storedAVPlayer
    }
}

extension YTViewController: YTPlayerViewDelegate {
    public func animatePlayView(to state: YTPlayerState) {
        switch state {
        case .landscapeLeft:
            break
        case .landscapeRight:
            break
        case .portrait:
            break
        case .minimized:
            break
        case .hidden:
            UIView.animate(withDuration: 0.25, animations: {
                self.ytPlayerView?.frame.origin = self.hiddenOrigin
            }, completion: { (_) in
                self.ytPlayerView?.deleteSelf()
                self.ytPlayerView = nil
                
                self.bottomView?.removeFromSuperview()
                self.bottomView = nil
            })
            self.containerView.frame = .zero
            self.ytViewControllerDelegate?.didSwipeAway()
            break
        }
    }
    
    public func didMinimize() {
        self.ytViewControllerDelegate?.didMinimize()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomView?.backgroundColor = .clear
            self.bottomView?.isUserInteractionEnabled = false
        })
        
        self.containerView.frame = .zero
    }
    
    public func didmaximize() {
        self.ytViewControllerDelegate?.didmaximize()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomView?.backgroundColor = .white
            self.bottomView?.isUserInteractionEnabled = true
        })
        
        self.containerView.frame = self.view.frame
    }
    
    public func swipeToMinimize(translation: CGFloat, toState: YTPlayerState) {
    }
    
    public func didEndedSwipe(toState: YTPlayerState) {
        self.animatePlayView(to: toState)
    }
}

