//
//  PlayerView.swift
//  KoalaTeaPlayer
//
//  Created by Craig Holliday on 8/3/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

public enum Direction {
    case up
    case left
    case none
}

public enum YTPlayerState {
    case landscapeLeft
    case landscapeRight
    case portrait
    case minimized
    case hidden
}

public protocol YTPlayerViewDelegate: NSObjectProtocol {
    func didMinimize()
    func didmaximize()
    func swipeToMinimize(translation: CGFloat, toState: YTPlayerState)
    func didEndedSwipe(toState: YTPlayerState)
}

public extension CGAffineTransform {
    init(from: CGRect, toRect to: CGRect) {
        self.init(translationX: to.minX-from.minX, y: to.minY-from.minY)
        self = self.scaledBy(x: to.width/from.width, y: to.height/from.height)
    }
}

public class YTPlayerView: UIView {
    /// The instance of `AssetPlaybackManager` that the app uses for managing playback.
    public var assetPlayer: AssetPlayer?
    public var remoteCommandManager: RemoteCommandManager?
    
    public var playerView: PlayerView?
    public var controlsView: ControlsView?
    public var skipView: SkipView?
    
    public weak var delegate: YTPlayerViewDelegate?
    public var direction = Direction.none
    public var state = YTPlayerState.portrait {
        didSet {
            self.animate(to: self.state)
        }
    }

    public var isRotated: Bool {
        get {
            return self.state == .landscapeLeft || self.state == .landscapeRight
        }
    }
    
    public var asset: Asset? {
        didSet {
            setupPlayback()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        self.performLayout()
        self.setupGestureRecognizer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("player view deinit")
    }
    
    public func deleteSelf() {
        self.assetPlayer?.stop()
        self.assetPlayer = nil
        self.remoteCommandManager = nil
        self.playerView = nil
        self.controlsView = nil
        self.skipView = nil
        self.delegate = nil
        self.removeFromSuperview()
    }
    
    // Mark: - Asset Playback Manager Setup
    public func setupPlayback() {
        self.assetPlayer = AssetPlayer(asset: asset)
        self.assetPlayer?.playerDelegate = self
        
        // Set playbackmanager for controls view so we can check state there
        self.controlsView?.assetPlaybackManager = assetPlayer
        setupRemoteCommandManager()
        setupPlayerView()
    }
    
    public func setupRemoteCommandManager() {
        // Initializer the `RemoteCommandManager`.
        guard let assetPlayer = assetPlayer else { return }
        remoteCommandManager = RemoteCommandManager(assetPlaybackManager: assetPlayer)
        
        // Always enable playback commands in MPRemoteCommandCenter.
        remoteCommandManager?.activatePlaybackCommands(true)
        remoteCommandManager?.toggleChangePlaybackPositionCommand(true)
        remoteCommandManager?.toggleSkipBackwardCommand(true, interval: 10)
        remoteCommandManager?.toggleSkipForwardCommand(true, interval: 10)
    }
    
    public override func performLayout() {
        skipView = SkipView()
        self.skipView?.delegate = self
        guard let skipView = skipView else { return }
        self.addSubview(skipView)
        self.skipView?.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        controlsView = ControlsView()
        self.controlsView?.delegate = self
        guard let controlsView = controlsView else { return }
        self.addSubview(controlsView)
        self.controlsView?.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    fileprivate func setupPlayerView() {
        self.playerView = assetPlayer?.playerView
        guard let playerView = playerView else { return }
        self.addSubview(playerView)
        self.playerView?.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.sendSubview(toBack: playerView)
    }
    
    fileprivate func handleAssetPlaybackManagerStateChange(to state: AssetPlayerPlaybackState) {
        print(state)
        switch state {
        case .setup:
            controlsView?.disableAllButtons()
            controlsView?.activityView.startAnimating()
            
            controlsView?.playButton.isHidden = false
            controlsView?.pauseButton.isHidden = true
            break
        case .playing:
            controlsView?.enableAllButtons()
            controlsView?.activityView.stopAnimating()
            
            controlsView?.playButton.isHidden = true
            controlsView?.pauseButton.isHidden = false

            self.controlsView?.waitAndFadeOut()
            break
        case .paused:
            controlsView?.activityView.stopAnimating()
            
            controlsView?.playButton.isHidden = false
            controlsView?.pauseButton.isHidden = true
            break
        case .interrupted:
            print("Interuppted state")
            break
        case .failed:
            break
        case .buffering:
            controlsView?.activityView.startAnimating()
            
            controlsView?.playButton.isHidden = true
            controlsView?.pauseButton.isHidden = true
            break
        case .stopped:
            break
        }
    }
    
    public func orientationChange() {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            self.state = .landscapeLeft
            break
        case .landscapeRight:
            self.state = .landscapeRight
            break
        case .portrait:
            self.state = .portrait
            break
        case .portraitUpsideDown:
            break
        case .unknown:
            break
        case .faceUp:
            break
        case .faceDown:
            break
        }
    }
}

extension YTPlayerView: AssetPlayerDelegate {
    public func currentAssetDidChange(_ player: AssetPlayer) {
    }
    
    public func playerIsSetup(_ player: AssetPlayer) {
        self.playerView = assetPlayer?.playerView
        self.controlsView?.playbackSliderView?.updateSlider(maxValue: player.maxSecondValue)
    }
    
    public func playerPlaybackStateDidChange(_ player: AssetPlayer) {
        guard let state = player.state else { return }
        self.handleAssetPlaybackManagerStateChange(to: state)
    }
    
    public func playerCurrentTimeDidChange(_ player: AssetPlayer) {
        self.controlsView?.playbackSliderView?.updateTimeLabels(currentTimeText: player.timeElapsedText, timeLeftText: player.timeLeftText)
        self.controlsView?.playbackSliderView?.updateSlider(currentValue: Float(player.currentTime))
    }
    
    public func playerPlaybackDidEnd(_ player: AssetPlayer) {
        //@TODO: Add back current time tracking
//        podcastModel?.update(currentTime: 0.0)
    }
    
    public func playerIsLikelyToKeepUp(_ player: AssetPlayer) {
        //@TODO: Nothing to do here?
    }
    
    public func playerBufferTimeDidChange(_ player: AssetPlayer) {
        guard let assetPlayer = assetPlayer else { return }
        self.controlsView?.playbackSliderView?.updateBufferSlider(bufferValue: assetPlayer.bufferedTime)
    }
}

extension YTPlayerView: ControlsViewDelegate {
    public func minimizeButtonPressed() {
        self.minimize()
    }

    public func playButtonPressed() {
        self.assetPlayer?.play()
    }

    public func pauseButtonPressed() {
        self.assetPlayer?.pause()
    }

    public func playbackSliderValueChanged(value: Float) {
        assetPlayer?.seekTo(interval: TimeInterval(value))
    }
    
    public func fullscreenButtonPressed() {
        switch self.isRotated {
        case true:
            self.state = .portrait
        case false:
            self.state = .landscapeLeft
        }
    }
    
    func handleStateChangeforControlView() {
        switch self.state {
        case .minimized:
            self.controlsView?.fadeSelfOut()
            self.controlsView?.fadeOutSliders()
        case .landscapeLeft, .landscapeRight:
            self.controlsView?.setRotatedConstraints()
            self.controlsView?.minimizeButton.isHidden = true
        case .portrait:
            self.controlsView?.fadeSelfIn()
            self.controlsView?.fadeInSliders()
            self.controlsView?.setDefaultConstraints()
            self.controlsView?.minimizeButton.isHidden = false
        case .hidden:
            break
        }
    }
}

extension YTPlayerView: SkipViewDelegate {
    public func skipForwardButtonPressed() {
        self.controlsView?.fadeSelfOut()
        self.assetPlayer?.skipForward(10)
    }
    
    public func skipBackwardButtonPressed() {
        self.controlsView?.fadeSelfOut()
        self.assetPlayer?.skipBackward(10)
    }
    
    public func singleTap() {
        guard self.state != .minimized else {
            self.state = .portrait
            self.delegate?.didmaximize()
            return
        }
        guard let controlsView = controlsView else { return }
        switch controlsView.isVisible {
        case true:
            self.controlsView?.fadeSelfOut()
            break
        case false:
            self.controlsView?.fadeSelfIn()
            break
        }
    }
}

extension YTPlayerView: UIGestureRecognizerDelegate {
    func animate(to: YTPlayerState) {
        guard let superView = self.superview else { return }
        
        let originPoint = CGPoint(x: 0, y: 0)
        self.layer.anchorPoint = originPoint

        switch self.state {
        case .minimized:
            UIView.animate(withDuration: 0.3, animations: {
                
                self.width = UIView.getValueScaledByScreenWidthFor(baseValue: 200)
                self.height = self.width / (16/9)

                let x = superView.frame.maxX - self.width - 10
                let y = superView.frame.maxY - self.height - 10
                self.layer.position = CGPoint(x: x, y: y)
            })
            self.delegate?.didMinimize()
        case .landscapeLeft:
            self.controlsView?.isRotated = true
            UIView.animate(withDuration: 0.3, animations: {
                // This is an EXACT order for left and right
                // Transform > Change height and width > Change layer position
                let newTransform = CGAffineTransform(rotationAngle: (CGFloat.pi / 2))
                self.transform = newTransform
                
                self.height = superView.height
                self.width = superView.width
                
                self.layer.position = CGPoint(x: superView.frame.maxX, y: 0)
            })
        case .landscapeRight:
            self.controlsView?.isRotated = true
            UIView.animate(withDuration: 0.3, animations: {
                // This is an EXACT order for left and right
                // Transform > Change height and width > Change layer position
                let newTransform = CGAffineTransform(rotationAngle: -(CGFloat.pi / 2))
                self.transform = newTransform
                
                self.height = superView.height
                self.width = superView.width
                
                self.layer.position = CGPoint(x: 0, y: superView.frame.maxY)
            })
        case .portrait:
            self.controlsView?.isRotated = false
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform.identity
                self.layer.position = CGPoint(x: 0, y: 0)
                
                self.height = superView.width / (16/9)
                self.width = superView.width
            })
            self.delegate?.didmaximize()
        case .hidden:
            break
        }
        
        self.handleStateChangeforControlView()
    }
    
    func minimize() {
        self.state = .minimized
        self.delegate?.didMinimize()
    }
    
    func setupGestureRecognizer() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.minimizeGesture(_:)))
        gestureRecognizer.delegate = self
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func minimizeGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            let velocity = sender.velocity(in: nil)
            if abs(velocity.x) < abs(velocity.y) {
                self.direction = .up
            } else {
                self.direction = .left
            }
        }
        var finalState = YTPlayerState.portrait
        switch self.state {
        case .portrait:
//            let factor = (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
//            self.changeValues(scaleFactor: factor)
//            self.delegate?.swipeToMinimize(translation: factor, toState: .minimized)
//            finalState = .minimized
            break
        case .minimized:
            if self.direction == .left {
                finalState = .hidden
                let factor: CGFloat = sender.translation(in: nil).x
                self.delegate?.swipeToMinimize(translation: factor, toState: .hidden)
            } else {
                finalState = .portrait
                let factor = 1 - (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
                self.changeValues(scaleFactor: factor)
                self.delegate?.swipeToMinimize(translation: factor, toState: .portrait)
            }
        default: break
        }
        if sender.state == .ended {
            self.state = finalState
            self.delegate?.didEndedSwipe(toState: self.state)
            if self.state == .hidden {
                self.assetPlayer?.pause()
            }
        }
    }
    
    func changeValues(scaleFactor: CGFloat) {
        self.controlsView?.minimizeButton.alpha = 1 - scaleFactor
//        self.alpha = 1 - scaleFactor
        let scale = CGAffineTransform.init(scaleX: (1 - 0.5 * scaleFactor), y: (1 - 0.5 * scaleFactor))
        let trasform = scale.concatenating(CGAffineTransform.init(translationX: -(self.bounds.width / 4 * scaleFactor), y: -(self.bounds.height / 4 * scaleFactor)))
        self.transform = trasform
    }
}
