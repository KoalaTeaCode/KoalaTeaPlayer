//
//  YTViewControllerPresenter.swift
//  KoalaTeaPlayer
//
//  Created by Craig Holliday on 12/6/17.
//

import UIKit

open class YTViewControllerPresenter: UIViewController {
    
    var ytNavigationController: YTViewController? = nil

    override open func viewDidLoad() {
        super.viewDidLoad()

        guard let navigationController = self.navigationController as? YTViewController else {
            print("The navigation controller is not a YTViewController")
            return
        }
        self.ytNavigationController = navigationController
        self.ytNavigationController?.ytViewControllerDelegate = self
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func loadYTPlayerViewWith(assetName: String, videoURL: URL, artworkURL: URL? = nil, savedTime: Float = 0) {
        guard let ytNavigationController = ytNavigationController else { return }
        ytNavigationController.loadYTPlayerViewWith(assetName: assetName, videoURL: videoURL, artworkURL: artworkURL, savedTime: savedTime)
        self.hideStatusBar()
    }
    
    open func showStatusBar() {
        statusBarShouldBeHidden = false
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    open func hideStatusBar() {
        statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    open var statusBarShouldBeHidden = false
    
    override open var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
}

extension YTViewControllerPresenter: YTViewControllerDelegate {
    public func didMinimize() {
        showStatusBar()
    }
    
    public func didmaximize() {
        hideStatusBar()
    }
    
    public func didSwipeAway() {
        
    }
}

open class YTViewControllerTablePresenter: UITableViewController {
    
    var ytNavigationController: YTViewController? = nil
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        guard let navigationController = self.navigationController as? YTViewController else {
            print("The navigation controller is not a YTViewController")
            return
        }
        self.ytNavigationController = navigationController
        self.ytNavigationController?.ytViewControllerDelegate = self
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func loadYTPlayerViewWith(assetName: String, videoURL: URL, artworkURL: URL? = nil, savedTime: Float = 0) {
        guard let ytNavigationController = ytNavigationController else { return }
        ytNavigationController.loadYTPlayerViewWith(assetName: assetName, videoURL: videoURL, artworkURL: artworkURL, savedTime: savedTime)
        self.hideStatusBar()
    }
    
    open func showStatusBar() {
        statusBarShouldBeHidden = false
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    open func hideStatusBar() {
        statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    open var statusBarShouldBeHidden = false
    
    override open var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
}

extension YTViewControllerTablePresenter: YTViewControllerDelegate {
    public func didMinimize() {
        showStatusBar()
    }
    
    public func didmaximize() {
        hideStatusBar()
    }
    
    public func didSwipeAway() {
        
    }
}

open class YTViewControllerCollectionPresenter: UICollectionViewController {
    
    var ytNavigationController: YTViewController? = nil
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        guard let navigationController = self.navigationController as? YTViewController else {
            print("The navigation controller is not a YTViewController")
            return
        }
        self.ytNavigationController = navigationController
        self.ytNavigationController?.ytViewControllerDelegate = self
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func loadYTPlayerViewWith(assetName: String, videoURL: URL, artworkURL: URL? = nil, savedTime: Float = 0) {
        guard let ytNavigationController = ytNavigationController else { return }
        ytNavigationController.loadYTPlayerViewWith(assetName: assetName, videoURL: videoURL, artworkURL: artworkURL, savedTime: savedTime)
        self.hideStatusBar()
    }
    
    open func showStatusBar() {
        statusBarShouldBeHidden = false
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    open func hideStatusBar() {
        statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    open var statusBarShouldBeHidden = false
    
    override open var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
}

extension YTViewControllerCollectionPresenter: YTViewControllerDelegate {
    public func didMinimize() {
        showStatusBar()
    }
    
    public func didmaximize() {
        hideStatusBar()
    }
    
    public func didSwipeAway() {
        
    }
}
