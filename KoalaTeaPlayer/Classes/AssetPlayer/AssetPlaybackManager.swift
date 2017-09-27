//
//  Player.swift
//  KoalaTeaPlayer
//
//  Created by Craig Holliday on 8/4/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

// @TODO: 🛑🛑🛑 This is being removed 🛑🛑🛑

import AVFoundation
import MediaPlayer

// MARK: - PlayerDelegate

// Player delegate protocol
public protocol AssetPlaybackManagerDelegate: NSObjectProtocol {
    // Initial
    func currentAssetDidChange(_ player: AssetPlaybackManager)
    func playerReady(_ player: AssetPlaybackManager)
    
    // Playback
    func playerPlaybackStateDidChange(_ player: AssetPlaybackManager)
    func playerCurrentTimeDidChange(_ player: AssetPlaybackManager)
    func playerPlaybackDidEnd(_ player: AssetPlaybackManager)
    
    // Downloading
    func playerDidFinishDownloading(_ player: AssetPlaybackManager)
    func playerDownloadProgressDidChange(_ player: AssetPlaybackManager)
    
    // Buffering
    func playerIsLikelyToKeepUp(_ player: AssetPlaybackManager)
    // This is the time in seconds that the video has been buffered.
    // If implementing a UIProgressView, user this value / player.maximumDuration to set progress.
    func playerBufferTimeDidChange(_ player: AssetPlaybackManager)
}

/// An enumeration of possible playback states that `AssetPlaybackManager` can be in.
///
/// - initial: The playback state that `AssetPlaybackManager` starts in when nothing is playing.
/// - playing: The playback state that `AssetPlaybackManager` is in when its `AVPlayer` has a `rate` != 0.
/// - paused: The playback state that `AssetPlaybackManager` is in when its `AVPlayer` has a `rate` == 0.
/// - interrupted: The playback state that `AssetPlaybackManager` is in when audio is interrupted.
/// - failed: The asset failed to load into AVPlayer
/// - buffering: An asset has been set and the Asset is loading
/// - stopped: Was sent the stop command and should deinit or stop player
public enum PlaybackState: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    //@TODO is there a way to shorten this? (or auto generate)
    public static func ==(lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.setup(let lKey), .setup(let rKey)):
            return lKey == rKey
        case (.initial, .initial):
            return true
        case (.playing, .playing):
            return true
        case (.paused, .paused):
            return true
        case (.interrupted, .interrupted):
            return true
        case (.failed, .failed):
            return true
        case (.buffering, .buffering):
            return true
        case (.stopped, .stopped):
            return true
        default:
            return false
        }
    }

    case setup(asset: Asset?)
    case initial, playing, paused, interrupted, failed, buffering, stopped
}

public class AssetPlaybackManager: NSObject {
    /// Player delegate.
    open weak var playerDelegate: AssetPlaybackManagerDelegate?
    
    // MARK: Types
    
    /// Notification that is posted when the `nextTrack()` is called.
    fileprivate static let nextTrackNotification = Notification.Name("nextTrackNotification")
    
    /// Notification that is posted when the `previousTrack()` is called.
    fileprivate static let previousTrackNotification = Notification.Name("previousTrackNotification")
    
    /// Notification that is posted when currently playing `Asset` did change.
    static let currentAssetDidChangeNotification = Notification.Name("currentAssetDidChangeNotification")
    
    /// Notification that is posted when the internal AVPlayer rate did change.
    static let playerRateDidChangeNotification = Notification.Name("playerRateDidChangeNotification")
    
    // MARK: Properties
    
    /// The instance of `MPNowPlayingInfoCenter` that is used for updating metadata for the currently playing `Asset`.
    fileprivate let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    
    /// A token obtained from calling `player`'s `addPeriodicTimeObserverForInterval(_:queue:usingBlock:)` method.
    fileprivate var timeObserverToken: Any?
    
    /// The progress in percent for the playback of `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
    @objc dynamic var percentProgress: Float = 0
    
    /// The total duration in seconds for the `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
    @objc dynamic var duration: Float {
        guard let currentItem = self.avPlayer.currentItem else { return 0.0 }
        
        return Float(CMTimeGetSeconds(currentItem.duration))
    }
    
    /// The current playback position in seconds for the `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
    @objc dynamic var playbackPosition: Float {
        get {
            if let playerItem = self.playerItem {
                return Float(CMTimeGetSeconds(playerItem.currentTime()))
            } else {
                return 0
            }
        }
        set {
            guard self.playbackPosition != self.duration else { return }
            self.playerDelegate?.playerCurrentTimeDidChange(self)
        }
    }
    
    @objc dynamic var bufferedTime: Float = 0 {
        didSet {
            self.playerDelegate?.playerBufferTimeDidChange(self)
        }
    }
    
    /// The state that the internal `AVPlayer` is in.
    public var state: PlaybackState = .initial {
        didSet {
            print(state, "state changin")
            if state != oldValue {
                self.playerDelegate?.playerPlaybackStateDidChange(self)
                self.handleStateChange()
            }
        }
    }
    
    /// A Bool for tracking if playback should be resumed after an interruption.  See README.md for more information.
    fileprivate var shouldResumePlaybackAfterInterruption = true
    
    /// The instance of AVPlayer that will be used for playback of AssetPlaybackManager.playerItem.
    public var avPlayer: AVPlayer! {
        willSet {
            if avPlayer != nil {
                self.removePlayerObservers()
                self.removePlayerTimeObserver()
            }
        }
        didSet {
            if avPlayer != nil {
                self.addPlayerObservers()
                self.addPlayerTimeObserver()
            }
        }
    }
    
    @objc dynamic public var volume: Float = 0 {
        didSet {
            self.avPlayer.volume = self.volume
        }
    }
    
    /// The AVPlayerItem associated with AssetPlaybackManager.asset.urlAsset
    fileprivate var playerItem: AVPlayerItem! {
        willSet {
            if playerItem != nil {
                self.removePlayerItemObservers()
            }
        }
        didSet {
            if playerItem != nil {
                self.addPlayerItemObservers()
            }
        }
    }
    
    /// The Asset that is currently being loaded for playback.
    var asset: Asset! {
        willSet {
            if asset != nil {
                asset.urlAsset.removeObserver(self, forKeyPath: #keyPath(AVURLAsset.isPlayable), context: &PlayerItemObserverContext)
            }
        }
        didSet {
            if asset != nil {
                asset.urlAsset.addObserver(self, forKeyPath: #keyPath(AVURLAsset.isPlayable), options: [.initial, .new], context: &PlayerItemObserverContext)
                //@TODO: Add in saved time
//                if let savedTime = asset.savedTime {
//                    self.seekTo(TimeInterval(savedTime))
//                }
            }
            else {
                // Unload currentItem so that the state is updated globally.
                avPlayer.replaceCurrentItem(with: nil)
            }
            playerDelegate?.currentAssetDidChange(self)
        }
    }
    
    public var playerView: PlayerView? = PlayerView(frame: .zero) {
        willSet {
            guard newValue != nil else { return }
            if playerItem != nil {
                self.removePlayerLayerObservers()
            }
        }
        didSet {
            if playerItem != nil {
                self.addPlayerLayerObservers()
            }
        }
    }
    
    // MARK: Initialization
    
    public init(asset: Asset?) {
        super.init()
        // @TODO: Do we need this here
        guard asset != nil else { return }
        self.setStateTo(state: .setup(asset: asset))
    }
    
    deinit {
        removeAVAudioSessionObservers()
    }
    
    func handleStateChange() {
        switch self.state {
        case .initial:
            break
        case .setup(let asset):
            self.setupAVAudioSession()
            self.setupAVPlayer(with: AVPlayer())
            self.asset = asset
            break
        case .playing:
            guard self.asset != nil else { return }
            
            if shouldResumePlaybackAfterInterruption == false {
                shouldResumePlaybackAfterInterruption = true
                return
            }
            
            self.avPlayer.play()
            break
        case .paused:
            guard asset != nil else { return }
            
            if state == .interrupted {
                shouldResumePlaybackAfterInterruption = false
                
                return
            }
            
            self.avPlayer.pause()
            break
        case .interrupted:
            break
        case .failed:
            break
        case .buffering:
            guard asset != nil else { return }
            self.avPlayer.pause()
            break
        case .stopped:
            guard asset != nil else { return }
            
            asset = nil
            playerItem = nil
            self.avPlayer.replaceCurrentItem(with: nil)
            break
        }
    }
    
    // MARK: Setters
    
    // Method to set state so this can be called in init
    func setStateTo(state: PlaybackState) {
        self.state = state
    }
    
    func setupAVPlayer(with player: AVPlayer) {
        self.avPlayer = player
    }
    
    func replaceAVPlayer(with player: AVPlayer) {
        if self.avPlayer != nil {
            self.avPlayer = player
        }
    }
    
    func setupPlayerItem(with playerItem: AVPlayerItem) {
        DispatchQueue.main.async {
            //@TODO: guards here and everywhere in this
            self.playerItem = playerItem
            self.avPlayer.replaceCurrentItem(with: playerItem)
        }
    }
    
    // MARK: Notification Observing Methods
    
    @objc func handleAVPlayerItemDidPlayToEndTimeNotification(notification: Notification) {
        self.playerDelegate?.playerPlaybackDidEnd(self)
        self.state = .stopped
    }
    
    // MARK: Key-Value Observing Method
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        print(keyPath, "🤷")
        if (context == &PlayerItemObserverContext) {
            if keyPath == #keyPath(AVURLAsset.isPlayable) {
                if asset.urlAsset.isPlayable {
                    let playerItem = AVPlayerItem(asset: self.asset.urlAsset)
                    self.setupPlayerItem(with: playerItem)
                }
            }
            else if keyPath == #keyPath(AVPlayerItem.status) {
                if playerItem.status == .readyToPlay {
                    guard state != .paused else { return }
                    self.state = .playing
                }
            }
            else if keyPath == #keyPath(AVPlayer.currentItem) {
                // Cleanup if needed.
                if avPlayer.currentItem == nil {
                    if asset != nil { asset = nil }
                    if playerItem != nil { playerItem = nil }
                }
                
                updateGeneralMetadata()
            }
            else if keyPath == #keyPath(AVPlayer.rate) {
                updatePlaybackRateMetadata()
            }
                
            // All Buffer observer values
            else if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferEmpty) {
                // PlayerEmptyBufferKey
                if let item = self.playerItem {
                    if item.isPlaybackBufferEmpty {
                        guard state != .paused else { return }
                        self.state = .buffering
                    }
                }
                
                self.playerView?.playerLayer.player = self.avPlayer
                self.playerView?.playerLayer.isHidden = false
                //@TODO: check why statis isn't working or if we care
//                if let status = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
//                    switch (status.intValue as AVPlayerStatus.RawValue) {
//                    case AVPlayerStatus.readyToPlay.rawValue:
//                        self.playerView.playerLayer.player = self.avPlayer
//                        self.playerView.playerLayer.isHidden = false
//                        break
//                    case AVPlayerStatus.failed.rawValue:
//                        self.state = .failed
//                        break
//                    default:
//                        break
//                    }
//                }
            }
            else if keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp) {
                // PlayerKeepUpKey
                if let item = self.playerItem {
                    if item.isPlaybackLikelyToKeepUp {
                        if self.state == .buffering || self.state == .playing {
                            //@TODO: Check if this guard is breaking the rest of this section
                            guard state != .paused else { return }
                            self.playerDelegate?.playerIsLikelyToKeepUp(self)
                            self.state = .playing
                            return
                        }
                    }
                }
                
                self.playerView?.playerLayer.player = self.avPlayer
                self.playerView?.playerLayer.isHidden = false
//                if let status = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
//                    switch (status.intValue as AVPlayerStatus.RawValue) {
//                    case AVPlayerStatus.readyToPlay.rawValue:
//                        self.playerView.playerLayer.player = self.avPlayer
//                        self.playerView.playerLayer.isHidden = false
//                        break
//                    case AVPlayerStatus.failed.rawValue:
//                        self.state = .failed
//                        break
//                    default:
//                        break
//                    }
//                }
            }
            else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
                //@TODO: This gets check a lot
                // PlayerLoadedTimeRangesKey
                if let item = self.playerItem {
                    let timeRanges = item.loadedTimeRanges
                    if let timeRange = timeRanges.first?.timeRangeValue {
                        let bufferedTime: Float = Float(CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration)))
                        // Smart Value check for buffered time to switch to playing state
                        // or switch to buffering state
                        switch (bufferedTime - self.playbackPosition) > 5 || bufferedTime.rounded() == self.playbackPosition.rounded() {
                        case true:
                            if self.state != .buffering, self.state != .paused, self.state != .playing {
                                self.state = .playing
                            }
                        case false:
                            if self.state != .buffering && self.state != .paused {
                                self.state = .buffering
                            }
                        }
                        
                        self.bufferedTime = Float(bufferedTime)
                    } else {
//                        self.playFromCurrentTime()
                    }
                }
            }
        }
        else if (context == &PlayerLayerObserverContext) {
            if (self.playerView?.playerLayer.isReadyForDisplay)! {
                self.playerDelegate?.playerReady(self)
            }
        }
    }
}

// MARK: - AudioSession
extension AssetPlaybackManager {
    @objc func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo, let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interruptionType = AVAudioSessionInterruptionType(rawValue: typeInt) else { return }
        
        switch interruptionType {
        case .began:
            self.state = .interrupted
        case .ended:
            do {
                try AVAudioSession.sharedInstance().setActive(true, with: [])
                
                if shouldResumePlaybackAfterInterruption == false {
                    shouldResumePlaybackAfterInterruption = true
                    
                    return
                }
                
                guard let optionsInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
                
                let interruptionOptions = AVAudioSessionInterruptionOptions(rawValue: optionsInt)
                
                if interruptionOptions.contains(.shouldResume) {
                    play()
                }
            }
            catch {
                print("An Error occured activating the audio session while resuming from interruption: \(error)")
            }
        }
    }
    
    func setupAVAudioSession() {
        // Setup AVAudioSession to indicate to the system you how intend to play audio.
        let audioSession = AVAudioSession.sharedInstance()
        
        self.addAVAudioSessionObservers()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault)
        }
        catch {
            print("An error occured setting the audio session category: \(error)")
        }
        
        // Set the AVAudioSession as active.  This is required so that your application becomes the "Now Playing" app.
        do {
            try audioSession.setActive(true)
        }
        catch {
            print("An Error occured activating the audio session: \(error)")
        }
    }
    
    func addAVAudioSessionObservers() {
        // Add the notification observer needed to respond to audio interruptions.
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleAudioSessionInterruption(notification:)), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
    }
    
    func removeAVAudioSessionObservers() {
        // Remove audio session interruption observer
        NotificationCenter.default.removeObserver(self, name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
    }
}

// MARK: Playback Control Methods.
extension AssetPlaybackManager {
    func play() {
        self.state = .playing
    }
    
    func pause() {
        self.state = .paused
    }
    
    func togglePlayPause() {
        guard asset != nil else { return }
        
        if self.avPlayer.rate == 1.0 {
            self.state = .paused
        }
        else {
            self.state = .playing
        }
    }
    
    func stop() {
        self.state = .stopped
    }
    
    func nextTrack() {
        guard asset != nil else { return }
        
        NotificationCenter.default.post(name: AssetPlaybackManager.nextTrackNotification, object: nil, userInfo: [Asset.nameKey: asset.assetName])
    }
    
    func previousTrack() {
        guard asset != nil else { return }
        
        NotificationCenter.default.post(name: AssetPlaybackManager.previousTrackNotification, object: nil, userInfo: [Asset.nameKey: asset.assetName])
    }
    
    func skipForward(_ interval: TimeInterval) {
        guard asset != nil else { return }
        
        let currentTime = self.avPlayer.currentTime()
        let offset = CMTimeMakeWithSeconds(interval, 1)
        
        let newTime = CMTimeAdd(currentTime, offset)
        self.avPlayer.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (_) in
            self.updatePlaybackRateMetadata()
            self.checkPaused()
        })
    }
    
    func skipBackward(_ interval: TimeInterval) {
        guard asset != nil else { return }
        
        let currentTime = self.avPlayer.currentTime()
        let offset = CMTimeMakeWithSeconds(interval, 1)
        
        let newTime = CMTimeSubtract(currentTime, offset)
        self.avPlayer.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (_) in
            self.updatePlaybackRateMetadata()
            self.checkPaused()
        })
    }
    
    func seekTo(_ position: TimeInterval) {
        guard asset != nil else { return }
        let newPosition = CMTimeMakeWithSeconds(position, 1)
        self.avPlayer.seek(to: newPosition, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (_) in
            self.updatePlaybackRateMetadata()
            self.checkPaused()
        })
    }
    
    func checkPaused() {
        if self.state == .paused {
            self.pause()
        }
    }
    
    func beginRewind() {
        guard asset != nil else { return }
        
        self.avPlayer.rate = -2.0
    }
    
    func beginFastForward() {
        guard asset != nil else { return }
        
        self.avPlayer.rate = 2.0
    }
    
    func endRewindFastForward() {
        guard asset != nil else { return }
        
        self.avPlayer.rate = 1.0
    }
}

// MARK: MPNowPlayingInforCenter Management Methods
extension AssetPlaybackManager {
    func updateGeneralMetadata() {
        guard self.avPlayer.currentItem != nil, let urlAsset = self.avPlayer.currentItem?.asset else {
            nowPlayingInfoCenter.nowPlayingInfo = nil
            
            return
        }
        
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        let title = AVMetadataItem.metadataItems(from: urlAsset.commonMetadata, withKey: AVMetadataKey.commonKeyTitle, keySpace: AVMetadataKeySpace.common).first?.value as? String ?? asset.assetName
        let album = AVMetadataItem.metadataItems(from: urlAsset.commonMetadata, withKey: AVMetadataKey.commonKeyAlbumName, keySpace: AVMetadataKeySpace.common).first?.value as? String ?? ""
        var artworkData = AVMetadataItem.metadataItems(from: urlAsset.commonMetadata, withKey: AVMetadataKey.commonKeyArtwork, keySpace: AVMetadataKeySpace.common).first?.value as? Data ?? Data()
        if let url = asset.artworkURL {
            if let data = try? Data(contentsOf: url) {
                artworkData = data
            }
        }
        
        let image = UIImage(data: artworkData) ?? UIImage()
        let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {  (_) -> UIImage in
            return image
        })
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    func updatePlaybackRateMetadata() {
        guard self.avPlayer.currentItem != nil else {
            nowPlayingInfoCenter.nowPlayingInfo = nil
            
            return
        }
        
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.avPlayer.currentItem!.currentTime())
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.avPlayer.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = self.avPlayer.rate
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        // @TODO: Don't think this should be here
//        if self.avPlayer.rate == 0.0 {
//            state = .paused
//        }
//        else {
//            state = .playing
//        }
        
    }
}

// MARK: - KVO

// KVO contexts

private var PlayerObserverContext = 0
private var PlayerItemObserverContext = 0
private var PlayerLayerObserverContext = 0

extension AssetPlaybackManager {
    // MARK: - AVPlayerLayerObservers
    
    internal func addPlayerLayerObservers() {
        guard playerView != nil else { return }
        print("here2")
        self.playerView?.layer.addObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay), options: ([.new, .old]), context: &PlayerLayerObserverContext)
    }
    
    internal func removePlayerLayerObservers() {
        guard playerView != nil else { return }
        print("here1")
        self.playerView?.layer.removeObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay), context: &PlayerLayerObserverContext)
    }
    
    internal func addPlayerObservers() {
        // Add the Key-Value Observers needed to keep internal state of `AssetPlaybackManager` and `MPNowPlayingInfoCenter` in sync.
        self.avPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), options: [.initial, .new], context: &PlayerItemObserverContext)
        self.avPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.new], context: &PlayerItemObserverContext)
    }
    
    internal func removePlayerObservers() {
        self.avPlayer.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), context: &PlayerItemObserverContext)
        self.avPlayer.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate), context: &PlayerItemObserverContext)
    }
    
    internal func addPlayerTimeObserver() {
        // Add a periodic time observer to keep `percentProgress` and `playbackPosition` up to date.
        timeObserverToken = self.avPlayer.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1.0 / 1.0, Int32(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { [weak self] time in
            let timeElapsed = Float(CMTimeGetSeconds(time))
            guard let duration = self?.self.avPlayer.currentItem?.duration else { return }
            
            let durationInSecods = Float(CMTimeGetSeconds(duration))

            self?.playbackPosition = timeElapsed
            self?.percentProgress = timeElapsed / durationInSecods
        })
    }
    
    internal func removePlayerTimeObserver() {
        // Remove the periodic time observer.
        if let timeObserverToken = timeObserverToken {
            self.avPlayer.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    // Player buffer observers
    internal func addPlayerItemObservers() {
//        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.initial, .new], context: &PlayerItemObserverContext)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleAVPlayerItemDidPlayToEndTimeNotification(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), options: ([.new, .old]), context: &PlayerItemObserverContext)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: ([.new, .old]), context: &PlayerItemObserverContext)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: ([.new, .old]), context: &PlayerItemObserverContext)
    }
    
    internal func removePlayerItemObservers() {
//        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &PlayerItemObserverContext)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), context: &PlayerItemObserverContext)
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), context: &PlayerItemObserverContext)
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), context: &PlayerItemObserverContext)
    }
}
