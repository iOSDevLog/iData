//
//  MasterViewController.swift
//  iData
//
//  Created by ios dev on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

import UIKit
import Alamofire

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var searchResults = [PaperItem]()
    let paper: Paper? = nil

    var searchController: UISearchController!
    private let downloadQueue = DispatchQueue(label: "com.iosdevlog.iData.Search")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // Setup the Search Controller
        let searchStoryboard = UIStoryboard.init(name: "Search", bundle: nil)
        let searchResultsController = searchStoryboard.instantiateViewController(withIdentifier: "SearchTableViewController")
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            // Fallback on earlier versions
        }
        searchController.searchBar.placeholder = "Search Papers"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
            tableView.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["SCDB", "CJFQ", "CDMD", "CIPD", "CCND"]
        searchController.searchBar.delegate = self
        
        self.tableView.tableFooterView = UIView()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = true
        }
    }

    @objc
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row] as! NSDate
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    // MARK: - Private instance methods
    
    func searchPapers(_ searchText: String, scope: String = "SCDB") {
        let parameters: Parameters =
            [
                "app_id": "iOSDevLog",
                "access_token": "C3RoqraAz6nTJBhF",
                "keyword": searchText,
                "sort_type": "1",
                "db": scope,
                "start": "0",
                "advance": "0",
                ]
        
        downloadQueue.async {
            Alamofire.request(kSearchUrl, method: .get, parameters: parameters).responsePaper { [weak self] response in
                if let paper = response.result.value, let items = paper.data?.items {
                    print(paper)
                    self?.searchResults = items
                    if !(self!.searchBarIsEmpty()) {
                        let vc = self?.searchController.searchResultsController as! SearchTableViewController
                        vc.searchResults = self!.searchResults
                        vc.totalCount = paper.data?.totalCount
                        DispatchQueue.main.async {
                            vc.tableView.reloadData()
                        }
                    }
                } else {
                    print(response.error.debugDescription)
                }
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

extension MasterViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchPapers(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        searchPapers(searchController.searchBar.text!, scope: scope)
    }
}
