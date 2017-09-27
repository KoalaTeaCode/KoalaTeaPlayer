# KoalaTeaPlayer

[![CI Status](http://img.shields.io/travis/themisterholliday/KoalaTeaPlayer.svg?style=flat)](https://travis-ci.org/themisterholliday/KoalaTeaPlayer)
[![Version](https://img.shields.io/cocoapods/v/KoalaTeaPlayer.svg?style=flat)](http://cocoapods.org/pods/KoalaTeaPlayer)
[![License](https://img.shields.io/cocoapods/l/KoalaTeaPlayer.svg?style=flat)](http://cocoapods.org/pods/KoalaTeaPlayer)
[![Platform](https://img.shields.io/cocoapods/p/KoalaTeaPlayer.svg?style=flat)](http://cocoapods.org/pods/KoalaTeaPlayer)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

KoalaTeaPlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'KoalaTeaPlayer'
```

## Usage
Setup the assetPlayer.

```swift
let urlString = "http://traffic.libsyn.com/sedaily/PeriscopeData.mp3"
let audioURL = URL(string: urlString)

let artworkURL = URL(string: "https://www.w3schools.com/w3images/fjords.jpg")

let asset = Asset(assetName: "Test", url: audioURL!, artworkURL: artworkURL)
let assetPlaybackManager = AssetPlayer(asset: asset)
assetPlaybackManager.playerDelegate = self

// If you want remote commands
// Initializer the `RemoteCommandManager`.
remoteCommandManager = RemoteCommandManager(assetPlaybackManager: assetPlaybackManager)

// Always enable playback commands in MPRemoteCommandCenter.
remoteCommandManager.activatePlaybackCommands(true)
remoteCommandManager.toggleChangePlaybackPositionCommand(true)
remoteCommandManager.toggleSkipBackwardCommand(true, interval: 30)
remoteCommandManager.toggleSkipForwardCommand(true, interval: 30)
```

Setup the delegate methods
```swift
extension ViewController: AssetPlayerDelegate {
    func playerIsSetup(_ player: AssetPlayer) {
        // Max values and initial values should be setup
        // Setup duration text
        print(player.durationText)
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
```

## Author

themisterholliday, themisterholliday@gmail.com

## License

KoalaTeaPlayer is available under the MIT license. See the LICENSE file for more info.