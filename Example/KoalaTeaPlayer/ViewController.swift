//
//  ViewController.swift
//  KoalaTeaPlayer
//
//  Created by themisterholliday on 09/08/2017.
//  Copyright (c) 2017 themisterholliday. All rights reserved.
//

import UIKit
import KoalaTeaPlayer

import AVFoundation

class ViewController: UIViewController {
    
    public var asset: Asset! {
        didSet {
            setupPlayback()
        }
    }
    
    var playerView = PlayerView()
    
    // The instance of `AssetPlaybackManager` that the app uses for managing playback.
    public var assetPlaybackManager: AssetPlayer!
    public var remoteCommandManager: RemoteCommandManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        let movieURL = Bundle.main.url(forResource: "ElephantSeals", withExtension: "mov")!
        let urlString = "http://traffic.libsyn.com/sedaily/PeriscopeData.mp3"
        //        let urlString = "http://wpc.1765A.taucdn.net/801765A/video/uploads/videos/65c3a707-016e-474c-8838-c295bb491a16/index.m3u8"
        let movieURL = URL(string: urlString)
        
        let artworkURL = URL(string: "https://www.w3schools.com/w3images/fjords.jpg")
//        let savedTimeInSeconds: Float = 1000
        let asset = Asset(assetName: "Test", url: movieURL!, artworkURL: artworkURL)
        self.asset = asset
        self.assetPlaybackManager.changePlayerPlaybackRate(to: 2.0)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 40) {
            self.asset = nil
//            print("HERE")
//            // Your code with delay
//            self.assetPlaybackManager.setState(to: .paused)
//
//            for count in 1...10 {
//                let time = 5 * count
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(time)) {
//                    print("here 2")
//                    // Your code with delay
//                    //                self.assetPlaybackManager.setState(to: .playing)
//                    self.asset = asset
//                }
//            }
        }
    }
    
    // Mark: - Asset Playback Manager Setup
    public func setupPlayback() {
        self.assetPlaybackManager = AssetPlayer(asset: asset)
        self.assetPlaybackManager.playerDelegate = self
        
        // Set playbackmanager for controls view so we can check state there
//        setupRemoteCommandManager()
        setupPlayerView()
    }
    
    public func setupRemoteCommandManager() {
        // Initializer the `RemoteCommandManager`.
        remoteCommandManager = RemoteCommandManager(assetPlaybackManager: assetPlaybackManager)
        
        // Always enable playback commands in MPRemoteCommandCenter.
        remoteCommandManager.activatePlaybackCommands(true)
        remoteCommandManager.toggleChangePlaybackPositionCommand(true)
        remoteCommandManager.toggleSkipBackwardCommand(true, interval: 30)
        remoteCommandManager.toggleSkipForwardCommand(true, interval: 30)
    }
    
    fileprivate func setupPlayerView() {
        self.playerView = assetPlaybackManager.playerView!
        self.view.addSubview(self.playerView)
        self.playerView.frame = self.view.frame
    }
}

extension ViewController: AssetPlayerDelegate {
    func playerIsSetup(_ player: AssetPlayer) {
        // Max values and initial values should be setup
        // Setup duration text
        print(player.durationText, "is setup")
        // Setup TimeSlider max value
    }
    
    func currentAssetDidChange(_ player: AssetPlayer) {
        // Asset changed
        // @TODO: maybe remove this
        print("asset changed")
    }
    
    func playerPlaybackStateDidChange(_ player: AssetPlayer) {
        // player.state changed
        print("state changed")
        // Handle state changes like enabling and disabling play/pause buttons
    }
    
    func playerCurrentTimeDidChange(_ player: AssetPlayer) {
        // Current time changed, update sliders accordingly
        print("currentTime changed")
        print(player.currentTime)
        print(player.timeElapsedText)
        print(player.timeLeftText)
    }
    
    func playerPlaybackDidEnd(_ player: AssetPlayer) {
        // Video or audio finished
        // Please clean up your player view
        print("playback did end")
    }
    
    // Buffering Functions
    func playerIsLikelyToKeepUp(_ player: AssetPlayer) {
        // Amount of buffer time is in the green
        print("playback likely to keep")
    }
    
    func playerBufferTimeDidChange(_ player: AssetPlayer) {
        // Update the buffer slider if you have one
        print("buffer time change")
    }
}

