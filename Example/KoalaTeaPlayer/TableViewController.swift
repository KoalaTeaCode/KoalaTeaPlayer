//
//  TableViewController.swift
//  KoalaTeaPlayer_Example
//
//  Created by Craig Holliday on 12/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import KoalaTeaPlayer

class TableViewController: YTViewControllerTablePresenter {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 20
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = "Example"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let videoUrl = URL(string: "http://wpc.1765A.taucdn.net/801765A/video/uploads/videos/65c3a707-016e-474c-8838-c295bb491a16/index.m3u8") else { return }
        let artworkURL = URL(string: "https://i.imgur.com/Dw9elyF.png")
        
        self.loadYTPlayerViewWith(assetName: "Play that demooooo", videoURL: videoUrl, artworkURL: artworkURL, savedTime: 0)
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
