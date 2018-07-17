//
//  SearchTableViewController.swift
//  iData
//
//  Created by ios dev on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {
    var searchResults = [PaperItem]()
    var totalCount: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as! SearchTableViewCell

        // Configure the cell...
        let paperItem = searchResults[indexPath.row]
        cell.titleLabel.attributedText = html2AttributedString(string: paperItem.title)
        cell.authorLabel.attributedText = html2AttributedString(string: paperItem.author)
        cell.publishTimeLabel.attributedText = html2AttributedString(string: paperItem.publishTime)
        cell.dataBaseLabel.attributedText =  html2AttributedString(string: paperItem.database)
        cell.sourceLabel.attributedText =  html2AttributedString(string: paperItem.source)
        cell.orgnizLabel.attributedText =  html2AttributedString(string: paperItem.orgniz)
        cell.abstractLabel.attributedText = html2AttributedString(string: paperItem.abstract)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let totalCount = totalCount {
            return "Total Count: " + String(totalCount)
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let paperItem = searchResults[indexPath.row]
        let searchStoryBoard = UIStoryboard.init(name: "Search", bundle: nil)
        let docDetailCollectionViewController = searchStoryBoard.instantiateViewController(withIdentifier: DocDetailCollectionViewController.viewControllerIdentifier) as! DocDetailCollectionViewController
        docDetailCollectionViewController.paperItem = paperItem
        
        self.presentingViewController?.navigationController?.show(docDetailCollectionViewController, sender: nil)
    }
}