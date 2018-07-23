//
//  SearchTableViewController.swift
//  iData
//
//  Created by ios dev on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit
import QuickLook
import SafariServices
import DownloadButton
import Alamofire

class SearchTableViewController: UITableViewController {
    var paper: Paper?
    var searchResults = [PaperItem]()
    var totalCount: Int? = nil
    var paperItem: PaperItem!
    internal var dUrl: DURL?
    var loadMoreStatus = false
    
    var searchController: UISearchController!
    
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
        let docDetailViewController = searchStoryBoard.instantiateViewController(withIdentifier: DocDetailViewController.viewControllerIdentifier) as! DocDetailViewController
        docDetailViewController.paperItem = paperItem
        
        self.presentingViewController?.navigationController?.showDetailViewController(docDetailViewController, sender: nil)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            if paper?.data?.start != nil {
                loadMore()
            }
        }
    }
    
    func loadMore() {
        if !loadMoreStatus {
            self.loadMoreStatus = true
            self.tableView.tableFooterView?.isHidden = false
            let searchBar = searchController.searchBar
            let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
            searchPapers(searchController.searchBar.text!, scope: scope, start: paper?.data?.start)
        }
    }
    
    // MARK: - Private instance methods
    
    func searchPapers(_ searchText: String, scope: String = "SCDB", start: String? = nil) {
        let parameters: Parameters = [
            "app_id": "iOSDevLog",
            "access_token": "C3RoqraAz6nTJBhF",
            "keyword": searchText,
            "sort_type": "1",
            "db": scope,
            "start": start ?? "0",
            "advance": "0",
            ]
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(kSearchUrl, method: .get, parameters: parameters).responsePaper { [weak self] response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let strongSelf = self else { return }
            strongSelf.loadMoreStatus = false
            strongSelf.tableView.tableFooterView?.isHidden = true
            
            if let paper = response.result.value, let items = paper.data?.items {
                strongSelf.paper = paper
                if start == "0" {
                    strongSelf.searchResults = items
                } else {
                    strongSelf.searchResults.append(contentsOf: items)
                }
                if !(strongSelf.searchBarIsEmpty()) {
                    strongSelf.tableView.reloadData()
                }
                print("paper = \(paper)" )
            } else {
                toast(contentView: strongSelf.tableView, message: "NetworkError")
                print(response.error.debugDescription)
            }
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchPapers(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension SearchTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        searchPapers(searchController.searchBar.text!, scope: scope)
    }
}

