/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	`Asset` is a wrapper struct around an `AVURLAsset` and its asset name.
 */

import Foundation
import AVFoundation

public class Asset {
    // MARK: Types
    static let nameKey = "AssetName"
    
    // MARK: Properties
    
    /// The name of the asset to present in the application.
    var assetName: String = ""
    
    // Custom artwork
    var artworkURL: URL? = nil
    
    /// The `AVURLAsset` corresponding to an asset in either the application bundle or on the Internet.
    var urlAsset: AVURLAsset
    
    let savedTime: Float = 0
    
    public init(assetName: String, url: URL, artworkURL: URL? = nil) {
        self.assetName = assetName
        let avURLAsset = AVURLAsset(url: url)
        self.urlAsset = avURLAsset
        self.artworkURL = artworkURL
    }
}

extension Asset: Equatable {
    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.assetName == rhs.assetName && lhs.urlAsset == lhs.urlAsset
    }
}
